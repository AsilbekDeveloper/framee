import { createClient } from 'jsr:@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
}

const STORAGE_BUCKETS = ['avatars', 'post-images']

function json(body: unknown, status: number): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  })
}

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }
  if (req.method !== 'POST') {
    return json({ error: 'Method not allowed' }, 405)
  }

  try {
    // The account being deleted is always derived from the caller's own JWT —
    // never from the request body — so a user can only ever delete themselves.
    const authHeader = req.headers.get('Authorization')
    if (!authHeader) {
      return json({ error: 'Missing authorization header' }, 401)
    }

    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const anonKey = Deno.env.get('SUPABASE_ANON_KEY')!
    const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!

    // Caller-scoped client — resolves who is making the request.
    const userClient = createClient(supabaseUrl, anonKey, {
      global: { headers: { Authorization: authHeader } },
    })
    const {
      data: { user },
      error: userErr,
    } = await userClient.auth.getUser()

    if (userErr || !user) {
      return json({ error: 'Invalid or expired token' }, 401)
    }

    const userId = user.id

    // Admin client — service role bypasses RLS to perform the deletion.
    const admin = createClient(supabaseUrl, serviceRoleKey, {
      auth: { autoRefreshToken: false, persistSession: false },
    })

    // 1. Remove the user's storage objects. Both buckets use a flat
    //    `{userId}/{file}` layout, so a single list + remove per bucket covers
    //    everything. Storage is not FK-cascaded, so this must be explicit.
    //    A failure here is logged but non-fatal — the account must still delete.
    for (const bucket of STORAGE_BUCKETS) {
      const { data: files, error: listErr } = await admin.storage
        .from(bucket)
        .list(userId)
      if (listErr) {
        console.error(`delete-account: list ${bucket} failed — ${listErr.message}`)
        continue
      }
      if (files && files.length > 0) {
        const paths = files.map((f) => `${userId}/${f.name}`)
        const { error: removeErr } = await admin.storage.from(bucket).remove(paths)
        if (removeErr) {
          console.error(
            `delete-account: remove from ${bucket} failed — ${removeErr.message}`,
          )
        }
      }
    }

    // 2. Delete the profile row. Every user-owned table (posts, comments,
    //    follows, likes, notifications, saved_posts) has an ON DELETE CASCADE
    //    FK to profiles.id, so this one delete clears all their content.
    const { error: profileErr } = await admin
      .from('profiles')
      .delete()
      .eq('id', userId)
    if (profileErr) {
      console.error(`delete-account: profile delete failed — ${profileErr.message}`)
      return json({ error: 'Failed to delete profile data' }, 500)
    }

    // 3. Delete the auth user itself. profiles has no FK to auth.users, so
    //    without this the email would stay registered and the account would
    //    only be half-deleted.
    const { error: authErr } = await admin.auth.admin.deleteUser(userId)
    if (authErr) {
      console.error(`delete-account: auth user delete failed — ${authErr.message}`)
      return json({ error: 'Failed to delete account' }, 500)
    }

    return json({ success: true }, 200)
  } catch (e) {
    console.error(`delete-account: unexpected error — ${e}`)
    return json({ error: 'Internal server error' }, 500)
  }
})
