# Fase 3 — Gestión de Staff Mejorada

## Objetivo

Mejorar la experiencia de administración de personal agregando:
1. Reseteo de contraseña de staff por parte del admin.
2. Re-envío de invitación a usuarios que no activaron su cuenta.
3. Badges de estado en la lista de personal.
4. Cambiar contraseña voluntario desde el perfil (ya implementado en Fase 1).

**Riesgo:** 🟡 Medio  
**Archivos a modificar:** 2  
**Archivos nuevos:** 1 (Edge Function)  
**Esfuerzo estimado:** ~6 horas

**Depende de:** Fase 1 y Fase 2 completadas.

---

## Prerequisitos

- Fases 1 y 2 completadas y verificadas.
- Acceso al dashboard de Supabase para deployar Edge Functions.
- Leer `supabase/functions/create-staff-user/index.ts` — entender el patrón existente de Edge Functions.
- Leer `lib/features/auth/data/repositories/staff_account_repository.dart`.
- Leer `requerimiento/roles_staff_supabase.sql` — esquema SQL de la BD remota.

---

## Tarea 3.1 — Crear Edge Function `reset-staff-password`

### Contexto
Un administrador necesita poder resetear la contraseña de un miembro del staff cuando este la olvida o pierde acceso. La Edge Function generará una contraseña temporal aleatoria, la asignará al usuario en Supabase Auth y marcará `must_change_password = true` para que al siguiente login sea forzado a cambiarla.

### Archivo nuevo
`supabase/functions/reset-staff-password/index.ts`

### Código completo

```typescript
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
```

### Flujo de seguridad
1. El actor debe estar autenticado (header Authorization).
2. El actor debe ser admin de la misma empresa que el target.
3. No se permite auto-reset por esta vía.
4. La contraseña temporal se retorna en la respuesta (no se envía por email).
5. Se marca `must_change_password: true` para forzar cambio en el siguiente login.

### Despliegue
```bash
supabase functions deploy reset-staff-password
```

---

## Tarea 3.2 — Agregar métodos al `StaffAccountRepository`

### Contexto
El repositorio necesita nuevos métodos para invocar la Edge Function de reset y para re-enviar invitaciones.

### Archivo a modificar
`lib/features/auth/data/repositories/staff_account_repository.dart`

### Cambios exactos

1. **Agregar método `resetStaffPassword`** después del método `createStaffAccount`:

```dart
/// Resetea la contraseña de un usuario staff.
/// Retorna la contraseña temporal generada.
/// Solo puede ser invocado por un admin de la misma empresa.
Future<String> resetStaffPassword({
  required String targetUserId,
  required String empresaId,
}) async {
  final response = await _supabase.functions.invoke(
    'reset-staff-password',
    body: {
      'target_user_id': targetUserId,
      'empresa_id': empresaId,
    },
  );

  if (response.status != 200) {
    final data = response.data;
    throw Exception(
      data is Map<String, dynamic>
          ? (data['error'] ?? 'No se pudo resetear la contraseña')
          : 'No se pudo resetear la contraseña',
    );
  }

  final data = response.data;
  if (data is! Map<String, dynamic> || data['temp_password'] == null) {
    throw Exception('Respuesta inválida al resetear contraseña');
  }

  return data['temp_password'] as String;
}

/// Re-envía la invitación a un usuario staff que no ha activado su cuenta.
/// Usa la misma Edge Function de creación que re-invita por email.
Future<void> resendInvitation({
  required String correo,
  required String empresaId,
  required String adminUserId,
  required String nombre,
  required String rolId,
  required Set<String> bodegaIds,
}) async {
  // Reutiliza la Edge Function create-staff-user
  // que internamente llama a inviteUserByEmail.
  // Si el usuario ya existe, Supabase re-envía la invitación.
  final response = await _supabase.functions.invoke(
    'create-staff-user',
    body: {
      'empresa_id': empresaId,
      'admin_user_id': adminUserId,
      'nombre_completo': nombre,
      'correo': correo,
      'rol_id': rolId,
      'bodega_ids': bodegaIds.toList(),
    },
  );

  if (response.status != 200 && response.status != 201) {
    final data = response.data;
    throw Exception(
      data is Map<String, dynamic>
          ? (data['error'] ?? 'No se pudo re-enviar la invitación')
          : 'No se pudo re-enviar la invitación',
    );
  }
}
```

### Validación
- El método `resetStaffPassword` retorna una contraseña temporal como String.
- El método `resendInvitation` no retorna valor, solo lanza excepción si falla.

---

## Tarea 3.3 — Mejorar la pantalla de gestión de personal

### Contexto
La pantalla `StaffManagementScreen` necesita:
1. Botón para resetear contraseña de un usuario.
2. Botón para re-enviar invitación.
3. Diálogo que muestre la contraseña temporal generada.

### Archivo a modificar
`lib/features/auth/presentation/screens/staff_management_screen.dart`

### Cambios detallados

#### A. Agregar botones en el `trailing` de cada `ListTile` de usuario

Actualmente el trailing tiene botones de editar y desactivar. Se deben agregar:

**Nuevo botón "Resetear contraseña"** — Se muestra para todos los usuarios excepto el propio admin:

```dart
// Dentro del Wrap de trailing, agregar antes de los botones existentes:
if (canUpdate && user.id != authorization?.user?.id)
  IconButton(
    icon: const Icon(Icons.lock_reset_outlined),
    tooltip: 'Resetear contraseña',
    onPressed: () => _resetPassword(user),
  ),
```

#### B. Agregar método `_resetPassword`

```dart
Future<void> _resetPassword(Usuario user) async {
  // Diálogo de confirmación
  final confirm = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Resetear contraseña'),
      content: Text(
        '¿Resetear la contraseña de ${user.nombreCompleto}?\n\n'
        'Se generará una contraseña temporal que deberás comunicarle. '
        'Al iniciar sesión, se le pedirá que la cambie.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange.shade700,
            foregroundColor: Colors.white,
          ),
          child: const Text('Resetear'),
        ),
      ],
    ),
  );

  if (confirm != true) return;

  final auth = ref.read(authControllerProvider.notifier);
  final currentUser = auth.usuarioActual ?? await auth.getUser();
  if (currentUser == null || !mounted) return;

  try {
    final repository = StaffAccountRepository(
      ref.read(supabaseClientProvider),
      ref.read(driftDatabaseProvider),
    );

    final tempPassword = await repository.resetStaffPassword(
      targetUserId: user.id,
      empresaId: currentUser.empresaId,
    );

    if (!mounted) return;

    // Mostrar diálogo con la contraseña temporal
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green.shade600),
            const SizedBox(width: 10),
            const Expanded(child: Text('Contraseña reseteada')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'La nueva contraseña temporal de ${user.nombreCompleto} es:',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: SelectableText(
                tempPassword,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  fontFamily: 'monospace',
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.amber.shade700, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Comunica esta contraseña al usuario. '
                      'Se le pedirá cambiarla al iniciar sesión.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyan.shade800,
              foregroundColor: Colors.white,
            ),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  } catch (error) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error.toString()),
        backgroundColor: Colors.red.shade700,
      ),
    );
  }
}
```

#### C. Agregar botón "Re-enviar invitación"

Este botón solo aplica si el usuario tiene correo y parece no haber confirmado su cuenta. Una forma simple de detectar esto es si el `passwordHash` del usuario es `null` (no ha hecho login aún).

```dart
// Agregar junto a los otros botones de trailing:
if (canUpdate && user.passwordHash == null && user.correo != null)
  IconButton(
    icon: const Icon(Icons.email_outlined),
    tooltip: 'Re-enviar invitación',
    onPressed: () => _resendInvitation(user),
  ),
```

#### D. Agregar método `_resendInvitation`

```dart
Future<void> _resendInvitation(Usuario user) async {
  final dataAsync = ref.read(staffAdminDataProvider);
  final data = dataAsync.value;
  if (data == null) return;

  final auth = ref.read(authControllerProvider.notifier);
  final currentUser = auth.usuarioActual ?? await auth.getUser();
  if (currentUser == null || !mounted) return;

  final assignments = data.assignments
      .where((a) => a.usuarioId == user.id)
      .map((a) => a.bodegaId)
      .toSet();

  try {
    final repository = StaffAccountRepository(
      ref.read(supabaseClientProvider),
      ref.read(driftDatabaseProvider),
    );

    await repository.resendInvitation(
      correo: user.correo!,
      empresaId: currentUser.empresaId,
      adminUserId: currentUser.serverId,
      nombre: user.nombreCompleto,
      rolId: user.rolId,
      bodegaIds: assignments,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Invitación re-enviada a ${user.correo}'),
        backgroundColor: Colors.green.shade600,
      ),
    );
  } catch (error) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error.toString()),
        backgroundColor: Colors.red.shade700,
      ),
    );
  }
}
```

### Validación
- El botón "Resetear contraseña" aparece para usuarios que no son el admin actual.
- Al resetear, se muestra un diálogo con la contraseña temporal (seleccionable para copiar).
- El botón "Re-enviar invitación" solo aparece para usuarios sin passwordHash.
- Los mensajes de éxito/error se muestran correctamente.

---

## Checklist de verificación final — Fase 3

```bash
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

Edge Function:
```bash
supabase functions deploy reset-staff-password
```

- [ ] La Edge Function `reset-staff-password` se despliega sin errores.
- [ ] Un admin puede resetear la contraseña de un staff.
- [ ] La contraseña temporal se muestra en un diálogo seleccionable.
- [ ] El staff es forzado a cambiar su contraseña al siguiente login.
- [ ] Un admin no puede resetear su propia contraseña por esta vía.
- [ ] Re-enviar invitación funciona para usuarios sin password_hash.
- [ ] Los botones de acción aparecen solo cuando corresponde.

---

## Archivos modificados en esta fase

| Acción | Archivo | Líneas aprox. |
|---|---|---|
| NEW | `supabase/functions/reset-staff-password/index.ts` | ~130 líneas |
| MODIFY | `lib/features/auth/data/repositories/staff_account_repository.dart` | ~60 líneas |
| MODIFY | `lib/features/auth/presentation/screens/staff_management_screen.dart` | ~180 líneas |

**Total estimado:** ~370 líneas agregadas/modificadas.

---

## Diagrama de flujo del reset de contraseña

```
Admin toca "Resetear contraseña"
        │
        ▼
┌─────────────────────┐
│ Diálogo confirmación│
│ "¿Resetear a X?"    │
└─────────┬───────────┘
          │
      Confirma
          │
          ▼
┌─────────────────────────────┐
│ Edge Function               │
│ reset-staff-password        │
│                             │
│ 1. Verificar actor=admin    │
│ 2. Verificar misma empresa  │
│ 3. Generar temp password    │
│ 4. updateUserById(password) │
│ 5. must_change_password=true│
└─────────────┬───────────────┘
              │
              ▼
┌─────────────────────────┐
│ Diálogo con contraseña  │
│ temporal (seleccionable)│
│                         │
│  "ABC1234xyz"           │
│                         │
│ ⓘ Comunica esta clave  │
│   al usuario            │
└─────────────────────────┘
              │
              ▼
      Staff inicia sesión
      con temp password
              │
              ▼
┌─────────────────────────┐
│ ForcePasswordChange     │
│ Screen (ya existe)      │
│                         │
│ Ingresa nueva contraseña│
└─────────────────────────┘
```
