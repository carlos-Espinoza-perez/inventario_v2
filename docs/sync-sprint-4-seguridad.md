# Sprint 4 — Seguridad, RLS y Feedback de Sincronización en UI

**Prioridad:** 🟡 MENOR — Buenas prácticas y hardening post-lanzamiento  
**Esfuerzo estimado:** 3 días de desarrollo  
**Rama sugerida:** `feat/sync-sprint-4-security`  
**Prerequisito:** Sprints 1, 2 y 3 completados  
**Contexto:** Auditoría offline-first del 2026-06-26

---

## Objetivo

Auditar y endurecer las políticas de seguridad en Supabase (RLS), evaluar si las credenciales de usuario deben seguir sincronizándose, e implementar feedback visible en la UI cuando la sincronización falla persistentemente.

---

## Ítem 4.1 — Auditoría de Row Level Security (RLS) en Supabase

### Problema

El `_pull()` actual descarga cada tabla con:

```dart
final rows = await _supabase.from(remoteTableName).select();
```

Sin filtros explícitos en el código. La seguridad de que cada empresa solo descarga sus propios datos depende **exclusivamente** de las políticas RLS configuradas en Supabase. Si alguna tabla no tiene RLS habilitado o tiene una policy incorrecta, cualquier usuario autenticado podría descargar datos de otras empresas.

### Tablas de mayor riesgo

Las tablas que contienen datos sensibles de negocio y que deben estar filtradas por `empresa_id`:

| Tabla Supabase | Columna de filtro | Riesgo si no tiene RLS |
|---|---|---|
| `productos` | `empresa_id` | Catálogo de precios y costos de otras empresas |
| `inventario_producto` | `empresa_id` (via `productos`) | Stock de competidores |
| `ventas` | `empresa_id` | Historial de ventas completo |
| `detalle_venta` | `empresa_id` (via `ventas`) | Detalle de cada transacción |
| `clientes` | `empresa_id` | Base de clientes con datos personales |
| `usuarios` | `empresa_id` | Usuarios, roles, y credenciales |
| `caja_sesiones` | (via `cajas` → `empresa_id`) | Resúmenes financieros de caja |

### Procedimiento de auditoría

**Paso 1:** Ejecutar en Supabase Studio > SQL Editor:

```sql
-- Ver todas las policies existentes
SELECT
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual,
  with_check
FROM pg_policies
WHERE schemaname = 'public'
ORDER BY tablename, cmd;
```

**Paso 2:** Verificar que las tablas críticas tienen RLS habilitado:

```sql
-- Tablas sin RLS habilitado (potencialmente expuestas)
SELECT tablename
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename NOT IN (
    SELECT DISTINCT tablename FROM pg_policies WHERE schemaname = 'public'
  );
```

**Paso 3:** Para cada tabla con `empresa_id`, verificar que la política SELECT filtra por la empresa del usuario autenticado. El patrón correcto es:

```sql
-- Ejemplo para la tabla 'productos':
CREATE POLICY "usuarios solo ven productos de su empresa"
ON productos
FOR SELECT
USING (
  empresa_id = (
    SELECT u.empresa_id
    FROM usuarios u
    WHERE u.id = auth.uid()
    LIMIT 1
  )
);
```

**Paso 4:** Para tablas sin `empresa_id` directo (ej: `inventario_producto`, `detalle_venta`), la policy debe hacer join con la tabla padre:

```sql
-- Para inventario_producto (no tiene empresa_id propio):
CREATE POLICY "usuarios solo ven inventario de su empresa"
ON inventario_producto
FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM productos p
    JOIN usuarios u ON u.empresa_id = p.empresa_id
    WHERE p.id = inventario_producto.producto_id
      AND u.id = auth.uid()
  )
);
```

**Paso 5:** Verificar que también hay policies para INSERT, UPDATE y DELETE, no solo SELECT:

```sql
-- Política de escritura — ejemplo para 'ventas':
CREATE POLICY "usuarios solo insertan ventas de su empresa"
ON ventas
FOR INSERT
WITH CHECK (
  empresa_id = (
    SELECT u.empresa_id FROM usuarios u WHERE u.id = auth.uid()
  )
);
```

### Documentar resultado

Crear el archivo `docs/supabase_rls_audit.md` con el resultado de cada `SELECT` de auditoría, indicando para cada tabla:
- ✅ RLS habilitado y policy correcta
- ⚠️ RLS habilitado pero policy incompleta (solo SELECT, falta INSERT/UPDATE)
- 🔴 Sin RLS o con policy incorrecta

### Archivos a crear/modificar

- `docs/supabase_rls_audit.md` (resultado de la auditoría)
- Nuevas migraciones en `supabase/migrations/` para policies faltantes

### Cómo validar

1. Con un usuario de la Empresa A, intentar acceder vía API REST a registros de la Empresa B:
   ```bash
   curl -H "Authorization: Bearer <token_empresa_a>" \
     "https://[proyecto].supabase.co/rest/v1/ventas?empresa_id=eq.[uuid_empresa_b]"
   ```
2. Verificar que la respuesta es un array vacío `[]`, no los datos de la Empresa B.
3. Verificar que el usuario de Empresa A puede leer sus propias ventas sin problema.

---

## Ítem 4.2 — Evaluar si `password_hash` y `pin_offline` deben sincronizarse

### Problema

**Archivo:** `lib/core/repositories/sync_repository_drift.dart`  
**Método:** `_usuarioToJson` (línea ~1059)

```dart
Map<String, dynamic> _usuarioToJson(Usuario r) => {
  ...
  'password_hash': r.passwordHash,  // ← hash de contraseña a Supabase
  'pin_offline': r.pinOffline,      // ← PIN numérico en texto plano (¿o hash?)
  ...
};
```

Estos dos campos se sincronizan con Supabase. Los riesgos son:

1. **Si `password_hash` es SHA-256 o MD5 sin salt:** vulnerable a rainbow table attacks. La tabla `usuarios` en Supabase se convierte en un objetivo de alto valor.
2. **Si `pin_offline` está en texto plano:** cualquier acceso a la tabla (por bug en RLS, log en Supabase, etc.) expone todos los PINs.
3. **Redundancia con Supabase Auth:** si los usuarios se autentican vía Supabase Auth (email + password), el `password_hash` local es redundante y no debería existir en la capa de datos.

### Análisis de uso

Evaluar el flujo de autenticación real del proyecto respondiendo:

- ¿El login offline usa `password_hash` local para verificar credenciales sin conexión?
- ¿El `pin_offline` se usa para acciones rápidas (ej: confirmar una venta con PIN)?
- ¿Supabase Auth maneja el login principal, y `password_hash` es solo para offline?

### Solución según escenario

**Escenario A — `password_hash` solo es para verificación offline (recomendado mantener pero asegurar):**

```dart
// Verificar que el hash usa bcrypt con salt único por usuario
// Nunca enviar el hash a Supabase si Supabase Auth maneja la autenticación principal

Map<String, dynamic> _usuarioToJson(Usuario r) => {
  ...
  // 'password_hash': r.passwordHash,  ← NO sincronizar con Supabase
  'pin_offline': r.pinOffline,         // ← solo si está hasheado con bcrypt
  ...
};
```

**Escenario B — `pin_offline` en texto plano (debe corregirse):**

```dart
// En el DAO, antes de guardar el PIN:
import 'package:bcrypt/bcrypt.dart'; // o usar pointycastle

Future<void> guardarPinOffline(String userId, String pin) async {
  final hash = BCrypt.hashpw(pin, BCrypt.gensalt());
  await (update(usuarios)..where((u) => u.id.equals(userId)))
      .write(UsuariosCompanion(pinOffline: Value(hash)));
}

// Para verificar:
bool verificarPin(String pin, String storedHash) {
  return BCrypt.checkpw(pin, storedHash);
}
```

**Escenario C — Política de no sincronizar credenciales (más seguro):**

Eliminar `password_hash` y `pin_offline` del payload de push. Estas columnas solo existen localmente y se regeneran al hacer login con Supabase Auth.

### Archivos a modificar

- `lib/core/repositories/sync_repository_drift.dart` (eliminar o condicionar campos en `_usuarioToJson`)
- `lib/core/db/daos/auth_dao.dart` (si se añade hashing de PIN)

### Cómo validar

1. Verificar en Supabase Studio que la columna `password_hash` en `usuarios` tiene restricción de visibilidad vía RLS (`SELECT` solo para el propio usuario o para `service_role`).
2. Con la anon key, intentar leer `password_hash`: `GET /rest/v1/usuarios?select=password_hash` → debe devolver null o error.
3. Verificar que el login offline sigue funcionando después de eliminar `password_hash` del push.

---

## Ítem 4.3 — Feedback de sincronización persistente en la UI

### Problema

**Archivo:** `lib/features/sync/presentation/providers/sync_status_provider.dart`

El `SyncStatusReport` es un `FutureProvider` que solo se actualiza cuando el usuario navega a la pantalla de sync y llama `refreshStats()`. Si hay registros en `sync_error` o el sistema lleva horas sin sincronizar, el usuario no recibe ningún aviso.

Esto es especialmente problemático en el escenario donde:
- Una venta quedó en `pending_insert` por un error y el vendedor ya procesó otras 10 ventas creyendo que todo está bien.
- El inventario local tiene divergencia con el servidor pero el usuario no lo sabe.

### Solución: Banner global de estado de sync

#### Paso 1: Añadir `retryCount` y `pendingCount` al `SyncState`

```dart
// En auto_sync_provider.dart:

class SyncState {
  final bool isSyncing;
  final bool isOnline;
  final String? lastError;
  final DateTime? lastSync;
  final int retryCount;         // ← NUEVO
  final int pendingCount;       // ← NUEVO: registros pendientes de sync

  const SyncState({
    this.isSyncing = false,
    this.isOnline = true,
    this.lastError,
    this.lastSync,
    this.retryCount = 0,
    this.pendingCount = 0,
  });

  SyncState copyWith({
    bool? isSyncing,
    bool? isOnline,
    String? lastError,
    DateTime? lastSync,
    int? retryCount,
    int? pendingCount,
  }) => SyncState(
    isSyncing: isSyncing ?? this.isSyncing,
    isOnline: isOnline ?? this.isOnline,
    lastError: lastError,
    lastSync: lastSync ?? this.lastSync,
    retryCount: retryCount ?? this.retryCount,
    pendingCount: pendingCount ?? this.pendingCount,
  );

  bool get hasPendingData => pendingCount > 0;
  bool get hasError => lastError != null;
  bool get isCritical => !isOnline && pendingCount > 0;
}
```

#### Paso 2: Actualizar `pendingCount` después de cada push

```dart
// Al finalizar pushCambiosLocales, contar pendientes restantes:
Future<int> _countTotalPending() async {
  final tables = [
    'empresas', 'roles', 'accesos_rol', 'usuarios', 'bodegas',
    'categorias', 'productos', 'producto_variantes', 'inventarios',
    'clientes', 'movimientos', 'detalle_movimientos',
    'ventas', 'detalle_ventas', 'pagos_ventas',
    'cajas', 'caja_sesiones', 'caja_movimientos_extras',
  ];
  int total = 0;
  for (final table in tables) {
    final res = await _db.customSelect(
      "SELECT COUNT(*) as cnt FROM $table WHERE sync_status IN ('pending_insert','pending_update','sync_error')",
    ).getSingleOrNull();
    total += res?.read<int>('cnt') ?? 0;
  }
  return total;
}
```

#### Paso 3: Widget global de banner de sync

Crear `lib/core/presentation/widgets/sync_status_banner.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventario_v2/core/providers/auto_sync_provider.dart';

class SyncStatusBanner extends ConsumerWidget {
  const SyncStatusBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncAsync = ref.watch(autoSyncProvider);

    return syncAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (syncState) {
        if (syncState.isOnline && !syncState.hasPendingData && !syncState.hasError) {
          return const SizedBox.shrink(); // Todo OK, no mostrar nada
        }

        Color bannerColor;
        String message;
        IconData icon;

        if (!syncState.isOnline && syncState.hasPendingData) {
          bannerColor = Colors.orange.shade700;
          icon = Icons.cloud_off;
          message = 'Sin conexión — ${syncState.pendingCount} cambios pendientes de sincronizar';
        } else if (syncState.hasError) {
          bannerColor = Colors.red.shade700;
          icon = Icons.sync_problem;
          message = 'Error de sincronización — toca para reintentar';
        } else if (syncState.hasPendingData) {
          bannerColor = Colors.blue.shade700;
          icon = Icons.sync;
          message = '${syncState.pendingCount} registros pendientes de sincronizar';
        } else {
          return const SizedBox.shrink();
        }

        return Material(
          color: bannerColor,
          child: InkWell(
            onTap: syncState.hasError
                ? () => ref.read(autoSyncProvider.notifier).runFullSync()
                : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(icon, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      message,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                  if (syncState.hasError)
                    const Text(
                      'REINTENTAR',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
```

#### Paso 4: Integrar el banner en el layout principal

En el shell o scaffold principal de la app (buscar el widget raíz que contiene el `NavigationBar` o el `Drawer`), añadir el `SyncStatusBanner` como primer hijo de la columna principal:

```dart
// En el widget principal que envuelve toda la app:
Column(
  children: [
    const SyncStatusBanner(),   // ← AÑADIR al principio
    Expanded(child: _buildBody()),
  ],
)
```

### Archivos a crear/modificar

- `lib/core/presentation/widgets/sync_status_banner.dart` (nuevo)
- `lib/core/providers/auto_sync_provider.dart` (añadir `retryCount`, `pendingCount` a `SyncState`)
- `lib/core/repositories/sync_repository_drift.dart` (añadir `_countTotalPending`)
- Widget principal de la app (integrar el banner)

### Cómo validar

1. Crear registros offline (modo avión). Verificar que el banner naranja aparece con el conteo correcto.
2. Simular un error de sync. Verificar que el banner rojo aparece con botón "REINTENTAR".
3. Al reconectarse y sincronizar exitosamente, verificar que el banner desaparece.
4. Verificar que el banner no aparece durante el uso normal online sin pendientes.

---

## Ítem 4.4 — `referencia_venta_id` excluido de validación UUID sin documentación

### Problema

**Archivo:** `lib/core/repositories/sync_repository_drift.dart`  
**Método:** `_isValidPayload` (línea ~989)

```dart
bool _isValidPayload(Map<String, dynamic> json) {
  ...
  for (final entry in json.entries) {
    if (!entry.key.endsWith('_id') || entry.key == 'referencia_venta_id') {
      continue; // ← salta validación UUID para referencia_venta_id
    }
    ...
  }
}
```

`referencia_venta_id` se excluye de la validación UUID sin explicación. Si este campo contiene un valor no-UUID (ej: un texto libre o un número de referencia externo), pasará la validación y llegará a Supabase, donde podría fallar con error 23503 si hay una FK, o guardarse silenciosamente con un valor inválido.

### Solución

**Opción A (si `referencia_venta_id` puede ser null o vacío):** Mantener la exclusión pero añadir comentario:

```dart
// referencia_venta_id es un campo opcional que puede contener
// referencias externas no-UUID (ej: número de transacción bancaria)
if (!entry.key.endsWith('_id') || entry.key == 'referencia_venta_id') {
  continue;
}
```

**Opción B (si siempre debe ser UUID o null):** Eliminar la exclusión para que pase por la validación normal.

**Opción C (si puede ser UUID válido o null, pero no texto libre):** Validar que sea UUID O null:

```dart
if (entry.key == 'referencia_venta_id') {
  final value = entry.value?.toString();
  if (value != null && value.isNotEmpty && !UuidValidator.isValidUUID(value)) {
    return false; // referencia_venta_id debe ser UUID o null
  }
  continue;
}
```

Confirmar con el equipo cuál es el uso real de `referencia_venta_id` y aplicar la opción correspondiente.

### Archivos a modificar

- `lib/core/repositories/sync_repository_drift.dart`

---

## Ítem 4.5 — Valores desconocidos de `tipo_movimiento` pasan sin error explícito

### Problema

**Archivo:** `lib/core/repositories/sync_repository_drift.dart`  
**Método:** `_tipoMovimientoToRemote` (línea ~1229)

```dart
String _tipoMovimientoToRemote(String value) {
  final normalized = value.trim().toLowerCase();
  return switch (normalized) {
    'entrada' => 'compra',
    'salida' => 'ajuste',
    'traslado' => 'traslado',
    'ajuste' => 'ajuste',
    'compra' => 'compra',
    _ => normalized, // ← valor desconocido pasa al servidor sin alerta
  };
}
```

Si se añade un nuevo `tipo_movimiento` localmente (ej: `'devolucion'`) sin actualizar el mapeo, el valor llega al servidor como `'devolucion'`. Si el servidor tiene un `CHECK` constraint que no incluye ese valor, el upsert falla con `sync_error` sin un mensaje claro del porqué.

### Solución

Añadir logging explícito y considerar fallo temprano:

```dart
String _tipoMovimientoToRemote(String value) {
  final normalized = value.trim().toLowerCase();
  return switch (normalized) {
    'entrada'  => 'compra',
    'salida'   => 'ajuste',
    'traslado' => 'traslado',
    'ajuste'   => 'ajuste',
    'compra'   => 'compra',
    _ => () {
      // ⚠️ Valor no mapeado — puede fallar en Supabase si tiene CHECK constraint
      AppLogger.warn(
        '[Sync] tipo_movimiento desconocido en push: "$normalized". '
        'Actualizar _tipoMovimientoToRemote si el servidor acepta este valor.',
      );
      return normalized;
    }(),
  };
}
```

### Archivos a modificar

- `lib/core/repositories/sync_repository_drift.dart`

---

## Checklist de cierre del Sprint 4

- [ ] 4.1 — Auditoría RLS ejecutada y documentada en `docs/supabase_rls_audit.md`
- [ ] 4.1 — Políticas faltantes o incorrectas corregidas con migraciones
- [ ] 4.1 — Test cross-tenant: usuario Empresa A no puede leer datos de Empresa B
- [ ] 4.2 — Decisión documentada sobre `password_hash` y `pin_offline` (sincronizar o no)
- [ ] 4.2 — Si se mantiene `pin_offline`, verificar que esté hasheado con bcrypt
- [ ] 4.3 — `SyncState` tiene `retryCount` y `pendingCount`
- [ ] 4.3 — `SyncStatusBanner` implementado y visible en el layout principal
- [ ] 4.3 — Banner desaparece cuando sync está OK, aparece con el estado correcto
- [ ] 4.4 — `referencia_venta_id` documentado o validación corregida
- [ ] 4.5 — `AppLogger.warn` en caso default de `_tipoMovimientoToRemote`
- [ ] Review de seguridad final por otro miembro del equipo antes de merge
