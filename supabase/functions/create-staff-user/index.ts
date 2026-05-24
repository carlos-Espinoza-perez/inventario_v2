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
    const empresaId = body.empresa_id as string
    const adminUserId = body.admin_user_id as string
    const nombreCompleto = body.nombre_completo as string
    const correo = body.correo as string
    const rolId = body.rol_id as string
    const bodegaIds = (body.bodega_ids ?? []) as string[]

    if (
      !empresaId ||
      !adminUserId ||
      !nombreCompleto ||
      !correo ||
      !rolId
    ) {
      return json({ error: 'Missing required fields' }, 400)
    }

    const { data: actorProfile, error: actorProfileError } = await adminClient
      .from('usuario')
      .select('id, empresa_id, rol:rol_id(user_admin)')
      .eq('id', actor.id)
      .single()

    if (actorProfileError || !actorProfile) {
      return json({ error: 'Admin profile not found' }, 403)
    }

    const isAdmin = actorProfile.rol?.user_admin === true
    if (!isAdmin || actorProfile.empresa_id !== empresaId || actor.id !== adminUserId) {
      return json({ error: 'Only an administrator can create staff accounts' }, 403)
    }

    const { data: authUser, error: createAuthError } =
      await adminClient.auth.admin.inviteUserByEmail(correo, {
        redirectTo: 'io.supabase.inventario://login-callback/',
        data: {
          name: nombreCompleto,
          empresa_id: empresaId,
          must_change_password: true,
        },
      })

    if (createAuthError || !authUser.user) {
      return json({ error: createAuthError?.message ?? 'Could not invite user' }, 400)
    }

    const { data: profileData, error: profileError } = await adminClient.rpc(
      'sync_staff_profile',
      {
        p_user_id: authUser.user.id,
        p_empresa_id: empresaId,
        p_rol_id: rolId,
        p_nombre_completo: nombreCompleto,
        p_correo: correo,
        p_password_hash: null,
        p_usuario_registro_id: adminUserId,
        p_bodega_ids: bodegaIds,
      },
    )

    if (profileError || !profileData) {
      await adminClient.auth.admin.deleteUser(authUser.user.id)
      return json({ error: profileError?.message ?? 'Could not create staff profile' }, 400)
    }

    return json(profileData, 201)
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
