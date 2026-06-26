import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
const FIREBASE_SERVICE_ACCOUNT = Deno.env.get('FIREBASE_SERVICE_ACCOUNT')!

interface NotificationRecord {
  id: string
  user_id: string
  actor_id: string
  type: string
  post_id: string | null
  is_read: boolean
  created_at: string
}

type Locale = 'en' | 'uz' | 'ru'

const messages: Record<string, Record<Locale, (actor: string) => string>> = {
  like: {
    en: (a) => `${a} liked your post`,
    uz: (a) => `${a} postingizni yoqladi`,
    ru: (a) => `${a} оценил ваш пост`,
  },
  comment: {
    en: (a) => `${a} commented on your post`,
    uz: (a) => `${a} postingizga izoh qoldirdi`,
    ru: (a) => `${a} прокомментировал ваш пост`,
  },
  mention: {
    en: (a) => `${a} mentioned you in a comment`,
    uz: (a) => `${a} izohda sizni esladi`,
    ru: (a) => `${a} упомянул вас в комментарии`,
  },
  follow: {
    en: (a) => `${a} started following you`,
    uz: (a) => `${a} sizni kuzata boshladi`,
    ru: (a) => `${a} подписался на вас`,
  },
  follow_request: {
    en: (a) => `${a} wants to follow you`,
    uz: (a) => `${a} sizni kuzatmoqchi`,
    ru: (a) => `${a} хочет подписаться на вас`,
  },
}

// FCM HTTP v1 — service account JWT → access token
async function getAccessToken(serviceAccount: Record<string, string>): Promise<string> {
  const now = Math.floor(Date.now() / 1000)
  const encoder = new TextEncoder()

  const b64url = (data: string) =>
    btoa(data).replace(/\+/g, '-').replace(/\//g, '_').replace(/=/g, '')

  const header = b64url(JSON.stringify({ alg: 'RS256', typ: 'JWT' }))
  const payload = b64url(JSON.stringify({
    iss: serviceAccount.client_email,
    scope: 'https://www.googleapis.com/auth/firebase.messaging',
    aud: 'https://oauth2.googleapis.com/token',
    iat: now,
    exp: now + 3600,
  }))

  const toSign = `${header}.${payload}`

  const pemContents = serviceAccount.private_key
    .replace(/-----BEGIN PRIVATE KEY-----/g, '')
    .replace(/-----END PRIVATE KEY-----/g, '')
    .replace(/\s/g, '')

  const keyData = Uint8Array.from(atob(pemContents), (c) => c.charCodeAt(0))
  const cryptoKey = await crypto.subtle.importKey(
    'pkcs8',
    keyData,
    { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' },
    false,
    ['sign'],
  )

  const sigBytes = await crypto.subtle.sign('RSASSA-PKCS1-v1_5', cryptoKey, encoder.encode(toSign))
  const sig = b64url(String.fromCharCode(...new Uint8Array(sigBytes)))
  const jwt = `${toSign}.${sig}`

  const tokenRes = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
      assertion: jwt,
    }),
  })

  const tokenData = await tokenRes.json()
  if (!tokenData.access_token) {
    throw new Error(`Failed to get access token: ${JSON.stringify(tokenData)}`)
  }
  return tokenData.access_token
}

// Clear stale FCM token from profiles table so we don't try again
async function clearStaleToken(supabase: ReturnType<typeof createClient>, userId: string) {
  try {
    await supabase.from('profiles').update({ fcm_token: null }).eq('id', userId)
    console.log(`Cleared stale FCM token for user ${userId}`)
  } catch (e) {
    console.error(`Failed to clear stale token: ${e}`)
  }
}

serve(async (req) => {
  try {
    const payload = await req.json()

    // Supabase Database Webhook sends: { type, table, record, old_record }
    const record = payload.record as NotificationRecord | undefined
    if (!record || payload.type !== 'INSERT') {
      return new Response('ignored', { status: 200 })
    }

    const { user_id, actor_id, type, post_id } = record

    // Never push a notification to yourself
    if (user_id === actor_id) {
      return new Response('self-notification skipped', { status: 200 })
    }

    // Non-follow types must have a post_id
    const isFollowType = type === 'follow' || type === 'follow_request'
    if (!isFollowType && !post_id) {
      console.log(`Skipping ${type} notification — missing post_id`)
      return new Response('missing post_id', { status: 200 })
    }

    const localizedMessages = messages[type]
    if (!localizedMessages) {
      console.log(`Unknown notification type: ${type}`)
      return new Response('unknown type', { status: 200 })
    }

    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)

    // Fetch recipient FCM token and locale in parallel with actor info
    const [recipientRes, actorRes] = await Promise.all([
      supabase.from('profiles').select('fcm_token, locale').eq('id', user_id).single(),
      supabase.from('profiles').select('username, display_name').eq('id', actor_id).single(),
    ])

    const recipient = recipientRes.data
    const actor = actorRes.data

    if (!recipient?.fcm_token) {
      console.log(`No FCM token for user ${user_id}`)
      return new Response('no token', { status: 200 })
    }

    if (!actor) {
      console.log(`Actor ${actor_id} not found`)
      return new Response('actor not found', { status: 200 })
    }

    const locale: Locale =
      recipient.locale === 'uz' || recipient.locale === 'ru' ? recipient.locale : 'en'

    const actorName = `@${actor.username}`
    const body = localizedMessages[locale](actorName)
    const route = isFollowType ? `/user/${actor_id}` : `/post/${post_id}`

    const serviceAccount = JSON.parse(FIREBASE_SERVICE_ACCOUNT)
    const accessToken = await getAccessToken(serviceAccount)
    const projectId = serviceAccount.project_id

    const fcmRes = await fetch(
      `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`,
      {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${accessToken}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          message: {
            token: recipient.fcm_token,
            notification: {
              title: 'Framee',
              body,
            },
            data: { route },
            android: {
              priority: 'high',
              notification: {
                sound: 'default',
                channel_id: 'framee_channel',
                click_action: 'FLUTTER_NOTIFICATION_CLICK',
              },
            },
            apns: {
              payload: {
                aps: { sound: 'default', badge: 1 },
              },
            },
          },
        }),
      },
    )

    const result = await fcmRes.json()
    console.log('FCM v1 response:', JSON.stringify(result))

    // Token is no longer valid — clean it up so we don't waste calls
    const isUnregistered =
      result?.error?.status === 'NOT_FOUND' ||
      result?.error?.details?.some(
        (d: { errorCode?: string }) => d.errorCode === 'UNREGISTERED',
      )

    if (isUnregistered) {
      await clearStaleToken(supabase, user_id)
    } else if (!fcmRes.ok) {
      console.error('FCM send failed:', JSON.stringify(result))
    }

    return new Response(JSON.stringify({ success: fcmRes.ok, result }), {
      headers: { 'Content-Type': 'application/json' },
      status: 200,
    })
  } catch (error) {
    console.error('Edge function error:', error)
    return new Response(JSON.stringify({ error: String(error) }), {
      headers: { 'Content-Type': 'application/json' },
      status: 500,
    })
  }
})
