import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const FCM_SERVER_KEY = Deno.env.get('FCM_SERVER_KEY')!
const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!

interface NotificationRecord {
  id: string
  user_id: string
  actor_id: string
  type: string
  post_id: string | null
  is_read: boolean
  created_at: string
}

serve(async (req) => {
  try {
    const payload = await req.json()

    // Supabase Database Webhook format: { type, table, record, old_record }
    const record = payload.record as NotificationRecord | undefined
    if (!record || payload.type !== 'INSERT') {
      return new Response('ignored', { status: 200 })
    }

    const { user_id, actor_id, type, post_id } = record

    // Foydalanuvchi o'ziga notification yubormasin
    if (user_id === actor_id) {
      return new Response('self-notification skipped', { status: 200 })
    }

    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)

    // Recipient FCM token olish
    const { data: recipient } = await supabase
      .from('profiles')
      .select('fcm_token')
      .eq('id', user_id)
      .single()

    if (!recipient?.fcm_token) {
      console.log(`No FCM token for user ${user_id}`)
      return new Response('no token', { status: 200 })
    }

    // Actor ma'lumotlari
    const { data: actor } = await supabase
      .from('profiles')
      .select('username, display_name')
      .eq('id', actor_id)
      .single()

    if (!actor) {
      return new Response('actor not found', { status: 200 })
    }

    const actorName = actor.display_name || `@${actor.username}`

    // Notification matni va route belgilash
    let body: string
    let route: string

    switch (type) {
      case 'like':
        body = `${actorName} rasmingizni yoqtirdi`
        route = `/post/${post_id}`
        break
      case 'comment':
        body = `${actorName} rasmingizga izoh qoldirdi`
        route = `/post/${post_id}`
        break
      case 'mention':
        body = `${actorName} izohda sizni tilga oldi`
        route = `/post/${post_id}`
        break
      case 'follow':
        body = `${actorName} sizni kuzata boshladi`
        route = `/user/${actor_id}`
        break
      case 'follow_request':
        body = `${actorName} kuzatish so'rov yubordi`
        route = `/user/${actor_id}`
        break
      default:
        console.log(`Unknown notification type: ${type}`)
        return new Response('unknown type', { status: 200 })
    }

    // FCM Legacy API orqali push yuborish
    const fcmResponse = await fetch('https://fcm.googleapis.com/fcm/send', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `key=${FCM_SERVER_KEY}`,
      },
      body: JSON.stringify({
        to: recipient.fcm_token,
        priority: 'high',
        notification: {
          title: 'Framee',
          body,
          sound: 'default',
          click_action: 'FLUTTER_NOTIFICATION_CLICK',
        },
        data: {
          route,
        },
      }),
    })

    const result = await fcmResponse.json()
    console.log('FCM response:', JSON.stringify(result))

    if (result.failure > 0) {
      console.error('FCM send failed:', result.results)
    }

    return new Response(JSON.stringify({ success: true, result }), {
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
