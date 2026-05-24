# Fase 4 — Hub de Administración Unificado

## Objetivo

Crear un punto de entrada centralizado para toda la gestión administrativa del sistema. En lugar de tener las opciones dispersas en diferentes pantallas, el Hub de Administración agrupa:
- Gestión de Personal
- Gestión de Roles y Permisos
- Gestión de Bodegas
- Herramientas del sistema (sincronización, logs)

Además muestra un resumen rápido del estado actual del sistema.

**Riesgo:** 🟡 Medio  
**Archivos a modificar:** 2  
**Archivos nuevos:** 1  
**Esfuerzo estimado:** ~4 horas

**Depende de:** Fases 1, 2 y 3 completadas.

---

## Prerequisitos

- Fases 1, 2 y 3 completadas y verificadas.
- Leer `lib/features/auth/presentation/screens/user_profile_screen.dart` — se modificará para enlazar al hub.
- Leer `lib/core/router/app_router.dart` — se agregará la nueva ruta.
- Leer `lib/core/db/daos/auth_dao.dart` — método `getStaffAdminData` que provee datos para el resumen.
- Leer `lib/features/auth/presentation/screens/staff_management_screen.dart` — provider `staffAdminDataProvider`.

---

## Tarea 4.1 — Crear pantalla `AdminHubScreen`

### Contexto
Una pantalla central que muestra tarjetas con resúmenes y enlaces directos a cada sección administrativa. Solo accesible para usuarios con permisos administrativos.

### Archivo nuevo
`lib/features/auth/presentation/screens/admin_hub_screen.dart`

### Código completo

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inventario_v2/core/constants/permission_codes.dart';
import 'package:inventario_v2/core/db/models/auth_admin_models.dart';
import 'package:inventario_v2/core/providers/app_bar_provider.dart';
import 'package:inventario_v2/core/providers/drift_provider.dart';
import 'package:inventario_v2/features/auth/data/repositories/role_access_repository.dart';
import 'package:inventario_v2/features/auth/presentation/providers/auth_provider.dart';
import 'package:inventario_v2/features/auth/presentation/providers/authorization_provider.dart';

/// Provider que carga los datos necesarios para el hub de administración.
/// Reutiliza la misma lógica que staffAdminDataProvider.
final adminHubDataProvider =
    FutureProvider.autoDispose<StaffAdminDataDrift>((ref) async {
      final auth = ref.read(authControllerProvider.notifier);
      final user = auth.usuarioActual ?? await auth.getUser();
      if (user == null) {
        return const StaffAdminDataDrift(
          users: [],
          roles: [],
          warehouses: [],
          assignments: [],
        );
      }

      final db = ref.watch(driftDatabaseProvider);
      await RoleAccessRepository(db).ensureBaseRolesForUser(user);
      return db.authDao.getStaffAdminData(user.empresaId);
    });

class AdminHubScreen extends ConsumerStatefulWidget {
  const AdminHubScreen({super.key});

  @override
  ConsumerState<AdminHubScreen> createState() => _AdminHubScreenState();
}

class _AdminHubScreenState extends ConsumerState<AdminHubScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(appBarProvider.notifier).setOptions(
        title: 'Administración',
        subtitle: 'Panel de control del sistema',
        showBackButton: true,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final dataAsync = ref.watch(adminHubDataProvider);
    final authState = ref.watch(authorizationStateProvider).value;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: dataAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (data) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Resumen general ──
            _buildSummarySection(data),

            const SizedBox(height: 24),

            // ── Secciones de administración ──
            const Text(
              'Gestión',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            // Personal
            if (authState?.can(PermissionCode.staffRead) ?? false)
              _AdminCard(
                icon: Icons.groups_2_outlined,
                iconColor: Colors.blue,
                iconBgColor: Colors.blue.shade50,
                title: 'Personal',
                subtitle: '${data.users.length} usuarios registrados',
                description: 'Crear, editar y gestionar miembros del equipo. '
                    'Asignar roles y bodegas.',
                onTap: () => context.push('/staff-management'),
              ),

            // Roles y Permisos
            if (authState?.can(PermissionCode.roleRead) ?? false)
              _AdminCard(
                icon: Icons.admin_panel_settings_outlined,
                iconColor: Colors.purple,
                iconBgColor: Colors.purple.shade50,
                title: 'Roles y Permisos',
                subtitle: '${data.roles.length} roles configurados',
                description: 'Crear roles personalizados y asignar permisos '
                    'granulares por sección del sistema.',
                onTap: () => context.push('/role-management'),
              ),

            // Bodegas
            if (authState?.can(PermissionCode.warehouseRead) ?? false)
              _AdminCard(
                icon: Icons.warehouse_outlined,
                iconColor: Colors.teal,
                iconBgColor: Colors.teal.shade50,
                title: 'Bodegas',
                subtitle: '${data.warehouses.length} bodegas activas',
                description: 'Administrar bodegas, puntos de venta y '
                    'asignaciones de personal.',
                onTap: () => context.push('/warehouse'),
              ),

            const SizedBox(height: 24),

            // ── Herramientas del sistema ──
            const Text(
              'Sistema',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            // Sincronización
            _AdminCard(
              icon: Icons.cloud_sync_outlined,
              iconColor: Colors.cyan,
              iconBgColor: Colors.cyan.shade50,
              title: 'Sincronización',
              subtitle: 'Estado de la conexión con el servidor',
              description: 'Monitorear contadores locales, ver estado de sync '
                  'y diagnosticar problemas de conexión.',
              onTap: () => context.push('/sync-status'),
            ),

            // Logs
            if (authState?.isAdmin ?? false)
              _AdminCard(
                icon: Icons.bug_report_outlined,
                iconColor: Colors.orange,
                iconBgColor: Colors.orange.shade50,
                title: 'Registro del sistema',
                subtitle: 'Logs de actividad y errores',
                description: 'Ver el registro en vivo del sistema para '
                    'diagnosticar errores y monitorear operaciones.',
                onTap: () => context.push('/log-viewer'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummarySection(StaffAdminDataDrift data) {
    // Contar usuarios por estado
    final activeUsers = data.users.where((u) => u.estado).length;
    // Contar usuarios sin password_hash (pendientes de activación)
    final pendingUsers = data.users.where((u) => u.passwordHash == null).length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.cyan.shade700, Colors.cyan.shade900],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.dashboard_customize_outlined, color: Colors.white, size: 28),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Resumen del sistema',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _SummaryChip(
                icon: Icons.people_outline,
                label: '$activeUsers activos',
                sublabel: pendingUsers > 0 ? '$pendingUsers pendientes' : null,
              ),
              _SummaryChip(
                icon: Icons.verified_user_outlined,
                label: '${data.roles.length} roles',
              ),
              _SummaryChip(
                icon: Icons.warehouse_outlined,
                label: '${data.warehouses.length} bodegas',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Card de sección administrativa.
class _AdminCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String subtitle;
  final String description;
  final VoidCallback onTap;

  const _AdminCard({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: iconColor, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey.shade400,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Chip de resumen para el header.
class _SummaryChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? sublabel;

  const _SummaryChip({
    required this.icon,
    required this.label,
    this.sublabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 18),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              if (sublabel != null)
                Text(
                  sublabel!,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 11,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
```

### Notas de diseño
- Header con gradiente cyan que muestra el resumen.
- Cards de Material con InkWell para feedback táctil.
- Cada sección se muestra condicionada al permiso del usuario.
- Los logs solo son visibles si el usuario es admin (`authState.isAdmin`).
- El resumen muestra usuarios activos, pendientes de activación, roles y bodegas.

---

## Tarea 4.2 — Agregar ruta `/admin` al router

### Archivo a modificar
`lib/core/router/app_router.dart`

### Cambios exactos

1. **Agregar import:**
```dart
import '../../features/auth/presentation/screens/admin_hub_screen.dart';
```

2. **Agregar ruta** dentro del `ShellRoute > routes`, después de `/staff-management`:
```dart
GoRoute(
  path: '/admin',
  builder: (context, state) => const PermissionGuard(
    requiredPermission: PermissionCode.staffRead,
    child: AdminHubScreen(),
  ),
),
```

### Notas
- Se usa `staff.read` como permiso base porque el hub muestra información de personal.
- Si el usuario tiene `staff.read` puede ver el hub, pero solo verá las secciones para las que tenga permiso (la pantalla internamente filtra).
- Un usuario admin (`userAdmin: true`) siempre tiene todos los permisos.

---

## Tarea 4.3 — Actualizar el perfil para enlazar al Hub

### Contexto
Actualmente `UserProfileScreen` tiene cards individuales para "Sincronización" y "Gestión de Personal". Se debe reemplazar con un solo card de "Administración" que lleve al hub.

### Archivo a modificar
`lib/features/auth/presentation/screens/user_profile_screen.dart`

### Cambios exactos

1. **Reemplazar el card de "Gestión de Personal"** (actualmente líneas 88-121) y el card de "Roles y Permisos" (agregado en Fase 1) con un solo card de "Administración":

**Código nuevo (reemplaza ambos cards):**

```dart
// Card de Administración — visible solo si tiene al menos un permiso admin
Builder(
  builder: (context) {
    final authState = ref.watch(authorizationStateProvider).value;
    final canSeeAdmin = authState != null &&
        (authState.can(PermissionCode.staffRead) ||
         authState.can(PermissionCode.roleRead) ||
         authState.isAdmin);

    if (!canSeeAdmin) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: CustomCard(
        padding: const EdgeInsets.all(16),
        onTap: () => context.push('/admin'),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.cyan.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.settings_outlined, color: Colors.cyan.shade700, size: 28),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Administración",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Personal, roles, permisos, bodegas y herramientas del sistema",
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

2. **El card de "Sincronización"** (líneas 53-86) se puede mantener como acceso directo, o moverlo al hub. **Recomendación:** mantenerlo en el perfil ya que es una herramienta útil para todos los usuarios.

3. **El card de "Cambiar contraseña"** (agregado en Fase 1) se mantiene.

### Resultado final del perfil
El perfil debería mostrar (de arriba a abajo):
1. Avatar + Nombre + Correo
2. Card "Estado de Sincronización"
3. Card "Cambiar Contraseña" (Fase 1)
4. Card "Administración" (condicionado a permisos)
5. Botón "Cerrar Sesión"

---

## Checklist de verificación final — Fase 4

```bash
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

- [ ] La app compila sin errores.
- [ ] La ruta `/admin` navega correctamente.
- [ ] El hub muestra el resumen con números correctos.
- [ ] Cada sección solo aparece si el usuario tiene el permiso correspondiente.
- [ ] Al tocar cada card del hub, navega a la pantalla correcta.
- [ ] Un usuario sin permisos de admin no ve el card "Administración" en el perfil.
- [ ] Los logs del sistema solo son visibles para admins.
- [ ] El perfil muestra la estructura correcta de cards.

---

## Archivos modificados en esta fase

| Acción | Archivo | Líneas aprox. |
|---|---|---|
| NEW | `lib/features/auth/presentation/screens/admin_hub_screen.dart` | ~280 líneas |
| MODIFY | `lib/core/router/app_router.dart` | +8 líneas |
| MODIFY | `lib/features/auth/presentation/screens/user_profile_screen.dart` | ~30 líneas (reemplazar cards) |

**Total estimado:** ~320 líneas agregadas/modificadas.

---

## Resumen total del módulo completo (todas las fases)

| Fase | Archivos nuevos | Archivos modificados | Líneas aprox. |
|---|---|---|---|
| Fase 1 | 0 | 4 | ~205 |
| Fase 2 | 2 | 2 | ~230 |
| Fase 3 | 1 (Edge Function) | 2 | ~370 |
| Fase 4 | 1 | 2 | ~320 |
| **Total** | **4** | **~7 únicos** | **~1,125** |

### Archivos NO modificados (zonas sensibles protegidas)
- ✅ `lib/core/db/tables/auth_tables.dart` — Sin cambios
- ✅ `lib/core/db/app_database.dart` — Sin cambios ni migraciones
- ✅ `lib/core/repositories/sync_repository_drift.dart` — Sin cambios
- ✅ `.env` — Sin cambios
- ✅ Configuración de firma Android — Sin cambios
- ✅ Modelos de Drift — Sin cambios
