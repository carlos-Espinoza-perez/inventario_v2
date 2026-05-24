# Fase 1 — Correcciones y Conexiones Faltantes

## Objetivo

Completar funcionalidad que ya existe parcialmente pero está rota o desconectada. No se agrega funcionalidad nueva, solo se conecta y corrige lo existente.

**Riesgo:** 🟢 Bajo  
**Archivos a modificar:** 4  
**Archivos nuevos:** 0  
**Esfuerzo estimado:** ~4 horas

---

## Prerequisitos

- Leer `AGENTS.md` completo antes de hacer cualquier cambio.
- Leer `lib/core/constants/permission_codes.dart` para entender los códigos de permisos.
- Leer `lib/features/auth/presentation/providers/authorization_provider.dart` para entender cómo se evalúan permisos.

---

## Tarea 1.1 — Agregar ruta `/role-management` al router

### Contexto
La pantalla `RoleManagementScreen` ya existe en `lib/features/auth/presentation/screens/role_management_screen.dart` y está completa (CRUD de roles con permisos granulares), pero **no tiene ruta registrada en GoRouter**, por lo que es inaccesible.

### Archivo a modificar
`lib/core/router/app_router.dart`

### Cambios exactos

1. **Agregar import** al inicio del archivo:
```dart
import '../../features/auth/presentation/screens/role_management_screen.dart';
```

2. **Agregar ruta** dentro del bloque `ShellRoute > routes`, después de la ruta `/staff-management` (aprox. línea 152):
```dart
GoRoute(
  path: '/role-management',
  builder: (context, state) => const RoleManagementScreen(),
),
```

### Validación
- La app debe compilar sin errores.
- Navegar a `/role-management` debe mostrar la pantalla de gestión de roles.

---

## Tarea 1.2 — Conectar botón "Gestionar roles" y corregir permisos hardcoded

### Contexto
En `StaffManagementScreen`, hay dos problemas:
1. El widget `_SummaryCard` tiene `onManageRoles: null`, por lo que el botón "Gestionar roles" nunca aparece.
2. Las variables `canUpdate` y `canDelete` están hardcoded a `true` (línea 57-58), ignorando los permisos reales del usuario.

### Archivo a modificar
`lib/features/auth/presentation/screens/staff_management_screen.dart`

### Cambios exactos

1. **Agregar import de GoRouter** (si no existe):
```dart
import 'package:go_router/go_router.dart';
```

2. **Agregar import de PermissionCode** (si no existe):
```dart
import 'package:inventario_v2/core/constants/permission_codes.dart';
```

3. **Reemplazar las líneas 57-58** (los `const canUpdate = true; const canDelete = true;`):

**Antes:**
```dart
const canUpdate = true;
const canDelete = true;
```

**Después:**
```dart
final canUpdate = authorization?.can(PermissionCode.staffUpdate) ?? false;
final canDelete = authorization?.can(PermissionCode.staffDelete) ?? false;
```

4. **Reemplazar el `onManageRoles: null`** en el widget `_SummaryCard` (aprox. línea 91):

**Antes:**
```dart
// TODO: Implementar vista de gestión de roles
onManageRoles: null,
```

**Después:**
```dart
onManageRoles: (authorization?.can(PermissionCode.roleRead) ?? false)
    ? () => context.push('/role-management')
    : null,
```

### Validación
- El botón "Gestionar roles" debe aparecer si el usuario tiene permiso `role.read`.
- Los botones de editar/desactivar personal deben respetar `staff.update` y `staff.delete`.
- Un usuario operador (sin permisos de staff) no debe ver los botones de acción.

---

## Tarea 1.3 — Implementar flujo "¿Olvidaste tu contraseña?"

### Contexto
En `form_login.dart` (línea 149-159), el texto "¿Olvidaste tu contraseña?" es un `Text` estático sin acción. Se debe convertir en un botón funcional que use `Supabase.auth.resetPasswordForEmail`.

### Archivo a modificar
`lib/features/auth/presentation/widgets/form_login.dart`

### Cambios exactos

1. **Agregar import de Supabase** al inicio:
```dart
import 'package:supabase_flutter/supabase_flutter.dart';
```

2. **Reemplazar el bloque del texto "¿Olvidaste tu contraseña?"** (líneas 149-159):

**Antes:**
```dart
Align(
  alignment: Alignment.centerRight,
  child: Text(
    "¿Olvidaste tu contraseña?",
    style: TextStyle(
      color: Colors.teal,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    ),
  ),
),
```

**Después:**
```dart
Align(
  alignment: Alignment.centerRight,
  child: GestureDetector(
    onTap: () => _showResetPasswordDialog(context),
    child: Text(
      "¿Olvidaste tu contraseña?",
      style: TextStyle(
        color: Colors.teal,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    ),
  ),
),
```

3. **Agregar método `_showResetPasswordDialog`** dentro de la clase `FormLoginState`, antes del método `build`:

```dart
Future<void> _showResetPasswordDialog(BuildContext context) async {
  final emailForReset = _emailCtrl.text.trim();

  if (emailForReset.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ingresa tu correo primero para recuperar tu contraseña.'),
        backgroundColor: Colors.orange,
      ),
    );
    return;
  }

  final confirm = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Recuperar contraseña'),
      content: Text(
        'Se enviará un enlace de recuperación a:\n\n$emailForReset\n\n¿Deseas continuar?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
          ),
          child: const Text('Enviar'),
        ),
      ],
    ),
  );

  if (confirm != true || !context.mounted) return;

  try {
    await Supabase.instance.client.auth.resetPasswordForEmail(emailForReset);

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Se envió un enlace de recuperación a $emailForReset',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 5),
      ),
    );
  } on AuthException catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: ${e.message}'),
        backgroundColor: Colors.red.shade700,
      ),
    );
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('No se pudo enviar el correo. Verifica tu conexión.'),
        backgroundColor: Colors.red.shade700,
      ),
    );
  }
}
```

### Comportamiento esperado
1. El usuario escribe su correo en el campo de email.
2. Toca "¿Olvidaste tu contraseña?".
3. Si el campo está vacío → muestra snackbar pidiendo que ingrese el correo.
4. Si hay correo → muestra diálogo de confirmación.
5. Si confirma → llama a `resetPasswordForEmail`.
6. Éxito → snackbar verde "Se envió un enlace de recuperación a...".
7. Error → snackbar rojo con mensaje de error.

### Validación
- El flujo funciona con un correo registrado en Supabase.
- Con correo no registrado, Supabase NO revela si el correo existe (por seguridad).
- Funciona solo con conexión a internet (mostrar error apropiado si está offline).

---

## Tarea 1.4 — Agregar "Cambiar contraseña" al perfil del usuario

### Contexto
La pantalla `UserProfileScreen` muestra información del usuario pero no permite cambiar la contraseña voluntariamente. Se debe agregar esta opción.

### Archivo a modificar
`lib/features/auth/presentation/screens/user_profile_screen.dart`

### Cambios exactos

1. **Agregar imports** al inicio:
```dart
import 'package:inventario_v2/core/constants/permission_codes.dart';
import 'package:inventario_v2/core/providers/supabase_provider.dart';
import 'package:inventario_v2/features/auth/presentation/providers/authorization_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
```

2. **Agregar un nuevo card de "Cambiar contraseña"** después del card de "Gestión de Personal" (después de la línea 121), antes del botón de cerrar sesión:

```dart
const SizedBox(height: 16),
CustomCard(
  padding: const EdgeInsets.all(16),
  onTap: () => _showChangePasswordDialog(context, ref),
  child: Row(
    children: [
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.lock_reset, color: Colors.orange.shade700, size: 28),
      ),
      const SizedBox(width: 16),
      const Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Cambiar Contraseña",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            SizedBox(height: 4),
            Text(
              "Actualizar tu contraseña de acceso al sistema",
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
      const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
    ],
  ),
),
```

3. **Agregar card de "Gestionar roles"** condicionado al permiso (después del card anterior):

```dart
// Solo mostrar si el usuario tiene permiso de role.read
Builder(
  builder: (context) {
    final authState = ref.watch(authorizationStateProvider).value;
    if (authState == null || !authState.can(PermissionCode.roleRead)) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: CustomCard(
        padding: const EdgeInsets.all(16),
        onTap: () => context.push('/role-management'),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.admin_panel_settings, color: Colors.purple.shade700, size: 28),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Roles y Permisos",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Gestionar roles y permisos de acceso al sistema",
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
          ],
        ),
      ),
    );
  },
),
```

4. **Agregar el método `_showChangePasswordDialog`** como una función estática o fuera del build:

```dart
void _showChangePasswordDialog(BuildContext context, WidgetRef ref) {
  final passwordCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool obscurePass = true;
  bool obscureConfirm = true;

  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => StatefulBuilder(
      builder: (context, setLocalState) => AlertDialog(
        title: const Text('Cambiar Contraseña'),
        content: SizedBox(
          width: 400,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Ingresa tu nueva contraseña. Debe tener al menos 6 caracteres.',
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: passwordCtrl,
                  obscureText: obscurePass,
                  enabled: !isLoading,
                  decoration: InputDecoration(
                    labelText: 'Nueva contraseña',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(obscurePass ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setLocalState(() => obscurePass = !obscurePass),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return 'La contraseña debe tener al menos 6 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: confirmCtrl,
                  obscureText: obscureConfirm,
                  enabled: !isLoading,
                  decoration: InputDecoration(
                    labelText: 'Confirmar contraseña',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(obscureConfirm ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setLocalState(() => obscureConfirm = !obscureConfirm),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (value) {
                    if (value != passwordCtrl.text) {
                      return 'Las contraseñas no coinciden';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          if (!isLoading)
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
          ElevatedButton(
            onPressed: isLoading
                ? null
                : () async {
                    if (!formKey.currentState!.validate()) return;
                    setLocalState(() => isLoading = true);

                    try {
                      final supabase = ref.read(supabaseClientProvider);
                      await supabase.auth.updateUser(
                        UserAttributes(password: passwordCtrl.text),
                      );

                      if (ctx.mounted) Navigator.pop(ctx);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Contraseña actualizada correctamente'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } on AuthException catch (e) {
                      setLocalState(() => isLoading = false);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: ${e.message}'),
                            backgroundColor: Colors.red.shade700,
                          ),
                        );
                      }
                    } catch (e) {
                      setLocalState(() => isLoading = false);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Error inesperado al cambiar contraseña'),
                            backgroundColor: Colors.red.shade700,
                          ),
                        );
                      }
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade800,
              foregroundColor: Colors.white,
            ),
            child: isLoading
                ? const SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Actualizar'),
          ),
        ],
      ),
    ),
  );
}
```

### Validación
- El diálogo de cambiar contraseña aparece y valida campos.
- La contraseña se actualiza en Supabase Auth.
- Se muestra snackbar de éxito/error.
- El card de "Roles y Permisos" solo aparece si el usuario tiene permiso `role.read`.

---

## Checklist de verificación final — Fase 1

```bash
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

- [ ] La app compila sin errores.
- [ ] La ruta `/role-management` navega correctamente.
- [ ] El botón "Gestionar roles" aparece en la pantalla de personal (si tiene permiso).
- [ ] "¿Olvidaste tu contraseña?" muestra diálogo y envía email.
- [ ] "Cambiar contraseña" desde el perfil funciona.
- [ ] Los botones de editar/desactivar personal respetan permisos reales.
- [ ] El card de "Roles y Permisos" solo aparece para usuarios con permiso.

---

## Archivos modificados en esta fase

| Acción | Archivo | Líneas aprox. modificadas |
|---|---|---|
| MODIFY | `lib/core/router/app_router.dart` | +5 líneas (import + ruta) |
| MODIFY | `lib/features/auth/presentation/screens/staff_management_screen.dart` | ~10 líneas |
| MODIFY | `lib/features/auth/presentation/widgets/form_login.dart` | ~70 líneas (método + UI) |
| MODIFY | `lib/features/auth/presentation/screens/user_profile_screen.dart` | ~120 líneas (cards + método) |

**Total estimado:** ~205 líneas agregadas/modificadas.
