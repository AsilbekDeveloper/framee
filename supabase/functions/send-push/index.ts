import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const fcmServerKey = Deno.env.get('FCM_SERVER_KEY')
    if (!fcmServerKey) throw new Error('FCM_SERVER_KEY not configured in Edge Function secrets')

    const body = await req.json()
    const { notification, registration_ids, condition } = body

    if (!notification?.title || !notification?.body) {
      throw new Error('notification.title and notification.body are required')
    }

    // Build FCM payload
    const fcmPayload: Record<string, unknown> = { notification }

    if (registration_ids && registration_ids.length > 0) {
      // Single token
      if (registration_ids.length === 1) {
        fcmPayload.to = registration_ids[0]
      } else {
        // Batch — FCM allows up to 1000 per request
        fcmPayload.registration_ids = registration_ids.slice(0, 1000)
      }
    } else if (condition) {
      fcmPayload.condition = condition
    } else {
      throw new Error('Provide registration_ids or condition')
    }

    const fcmRes = await fetch('https://fcm.googleapis.com/fcm/send', {
      method: 'POST',
      headers: {
        'Authorization': `key=${fcmServerKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(fcmPayload),
    })

    const fcmData = await fcmRes.json()

    if (!fcmRes.ok) {
      throw new Error(`FCM error ${fcmRes.status}: ${JSON.stringify(fcmData)}`)
    }

    return new Response(JSON.stringify({ success: true, fcm: fcmData }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  } catch (err) {
    return new Response(JSON.stringify({ error: (err as Error).message }), {
      status: 400,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  }
})
