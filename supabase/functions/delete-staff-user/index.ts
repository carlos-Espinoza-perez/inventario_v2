import { serve } from 'https://deno.land/std@0.224.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.49.8'

serve(async (req) => {
  try {
    const authHeader = req.headers.get('Authorization')
    if (!authHeader) {
      return json({ error: 'Missing authorization header' }, 401)
    }

    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const anonKey = Deno.env.get('SUPABASE_ANON_KEY')!
    const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!

    const userClient = createClient(supabaseUrl, anonKey, {
      global: { headers: { Authorization: authHeader } },
    })
    const adminClient = createClient(supabaseUrl, serviceRoleKey)

    const {
      data: { user: actor },
      error: actorError,
    } = await userClient.auth.getUser()

    if (actorError || !actor) {
      return json({ error: 'Unauthorized' }, 401)
    }

    const body = await req.json()
    const targetUserId = body.target_user_id as string
    const empresaId = body.empresa_id as string

    if (!targetUserId || !empresaId) {
      return json({ error: 'Missing required fields' }, 400)
    }

    // Verify actor is admin in the given company
    const { data: actorProfile, error: actorProfileError } = await adminClient
      .from('usuario')
      .select('id, empresa_id, rol:rol_id(user_admin)')
      .eq('id', actor.id)
      .single()

    if (actorProfileError || !actorProfile) {
      return json({ error: 'Admin profile not found' }, 403)
    }

    const isAdmin = actorProfile.rol?.user_admin === true
    if (!isAdmin || actorProfile.empresa_id !== empresaId) {
      return json({ error: 'Only an administrator can delete staff accounts' }, 403)
    }

    // Verify the target user belongs to the same company
    const { data: targetProfile, error: targetProfileError } = await adminClient
      .from('usuario')
      .select('id, empresa_id')
      .eq('id', targetUserId)
      .single()

    if (targetProfileError || !targetProfile) {
      return json({ error: 'Target user not found' }, 404)
    }

    if (targetProfile.empresa_id !== empresaId) {
      return json({ error: 'Cannot delete user from another company' }, 403)
    }

    // Finally delete from Supabase Auth
    // Note: If public.usuario has a foreign key to auth.users without ON DELETE CASCADE,
    // this will fail. We let Supabase throw the error so the frontend knows it failed.
    const { error: deleteAuthError } = await adminClient.auth.admin.deleteUser(
      targetUserId,
    )

    if (deleteAuthError) {
      return json(
        { error: deleteAuthError.message ?? 'Could not delete user from auth' },
        400,
      )
    }

    return json({ success: true }, 200)
  } catch (error) {
    return json(
      { error: error instanceof Error ? error.message : 'Unexpected error' },
      500,
    )
  }
})

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { 'Content-Type': 'application/json' },
  })
}
