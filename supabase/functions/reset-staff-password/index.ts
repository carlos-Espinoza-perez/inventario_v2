import { serve } from 'https://deno.land/std@0.224.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.49.8'

serve(async (req) => {
  try {
    // 1. Verificar autenticación
    const authHeader = req.headers.get('Authorization')
    if (!authHeader) {
      return json({ error: 'Missing authorization header' }, 401)
    }

    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const anonKey = Deno.env.get('SUPABASE_ANON_KEY')!
    const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!

    // Cliente con permisos del usuario que hace la petición
    const userClient = createClient(supabaseUrl, anonKey, {
      global: { headers: { Authorization: authHeader } },
    })
    // Cliente con permisos de servicio (puede modificar auth)
    const adminClient = createClient(supabaseUrl, serviceRoleKey)

    // 2. Obtener actor (quien hace la petición)
    const {
      data: { user: actor },
      error: actorError,
    } = await userClient.auth.getUser()

    if (actorError || !actor) {
      return json({ error: 'Unauthorized' }, 401)
    }

    // 3. Leer body de la petición
    const body = await req.json()
    const targetUserId = body.target_user_id as string
    const empresaId = body.empresa_id as string

    if (!targetUserId || !empresaId) {
      return json({ error: 'Missing required fields: target_user_id, empresa_id' }, 400)
    }

    // 4. Verificar que el actor es admin de la misma empresa
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
      return json({ error: 'Only an administrator of the same company can reset passwords' }, 403)
    }

    // 5. Verificar que el target user pertenece a la misma empresa
    const { data: targetProfile, error: targetProfileError } = await adminClient
      .from('usuario')
      .select('id, empresa_id, nombre_completo')
      .eq('id', targetUserId)
      .eq('empresa_id', empresaId)
      .single()

    if (targetProfileError || !targetProfile) {
      return json({ error: 'Target user not found in this company' }, 404)
    }

    // 6. No permitir que el admin se resetee a sí mismo por esta vía
    if (actor.id === targetUserId) {
      return json({ error: 'Cannot reset your own password through this endpoint. Use profile settings instead.' }, 400)
    }

    // 7. Generar contraseña temporal aleatoria
    const tempPassword = generateTempPassword()

    // 8. Actualizar la contraseña en Supabase Auth
    const { error: updateError } = await adminClient.auth.admin.updateUserById(
      targetUserId,
      {
        password: tempPassword,
        user_metadata: { must_change_password: true },
      },
    )

    if (updateError) {
      return json({ error: `Could not reset password: ${updateError.message}` }, 400)
    }

    // 9. Retornar la contraseña temporal
    // NOTA: Esta contraseña se muestra al admin en la app para que la comunique al staff.
    // NO se almacena en la base de datos ni en logs.
    return json({
      success: true,
      target_user_id: targetUserId,
      target_user_name: targetProfile.nombre_completo,
      temp_password: tempPassword,
      message: 'Password reset successful. The user must change their password on next login.',
    }, 200)

  } catch (error) {
    return json(
      { error: error instanceof Error ? error.message : 'Unexpected error' },
      500,
    )
  }
})

/**
 * Genera una contraseña temporal de 10 caracteres.
 * Formato: 3 letras mayúsculas + 4 dígitos + 3 letras minúsculas
 * Ejemplo: ABC1234xyz
 */
function generateTempPassword(): string {
  const upper = 'ABCDEFGHJKLMNPQRSTUVWXYZ' // Sin I ni O para evitar confusión
  const lower = 'abcdefghjkmnpqrstuvwxyz'   // Sin i, l, o para evitar confusión
  const digits = '23456789'                  // Sin 0, 1 para evitar confusión

  let password = ''
  for (let i = 0; i < 3; i++) password += upper[Math.floor(Math.random() * upper.length)]
  for (let i = 0; i < 4; i++) password += digits[Math.floor(Math.random() * digits.length)]
  for (let i = 0; i < 3; i++) password += lower[Math.floor(Math.random() * lower.length)]

  return password
}

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { 'Content-Type': 'application/json' },
  })
}
