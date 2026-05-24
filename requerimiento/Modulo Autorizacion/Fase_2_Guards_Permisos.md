# Fase 2 — Guards de Permisos en Rutas y UI

## Objetivo

Implementar protección real de acceso basada en permisos del rol del usuario. Todas las vistas del sistema deben validar que el usuario tenga el permiso correspondiente antes de mostrar contenido. Si no tiene permiso, se muestra una pantalla dedicada de "Sin permisos".

**Riesgo:** 🟡 Medio  
**Archivos a modificar:** 3  
**Archivos nuevos:** 2  
**Esfuerzo estimado:** ~6 horas

**Depende de:** Fase 1 completada (la ruta `/role-management` debe existir).

---

## Prerequisitos

- Fase 1 completada y verificada.
- Leer `lib/core/constants/permission_codes.dart` — contiene los 37 códigos de permisos organizados en 8 secciones.
- Leer `lib/features/auth/presentation/providers/authorization_provider.dart` — contiene `AuthorizationState` con método `can(permission)`.
- Leer `lib/core/router/app_router.dart` — entender la estructura de rutas con `ShellRoute`.

---

## Tarea 2.1 — Crear widget `PermissionGuard`

### Contexto
Se necesita un widget reutilizable que envuelva cualquier pantalla y valide si el usuario tiene el permiso necesario. Si no lo tiene, muestra la pantalla de acceso denegado.

### Archivo nuevo
`lib/core/router/permission_guard.dart`

### Código completo

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventario_v2/features/auth/presentation/providers/authorization_provider.dart';
import 'package:inventario_v2/features/auth/presentation/screens/access_denied_screen.dart';

/// Widget que protege una pantalla verificando que el usuario tenga
/// el permiso requerido. Si no lo tiene, muestra AccessDeniedScreen.
///
/// Uso:
/// ```dart
/// GoRoute(
///   path: '/staff-management',
///   builder: (context, state) => const PermissionGuard(
///     requiredPermission: PermissionCode.staffRead,
///     child: StaffManagementScreen(),
///   ),
/// ),
/// ```
class PermissionGuard extends ConsumerWidget {
  /// El código de permiso requerido para acceder a esta pantalla.
  /// Debe ser uno de los valores de `PermissionCode`.
  final String requiredPermission;

  /// La pantalla que se mostrará si el usuario tiene el permiso.
  final Widget child;

  const PermissionGuard({
    super.key,
    required this.requiredPermission,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authStateAsync = ref.watch(authorizationStateProvider);

    return authStateAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => AccessDeniedScreen(
        message: 'Error al verificar permisos: $error',
      ),
      data: (authState) {
        if (authState.can(requiredPermission)) {
          return child;
        }
        return const AccessDeniedScreen();
      },
    );
  }
}
```

### Notas de diseño
- Se usa `ConsumerWidget` para acceder al `authorizationStateProvider`.
- El método `can()` de `AuthorizationState` ya maneja la lógica de admin (retorna `true` para todo si es admin).
- Mientras se carga el estado de autorización, se muestra un `CircularProgressIndicator`.
- Si hay error al cargar permisos, se muestra la pantalla de acceso denegado con el mensaje de error.

---

## Tarea 2.2 — Crear pantalla `AccessDeniedScreen`

### Contexto
Pantalla dedicada que se muestra cuando un usuario intenta acceder a una vista para la cual no tiene permiso. Debe ser amigable, clara y tener un botón para regresar.

### Archivo nuevo
`lib/features/auth/presentation/screens/access_denied_screen.dart`

### Código completo

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Pantalla que se muestra cuando el usuario no tiene permiso
/// para acceder a una sección del sistema.
class AccessDeniedScreen extends StatelessWidget {
  /// Mensaje personalizado opcional. Si no se proporciona, usa el mensaje por defecto.
  final String? message;

  const AccessDeniedScreen({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lock_outline_rounded,
                  size: 64,
                  color: Colors.red.shade400,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Acceso restringido',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                message ??
                    'No tienes permisos para acceder a esta sección.\n\n'
                    'Contacta a un administrador si necesitas acceso.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/dashboard');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyan.shade800,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text(
                    'Volver',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### Comportamiento
- Ícono de candado con fondo rojo suave.
- Título "Acceso restringido".
- Mensaje explicativo.
- Botón "Volver" que regresa a la pantalla anterior (o al dashboard si no hay historial).
- Estilo visual consistente con el resto de la app (colores cyan, bordes redondeados).

---

## Tarea 2.3 — Envolver rutas con `PermissionGuard` en el router

### Contexto
Se deben proteger todas las rutas del `ShellRoute` con el guard de permisos correspondiente.

### Archivo a modificar
`lib/core/router/app_router.dart`

### Cambios exactos

1. **Agregar imports** al inicio:
```dart
import '../../core/router/permission_guard.dart';
import '../../core/constants/permission_codes.dart';
```

2. **Envolver cada ruta del ShellRoute** con `PermissionGuard`. A continuación el mapa completo de qué permiso requiere cada ruta:

| Ruta | Permiso | Notas |
|---|---|---|
| `/dashboard` | `dashboard.read` | Siempre accesible (es el fallback) |
| `/profile` | — | Sin guard (es su propio perfil) |
| `/staff-management` | `staff.read` | Solo admin/con permiso |
| `/role-management` | `role.read` | Solo admin/con permiso |
| `/sync-status` | — | Sin guard (herramienta técnica) |
| `/log-viewer` | — | Sin guard (herramienta técnica) |
| `/warehouse` | `warehouse.read` | |
| `/warehouse-create` | `warehouse.create` | |
| `/warehouse-inventory/:warehouseId` | `warehouse.read` | |
| `/warehouse-history/:warehouseId` | `warehouse.read` | |
| `/movement-detail/:movementId` | `warehouse.read` | |
| `/product-detail/:productId` | `product.read` | |
| `/product-create` | `product.create` | |
| `/magic-camera` | `product.create` | |
| `/barcode-scanner` | `warehouse.read` | |
| `/batch-entry/:bodegaId` | `warehouse.update` | |
| `/warehouse-transfer/:bodegaId` | `warehouse.update` | |
| `/product-list` | `product.read` | |
| `/pos` | `sale.create` | |
| `/sales` | `sale.read` | |
| `/sales-detail/:saleId` | `sale.read` | |
| `/cash-register` | `sale.create` | |
| `/cash-register-history` | `sale.read` | |
| `/cash-register-detail/:sessionId` | `sale.read` | |
| `/assistant` | `dashboard.read` | Acceso general |
| `/reports` | `report.read` | |
| `/reports/sales` | `report.read` | |
| `/reports/inventory` | `report.read` | |
| `/reports/financial` | `report.read` | |
| `/reports/receivables` | `report.read` | |
| `/reports/cash-history` | `report.read` | |

3. **Ejemplo de cómo envolver una ruta:**

**Antes:**
```dart
GoRoute(
  path: '/staff-management',
  builder: (context, state) => const StaffManagementScreen(),
),
```

**Después:**
```dart
GoRoute(
  path: '/staff-management',
  builder: (context, state) => const PermissionGuard(
    requiredPermission: PermissionCode.staffRead,
    child: StaffManagementScreen(),
  ),
),
```

4. **Rutas que NO se envuelven** (acceso siempre permitido si está autenticado):
- `/dashboard` — Es el punto de entrada, siempre accesible.
- `/profile` — El usuario siempre puede ver su propio perfil.
- `/sync-status` — Herramienta técnica.
- `/log-viewer` — Herramienta técnica.

### Validación
- Un usuario con rol "Operador" (permisos limitados) no debe poder acceder a `/staff-management`.
- Al intentar navegar a una ruta protegida sin permiso, se debe ver la pantalla de "Acceso restringido".
- Un usuario con rol "Administrador" debe poder acceder a todas las rutas.
- La navegación entre rutas permitidas funciona normalmente.

---

## Tarea 2.4 — Ocultar items del bottom bar sin permiso

### Contexto
Además de proteger las rutas, se deben ocultar los items del menú inferior para los que el usuario no tenga permiso. Esto mejora la experiencia evitando que el usuario intente navegar a algo que no puede ver.

### Archivo a modificar
Se debe localizar el widget del bottom navigation bar. Según el código analizado, está en:
`lib/features/dashboard/presentation/widgets/bottom_app_bar_dashboard.dart`

### Cambios requeridos

1. **Importar los providers necesarios:**
```dart
import 'package:inventario_v2/features/auth/presentation/providers/authorization_provider.dart';
import 'package:inventario_v2/core/constants/permission_codes.dart';
```

2. **Convertir el widget a `ConsumerWidget`** (si no lo es ya) para acceder a `ref.watch`.

3. **Para cada item del bottom bar, verificar permiso antes de mostrarlo:**

```dart
final authState = ref.watch(authorizationStateProvider).value;

// Ejemplo: Solo mostrar el botón de ventas si tiene permiso
if (authState?.can(PermissionCode.saleRead) ?? false)
  // mostrar item de ventas
```

4. **Mapa de items del menú ↔ permisos:**

| Item del menú | Permiso requerido |
|---|---|
| Bodegas / Inventario | `warehouse.read` |
| Ventas / POS | `sale.read` |
| Reportes | `report.read` |
| Asistente | `dashboard.read` (siempre visible) |

### Notas importantes
- **No eliminar el item completamente**, solo ocultarlo con una condición.
- Si el item está oculto y el usuario tiene pocos permisos, el bottom bar podría quedar con pocos items, lo cual es correcto.
- El botón de Home (FloatingActionButton central) siempre debe estar visible.
- Si el usuario es admin (`authState.isAdmin`), todos los items deben ser visibles.

### Validación
- Un operador con solo permisos de `warehouse.read` y `sale.read` no debe ver el item de "Reportes".
- Un admin debe ver todos los items.
- Los items visibles deben funcionar normalmente al tocarse.

---

## Checklist de verificación final — Fase 2

```bash
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

- [ ] La app compila sin errores.
- [ ] `PermissionGuard` muestra la pantalla protegida si tiene permiso.
- [ ] `PermissionGuard` muestra `AccessDeniedScreen` si no tiene permiso.
- [ ] `AccessDeniedScreen` se ve correctamente y el botón "Volver" funciona.
- [ ] Todas las rutas protegidas validan permiso.
- [ ] Las rutas no protegidas (`/dashboard`, `/profile`) siguen funcionando.
- [ ] El bottom bar oculta items sin permiso.
- [ ] Un usuario admin ve todo sin restricciones.
- [ ] Un usuario operador ve solo lo que su rol permite.

---

## Archivos modificados en esta fase

| Acción | Archivo | Líneas aprox. |
|---|---|---|
| NEW | `lib/core/router/permission_guard.dart` | ~50 líneas |
| NEW | `lib/features/auth/presentation/screens/access_denied_screen.dart` | ~90 líneas |
| MODIFY | `lib/core/router/app_router.dart` | ~60 líneas (envolver ~25 rutas) |
| MODIFY | `lib/features/dashboard/presentation/widgets/bottom_app_bar_dashboard.dart` | ~30 líneas |

**Total estimado:** ~230 líneas agregadas/modificadas.

---

## Diagrama de flujo del guard

```
Usuario navega a /staff-management
        │
        ▼
┌─────────────────────┐
│   PermissionGuard   │
│ required: staff.read│
└─────────┬───────────┘
          │
          ▼
┌───────────────────┐
│ authorizationState│
│    .can('staff.   │
│      read')       │
└─────────┬─────────┘
          │
    ┌─────┴─────┐
    │           │
   true       false
    │           │
    ▼           ▼
┌────────┐  ┌──────────────┐
│ Staff  │  │ AccessDenied │
│ Screen │  │   Screen     │
└────────┘  └──────────────┘
```
