# Sprint 1 — Correcciones Críticas de Sincronización

**Prioridad:** 🔴 BLOQUEANTE — No lanzar a producción sin completar este sprint  
**Esfuerzo estimado:** 3 días de desarrollo  
**Rama sugerida:** `fix/sync-sprint-1-critical`  
**Contexto:** Hallazgos de la auditoría offline-first realizada el 2026-06-26 sobre la rama `feat/audit-pre-beta`

---

## Objetivo

Eliminar los escenarios que causan pérdida irreversible de datos, corrupción de la base de datos local SQLite, e inconsistencias de ventas entre dispositivos de la misma empresa.

---

## Ítem 1.1 — SQL Injection en creación de entidades fantasma

### Problema

**Archivo:** `lib/core/repositories/sync_repository_drift.dart`  
**Métodos:** `_createGhostUsersIfMissing` (líneas ~824–843) y `_createGhostProductsIfMissing` (líneas ~858–978)

Los valores `userId`, `ventaId`, `categoriaId`, `bodegaId`, `productoId` y `varianteId` provienen directamente de `payload.newRecord` de Supabase Realtime. Se interpolan sin validación en strings SQL raw:

```dart
// ❌ VULNERABLE — interpolación directa de dato externo
await _db.customSelect(
  "SELECT 1 FROM usuarios WHERE id = '$userId' LIMIT 1"
);
await _db.customStatement(
  "INSERT INTO usuarios (...) VALUES ('$userId', ..., 'eliminado_$userId@sistema.local', ...)"
);
```

Si un payload llega con un `id` malformado (ej: `', 1); DROP TABLE ventas; --`), se ejecuta SQL arbitrario sobre la base de datos SQLite local del dispositivo.

La función `_isValidPayload()` **no aplica** en este flujo — solo aplica al push hacia Supabase, nunca a los datos entrantes del Realtime.

### Solución

**Paso 1:** Añadir validación de UUID al inicio de `_createGhostUsersIfMissing` y `_createGhostProductsIfMissing`, antes de cualquier operación de base de datos:

```dart
// En _createGhostUsersIfMissing — antes del loop:
for (final field in possibleUserFields) {
  final userId = map[field]?.toString();
  if (userId == null || userId.isEmpty) continue;
  if (!UuidValidator.isValidUUID(userId)) {          // ← AÑADIR
    AppLogger.warn('[Sync] Ghost: UUID inválido en campo $field: $userId');
    continue;
  }
  // ... resto del código
}
```

**Paso 2:** Reemplazar TODA interpolación de string en SQL raw por parámetros posicionales con `Variable.withString()`:

```dart
// ❌ Antes:
await _db.customSelect(
  "SELECT 1 FROM usuarios WHERE id = '$userId' LIMIT 1"
);

// ✅ Después:
await _db.customSelect(
  "SELECT 1 FROM usuarios WHERE id = ? LIMIT 1",
  variables: [Variable.withString(userId)],
).getSingleOrNull();
```

```dart
// ❌ Antes:
await _db.customStatement(
  "INSERT INTO usuarios (...) VALUES ('$userId', ..., 'eliminado_$userId@sistema.local', ...)"
);

// ✅ Después:
await _db.customStatement(
  "INSERT INTO usuarios (id, ..., correo, ...) VALUES (?, ..., ?, ...)",
  [userId, ..., 'eliminado_$userId@sistema.local', ...],
);
// Nota: la interpolación 'eliminado_$userId@sistema.local' en el VALUE es segura
// si userId ya fue validado como UUID en el paso anterior. De todas formas,
// para máxima seguridad, pasarla también como parámetro posicional.
```

**Paso 3:** Aplicar el mismo patrón a los `SELECT 1 FROM ...` de `_createGhostProductsIfMissing` para `ventaId`, `categoriaId`, `bodegaId`, `productoId` y `varianteId`.

### Archivos a modificar

- `lib/core/repositories/sync_repository_drift.dart`

### Cómo validar

1. Crear un payload falso con `id = "', 1); UPDATE productos SET nombre = 'HACKEADO' WHERE 1=1; --"`.
2. Llamar `_createGhostEntitiesIfMissing` con ese mapa.
3. Verificar que el log muestre `[Sync] Ghost: UUID inválido` y que ninguna tabla sea modificada.
4. Verificar que el flujo normal de Realtime (con UUIDs válidos) siga creando fantasmas correctamente.

---

## Ítem 1.2 — Nombre inconsistente de columna `metodo_pago` en `pagos_ventas`

### Problema

**Archivo:** `lib/core/repositories/sync_repository_drift.dart`  
**Métodos:** `_pagoVentaToJson` (línea ~1313) y `_pagoVentaFromJson` (línea ~1657)

El push envía el campo con un nombre, el pull lo recibe con otro:

```dart
// Push (_pagoVentaToJson):
'metodo_pago': r.metodoPago,          // ← envía como 'metodo_pago'

// Pull (_pagoVentaFromJson):
metodoPago: _text(j['metodo_de_pago']) ?? _text(j['metodo_pago']) ?? 'efectivo',
//           ↑ busca primero 'metodo_de_pago'
```

Si el servidor almacena la columna como `metodo_de_pago`, los pagos subidos desde el app llegan con `metodo_pago` (nombre incorrecto), el servidor los ignora o los guarda en la columna equivocada, y al hacer pull el valor llega como `null` → se asigna `'efectivo'` por defecto, borrando el método de pago real.

### Solución

**Paso 1:** Verificar en Supabase Studio (`Table Editor → pagos_ventas`) el nombre exacto de la columna del método de pago.

**Paso 2 (si el remoto usa `metodo_de_pago`):**
```dart
// ✅ Unificar push para usar el nombre correcto del servidor:
Map<String, dynamic> _pagoVentaToJson(PagosVenta r) => {
  ..._syncMap(r.id, r.createdAt, r.updatedAt, r.syncStatus),
  'venta_id': r.ventaId,
  'caja_sesion_id': r.cajaSesionId,
  'monto_pagado': r.montoPagado,
  'metodo_de_pago': r.metodoPago,       // ← corregido
  'referencia': r.referencia,
  // ...
};
```

**Paso 3 (si el remoto usa `metodo_pago`):** eliminar el fallback extra en el fromJson y dejar solo `_text(j['metodo_pago'])`.

### Archivos a modificar

- `lib/core/repositories/sync_repository_drift.dart`

### Cómo validar

1. Crear una venta offline con pago en `transferencia`.
2. Sincronizar.
3. Verificar en Supabase Studio que la fila en `pagos_ventas` tenga `metodo_de_pago = 'transferencia'` (o el nombre correcto).
4. Eliminar datos locales y re-sincronizar (pull).
5. Verificar que el método de pago local sea `'transferencia'`, no `'efectivo'`.

---

## Ítem 1.3 — Colisión de `fecha_registro` en `pagos_ventas`

### Problema

**Archivo:** `lib/core/repositories/sync_repository_drift.dart`  
**Método:** `_pagoVentaToJson` (línea ~1309)

La tabla `PagosVentas` tiene **dos** campos de fecha con semánticas distintas:

| Campo local | Significado |
|---|---|
| `createdAt` | Timestamp técnico de creación del registro |
| `fechaRegistro` | Fecha real en que se registró el pago (la que importa para reportes) |

El helper `_syncMap()` siempre incluye `'fecha_registro': createdAt.toIso8601String()`. Esto sobreescribe la fecha real del pago con el timestamp técnico. En el pull, el fromJson usa:

```dart
fechaRegistro: _date(j['fecha_registro_pago'] ?? j['fecha_registro']),
```

Si el servidor solo tiene `fecha_registro`, siempre se asigna `createdAt` como fecha del pago, perdiendo la fecha real del evento financiero.

### Solución

Enviar la fecha real del pago en un campo separado en el JSON de push:

```dart
Map<String, dynamic> _pagoVentaToJson(PagosVenta r) {
  final map = {
    ..._syncMap(r.id, r.createdAt, r.updatedAt, r.syncStatus),
    // fecha_registro del _syncMap = createdAt (timestamp técnico, OK)
    'venta_id': r.ventaId,
    'caja_sesion_id': r.cajaSesionId,
    'monto_pagado': r.montoPagado,
    'metodo_pago': r.metodoPago,           // (o 'metodo_de_pago' según 1.2)
    'referencia': r.referencia,
    'usuario_registro_id': r.usuarioRegistroId,
    'estado': r.estado,
    'fecha_eliminacion': r.fechaEliminacion?.toIso8601String(),
    'fecha_registro_pago': r.fechaRegistro.toIso8601String(),  // ← AÑADIR campo específico
  };
  return map;
}
```

Si la columna `fecha_registro_pago` no existe en el servidor, coordinar con el DBA para añadirla o confirmar que `fecha_registro` es suficiente y documentarlo explícitamente.

### Archivos a modificar

- `lib/core/repositories/sync_repository_drift.dart`
- (Posiblemente) nueva migración Supabase si se requiere la columna `fecha_registro_pago`

### Cómo validar

1. Registrar un pago offline a las 10:00.
2. Sincronizar a las 10:05 (los 5 minutos hacen visible la diferencia entre `createdAt` y `fechaRegistro`).
3. Verificar en Supabase que `fecha_registro_pago` sea 10:00, no 10:05.
4. Hacer pull en otro dispositivo y verificar que `fechaRegistro` local sea 10:00.

---

## Ítem 1.4 — `bodega_default_id` del usuario nunca se sincroniza

### Problema

**Archivo:** `lib/core/repositories/sync_repository_drift.dart`  
**Métodos:** `_usuarioToJson` (línea ~1059) y `_usuarioFromJson` (línea ~1365)

La tabla local `Usuarios` tiene la columna `bodegaDefaultId` que determina en qué bodega opera el usuario por defecto. Esta columna **nunca se incluye** en el push ni en el pull:

```dart
// Push (_usuarioToJson) — no incluye bodega_default_id
Map<String, dynamic> _usuarioToJson(Usuario r) => {
  ..._syncMap(...),
  'empresa_id': r.empresaId,
  'rol_id': r.rolId,
  // ← FALTA 'bodega_default_id': r.bodegaDefaultId,
  ...
};

// Pull (_usuarioFromJson) — hardcodeado como null
UsuariosCompanion _usuarioFromJson(Map<String, dynamic> j) =>
    UsuariosCompanion.insert(
      ...
      bodegaDefaultId: const Value(null),   // ← NUNCA se lee del servidor
      ...
    );
```

Si un administrador asigna una bodega por defecto a un usuario en el panel web o en otro dispositivo, ese cambio **nunca llega** al dispositivo del usuario.

### Solución

```dart
// ✅ Push — añadir campo:
Map<String, dynamic> _usuarioToJson(Usuario r) => {
  ..._syncMap(r.id, r.createdAt, r.updatedAt, r.syncStatus),
  'empresa_id': r.empresaId,
  'rol_id': r.rolId,
  'nombre_completo': r.nombreCompleto,
  'correo': r.correo,
  'password_hash': r.passwordHash,
  'pin_offline': r.pinOffline,
  'bodega_default_id': r.bodegaDefaultId,   // ← AÑADIR
  'usuario_registro_id': r.usuarioRegistroId,
  'estado': r.estado,
  'fecha_eliminacion': r.fechaEliminacion?.toIso8601String(),
};

// ✅ Pull — leer del servidor:
UsuariosCompanion _usuarioFromJson(Map<String, dynamic> j) =>
    UsuariosCompanion.insert(
      ...
      bodegaDefaultId: Value(_text(j['bodega_default_id'])),  // ← CORREGIR
      ...
    );
```

**Nota:** Verificar que la columna `bodega_default_id` exista en la tabla `usuarios` de Supabase. Si no existe, crear la migración correspondiente antes de activar el push.

### Archivos a modificar

- `lib/core/repositories/sync_repository_drift.dart`
- (Si aplica) nueva migración Supabase: `ALTER TABLE usuarios ADD COLUMN IF NOT EXISTS bodega_default_id UUID REFERENCES bodegas(id) ON DELETE SET NULL;`

### Cómo validar

1. En Supabase Studio, actualizar `bodega_default_id` de un usuario.
2. Hacer pull en el dispositivo.
3. Verificar que `usuario.bodegaDefaultId` local tenga el UUID de la bodega asignada.
4. En el app, cambiar la bodega por defecto del usuario.
5. Hacer push y verificar en Supabase Studio que el campo se actualizó.

---

## Ítem 1.5 — Venta padre marcada `synced` antes de sincronizar sus detalles

### Problema

**Archivo:** `lib/core/repositories/sync_repository_drift.dart`  
**Método:** `pushCambiosLocales` (líneas 122–133)

El push de ventas y sus detalles ocurre secuencialmente pero de forma independiente:

```dart
await _push('venta_producto', 'ventas', await _db.salesDao.getPendingVentas(), ...);
// ↑ Si esto tiene éxito, 'ventas' queda en sync_status = 'synced'

await _push('detalle_venta', 'detalle_ventas', await _db.salesDao.getPendingDetalleVentas(), ...);
// ↑ Si la red falla aquí, 'detalle_ventas' queda 'pending_insert'
//   pero la venta padre ya está 'synced' y no se reintentará
```

**Consecuencia:** Supabase tiene ventas sin líneas de detalle. Cualquier dispositivo que haga pull de esa empresa verá ventas con total ≠ suma de líneas, o líneas que apuntan a una venta vacía.

El mismo problema aplica a `movimientos` → `detalle_movimientos`.

### Solución

**Estrategia:** Implementar una función de push coordinado que marque el padre como `synced` solo si los hijos también sincronizaron exitosamente.

```dart
/// Sube ventas y sus detalles de forma coordinada.
/// Si el detalle_venta de una venta falla, revierte el sync_status
/// de la venta padre a 'pending_update' para que se reintente.
Future<void> _pushVentasCoordinado() async {
  final pendingVentas = await _db.salesDao.getPendingVentas();
  if (pendingVentas.isEmpty) return;

  // 1. Subir ventas normalmente
  await _push('venta_producto', 'ventas', pendingVentas, _ventaToJson);

  // 2. Subir detalles
  final pendingDetalles = await _db.salesDao.getPendingDetalleVentas();
  if (pendingDetalles.isEmpty) return;

  // Agrupar detalles por venta para poder revertir por padre
  final detallesPorVenta = <String, List<DetalleVenta>>{};
  for (final d in pendingDetalles) {
    detallesPorVenta.putIfAbsent(d.ventaId, () => []).add(d);
  }

  for (final entry in detallesPorVenta.entries) {
    final ventaId = entry.key;
    final detalles = entry.value;
    try {
      final payloads = detalles.map(_detalleVentaToJson).toList();
      await _supabase.from('detalle_venta').upsert(payloads);
      await _markSynced('detalle_ventas', detalles.map((d) => d.id).toList());
    } catch (e) {
      // Si fallan los detalles, revertir la venta padre para que se reintente
      AppLogger.warn('[Sync] Detalles de venta $ventaId fallaron. Revirtiendo padre.');
      await _db.customStatement(
        "UPDATE ventas SET sync_status = 'pending_update' WHERE id = ?",
        [ventaId],
      );
      await _markSyncError('detalle_ventas', detalles.map((d) => d.id).toList(), e.toString());
    }
  }
}
```

Reemplazar las dos llamadas `_push('venta_producto', ...)` y `_push('detalle_venta', ...)` en `pushCambiosLocales` por `await _pushVentasCoordinado()`.

Aplicar el mismo patrón para `movimientos` + `detalle_movimientos`.

### Archivos a modificar

- `lib/core/repositories/sync_repository_drift.dart`
- `lib/core/db/daos/sales_dao.dart` (si se necesita un método `getPendingDetalleVentasByVentaId`)

### Cómo validar

1. Crear una venta offline con 3 líneas de detalle.
2. Interceptar la red (modo avión) justo después del primer push de `ventas` y antes del push de `detalle_ventas` (simular con breakpoint en `_pushVentasCoordinado`).
3. Al reconectarse, verificar que la venta quede en `pending_update` (no `synced`) hasta que sus detalles también suban.
4. Verificar en Supabase Studio que la venta y sus 3 detalles aparecen juntos después del reintento.

---

## Checklist de cierre del Sprint 1

- [x] 1.1 — SQL Injection: validación UUID + parámetros posicionales en ghost entities
- [x] 1.2 — Columna `metodo_pago` / `metodo_de_pago` unificada
- [x] 1.3 — `fecha_registro_pago` enviado correctamente en push de pagos
- [x] 1.4 — `bodega_default_id` incluido en push y pull de usuarios
- [x] 1.5 — Push coordinado venta + detalle_venta (y movimiento + detalle_movimiento)
- [ ] Prueba de regresión: sincronización completa con dataset de prueba antes y después
- [ ] Code review de los cambios antes de merge a `main`
