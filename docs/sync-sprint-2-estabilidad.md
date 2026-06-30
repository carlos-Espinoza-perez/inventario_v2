# Sprint 2 — Estabilidad de Sincronización y Datos Faltantes

**Prioridad:** 🟠 MAYOR — Completar antes del lanzamiento  
**Esfuerzo estimado:** 4 días de desarrollo  
**Rama sugerida:** `fix/sync-sprint-2-stability`  
**Prerequisito:** Sprint 1 completado y mergeado  
**Contexto:** Auditoría offline-first del 2026-06-26

---

## Objetivo

Corregir inconsistencias silenciosas en datos ya sincronizados, pérdidas de campos al hacer pull, y condiciones de carrera que generan duplicados o estados rotos en la cola de sync.

---

## Ítem 2.1 — Mapeo inverso incompleto de `tipo_movimiento`

### Problema

**Archivo:** `lib/core/repositories/sync_repository_drift.dart`  
**Métodos:** `_tipoMovimientoToRemote` (línea ~1229) y `_tipoMovimientoFromRemote` (línea ~1241)

El mapeo entre valores locales y remotos es asimétrico. Al subir a Supabase (`ToRemote`) se transforma:
```
'salida'  → 'ajuste'
'entrada' → 'compra'
```

Al bajar de Supabase (`FromRemote`) se des-transforma solo:
```
'compra' → 'entrada'
// 'ajuste' → 'ajuste'  (sin des-transformar a 'salida')
```

**Consecuencia:** Un movimiento de tipo `salida` creado offline:
1. Se sube como `ajuste` a Supabase.
2. Al hacer pull en el mismo o en otro dispositivo, se descarga como `ajuste`.
3. El movimiento queda como `ajuste` localmente en lugar de `salida`, rompiendo los reportes y los filtros por tipo.

### Análisis de raíz

El problema es que `salida` y `ajuste` se mapean al mismo valor remoto (`'ajuste'`), haciendo el mapeo no reversible. Hay dos opciones de solución:

**Opción A (recomendada):** Sincronizar sin mapeo — usar el mismo vocabulario local y remoto.  
**Opción B:** Añadir un campo auxiliar `tipo_movimiento_local` en el JSON de push.

### Solución (Opción A)

Verificar si el esquema remoto `movimientos` acepta los valores `'entrada'`, `'salida'`, `'traslado'`, `'ajuste'`. Si el CHECK constraint del servidor solo acepta `'compra'`, `'ajuste'`, `'traslado'`, coordinar con el DBA para ampliarlo.

Si el servidor puede aceptar los valores locales directamente:

```dart
// ✅ Eliminar el mapeo y enviar el valor local tal cual:
String _tipoMovimientoToRemote(String value) => value;
String _tipoMovimientoFromRemote(String? value) => value ?? '';
```

Si el servidor no puede cambiar (Opción B):

```dart
// ✅ Guardar el tipo original en un campo adicional:
Map<String, dynamic> _movimientoToJson(Movimiento r) => {
  ..._syncMap(...),
  'tipo_movimiento': _tipoMovimientoToRemote(r.tipoMovimiento),
  'tipo_movimiento_local': r.tipoMovimiento,   // ← campo nuevo en Supabase
  ...
};

String _tipoMovimientoFromRemote(String? remoteValue, String? localValue) {
  if (localValue != null && localValue.isNotEmpty) return localValue;
  // fallback al des-mapeo anterior si no hay campo local
  return switch (remoteValue?.trim().toLowerCase() ?? '') {
    'compra' => 'entrada',
    _ => remoteValue ?? '',
  };
}
```

### Archivos a modificar

- `lib/core/repositories/sync_repository_drift.dart`
- (Si Opción B) nueva migración: `ALTER TABLE movimientos ADD COLUMN IF NOT EXISTS tipo_movimiento_local TEXT;`

### Cómo validar

1. Crear offline: 1 movimiento `entrada`, 1 `salida`, 1 `traslado`, 1 `ajuste`.
2. Sincronizar (push + pull).
3. Verificar que los tipos locales coinciden exactamente con los tipos en Supabase.
4. En otro dispositivo, hacer pull y verificar que los tipos se leen correctamente.

---

## Ítem 2.2 — `_markSynced` usa timestamp del dispositivo en lugar del servidor

### Problema

**Archivo:** `lib/core/repositories/sync_repository_drift.dart`  
**Método:** `_markSynced` (línea ~778)

```dart
Future<void> _markSynced(String tableName, List<String> ids) async {
  await _db.customStatement(
    "UPDATE $tableName SET sync_status = 'synced', updated_at = CURRENT_TIMESTAMP ...",
    ids,
  );
}
```

`CURRENT_TIMESTAMP` es la hora del dispositivo. Si el reloj del dispositivo está adelantado respecto al servidor (escenario habitual en dispositivos móviles sin sincronización NTP), ocurre lo siguiente:

1. Registro `X` se sube a Supabase con `ultima_actualizacion = 10:00:00` (hora servidor).
2. `_markSynced` actualiza local con `updated_at = 10:05:00` (hora dispositivo adelantada).
3. El servidor envía un evento Realtime para `X` con `ultima_actualizacion = 10:00:00`.
4. `_shouldUpdateLocal` compara: local `10:05:00` > remoto `10:00:00` → **preserva local**.
5. El registro queda divergido silenciosamente para siempre.

### Solución

Usar el timestamp que devuelve Supabase en la respuesta del upsert. Para ello, el `_push` debe capturar la respuesta y extraer el timestamp:

```dart
Future<void> _push<T>(
  String remoteTable,
  String localTable,
  List<T> rows,
  FutureOr<Map<String, dynamic>> Function(T row) toJson, {
  String? onConflict,
}) async {
  // ... (validación de payloads sin cambio)

  try {
    // ✅ Añadir .select() para recibir las filas confirmadas por Supabase
    final response = await _supabase
        .from(remoteTable)
        .upsert(validPayloads, onConflict: onConflict)
        .select('id, ultima_actualizacion');    // ← AÑADIR .select()

    // Construir mapa de id → ultima_actualizacion del servidor
    final serverTimestamps = <String, String>{};
    for (final row in response) {
      final id = row['id']?.toString() ?? '';
      final ts = row['ultima_actualizacion']?.toString() ?? '';
      if (id.isNotEmpty && ts.isNotEmpty) serverTimestamps[id] = ts;
    }

    await _markSyncedWithTimestamps(localTable, validIds, serverTimestamps);
    
  } catch (batchError) {
    // ... fallback individual sin cambio
  }
}

/// Versión de _markSynced que acepta timestamps del servidor por id
Future<void> _markSyncedWithTimestamps(
  String tableName,
  List<String> ids,
  Map<String, String> serverTimestamps,
) async {
  if (ids.isEmpty) return;
  for (final id in ids) {
    final ts = serverTimestamps[id];
    if (ts != null && ts.isNotEmpty) {
      await _db.customStatement(
        "UPDATE $tableName SET sync_status = 'synced', updated_at = ? WHERE id = ?",
        [ts, id],
      );
    } else {
      // Fallback: si Supabase no devolvió timestamp para este id, usar el actual
      await _db.customStatement(
        "UPDATE $tableName SET sync_status = 'synced' WHERE id = ?",
        [id],
      );
    }
  }
}
```

**Nota:** Mantener el método `_markSynced` original para casos donde el `.select()` no aplica (ej: upserts sin respuesta). El nuevo `_markSyncedWithTimestamps` es el camino preferido.

### Archivos a modificar

- `lib/core/repositories/sync_repository_drift.dart`

### Cómo validar

1. Adelantar el reloj del dispositivo de prueba 10 minutos.
2. Crear y sincronizar un producto.
3. Verificar que `updated_at` local del producto coincide con `ultima_actualizacion` de Supabase, no con la hora adelantada del dispositivo.
4. Restaurar el reloj. Hacer un cambio en el servidor vía Supabase Studio.
5. Verificar que el Realtime actualiza el local (no lo ignora por timestamp).

---

## Ítem 2.3 — Registros con `sync_error` sobrescritos incorrectamente por el remoto

### Problema

**Archivo:** `lib/core/repositories/sync_repository_drift.dart`  
**Método:** `_shouldUpdateLocal` (línea ~424)

```dart
if (syncStatus == 'synced' || syncStatus == 'sync_error') {
  return true; // ← acepta sobrescritura remota para sync_error
}
```

Un registro en `sync_error` tiene un cambio local que **no pudo subirse** al servidor (por error de red, validación, etc.). Cuando llega un evento Realtime o pull del mismo registro, el dato remoto (la versión antigua sin el cambio local) sobrescribe el cambio local, perdiéndolo sin informar al usuario.

### Solución

Tratar `sync_error` como un estado pendiente y comparar timestamps igual que `pending_update`:

```dart
Future<bool> _shouldUpdateLocal(
  String tableName,
  Map<String, dynamic> remoteJson,
) async {
  final id = remoteJson['id']?.toString();
  if (id == null || id.isEmpty) return true;

  final res = await _db.customSelect(
    "SELECT sync_status, updated_at FROM $tableName WHERE id = ? LIMIT 1",
    variables: [Variable.withString(id)],
  ).getSingleOrNull();

  if (res == null) return true;

  final syncStatus = res.read<String>('sync_status');

  // ✅ CAMBIO: sync_error ya no acepta sobrescritura automática —
  // se trata igual que pending_update (comparación por timestamp)
  if (syncStatus == 'synced') {
    return true;
  }

  // Para pending_insert, pending_update y sync_error: comparar timestamps
  final localUpdatedAtStr = res.read<String>('updated_at');
  final localUpdatedAt = DateTime.tryParse(localUpdatedAtStr)
      ?? DateTime.fromMillisecondsSinceEpoch(0);

  final remoteUpdatedAtStr =
      remoteJson['ultima_actualizacion']?.toString() ??
      remoteJson['fecha_registro']?.toString();
  final remoteUpdatedAt = remoteUpdatedAtStr != null
      ? DateTime.tryParse(remoteUpdatedAtStr)
            ?? DateTime.fromMillisecondsSinceEpoch(0)
      : DateTime.fromMillisecondsSinceEpoch(0);

  if (localUpdatedAt.isAfter(remoteUpdatedAt) ||
      localUpdatedAt.isAtSameMomentAs(remoteUpdatedAt)) {
    AppLogger.debug(
      '[Sync] Preservando edición local (${syncStatus}) para $tableName ($id)',
    );
    return false;
  }

  // El remoto es más reciente: aceptar, pero registrar si había un error pendiente
  if (syncStatus == 'sync_error') {
    AppLogger.warn(
      '[Sync] Sobrescribiendo sync_error con dato remoto más reciente en $tableName ($id)',
    );
  }

  return true;
}
```

### Archivos a modificar

- `lib/core/repositories/sync_repository_drift.dart`

### Cómo validar

1. Crear un producto y sincronizar (queda `synced`).
2. Modificar el nombre del producto offline. Queda `pending_update`.
3. Forzar un error en el push de ese producto (ej: corromper el UUID momentáneamente).
4. El registro queda `sync_error` con el nombre modificado.
5. Desde Supabase Studio, modificar ese mismo producto con un nombre diferente y con `ultima_actualizacion` anterior al del dispositivo.
6. Hacer pull. Verificar que el nombre local NO se sobreescribe (el local es más reciente).
7. Verificar que si el remoto tiene `ultima_actualizacion` posterior, sí sobrescribe (con log de warning).

---

## Ítem 2.4 — Campo `descripcion` de bodegas nunca se sube al servidor

### Problema

**Archivo:** `lib/core/repositories/sync_repository_drift.dart`  
**Método:** `_bodegaToJson` (línea ~1071)

La tabla local `Bodegas` tiene el campo `descripcion` (texto libre). El método de serialización no lo incluye:

```dart
Map<String, dynamic> _bodegaToJson(Bodega r) => {
  ..._syncMap(r.id, r.createdAt, r.updatedAt, r.syncStatus),
  'empresa_id': r.empresaId,
  'nombre': r.nombre,
  'direccion': r.direccion,
  // ← FALTA 'descripcion': r.descripcion,
  'es_punto_venta': r.esPuntoVenta,
  ...
};
```

### Solución

```dart
Map<String, dynamic> _bodegaToJson(Bodega r) => {
  ..._syncMap(r.id, r.createdAt, r.updatedAt, r.syncStatus),
  'empresa_id': r.empresaId,
  'nombre': r.nombre,
  'direccion': r.direccion,
  'descripcion': r.descripcion,        // ← AÑADIR
  'es_punto_venta': r.esPuntoVenta,
  'usuario_registro_id': r.usuarioRegistroId,
  'estado': r.estado,
  'fecha_eliminacion': r.fechaEliminacion?.toIso8601String(),
};
```

**Nota:** Verificar que la columna `descripcion` existe en la tabla `bodegas` de Supabase. Si no existe, crear la migración: `ALTER TABLE bodegas ADD COLUMN IF NOT EXISTS descripcion TEXT;`

### Archivos a modificar

- `lib/core/repositories/sync_repository_drift.dart`

---

## Ítem 2.5 — `fecha_registro` eliminado en `caja_sesiones`, `ventas` y `caja_movimientos_extras`

### Problema

**Archivo:** `lib/core/repositories/sync_repository_drift.dart`  
**Métodos:** `_cajaSesionToJson` (línea ~1098), `_cajaMovimientoExtraToJson` (línea ~1117), `_ventaToJson` (línea ~1273)

Los tres métodos eliminan explícitamente el campo `fecha_registro` del mapa antes de enviarlo a Supabase:

```dart
map.remove('fecha_registro');   // presente en los tres métodos
```

Este `remove` fue añadido originalmente para evitar conflictos. El riesgo es:

1. Si la columna `fecha_registro` en Supabase es `NOT NULL` sin valor por defecto, el upsert fallará con un error de constraint.
2. Si es `NOT NULL` con `DEFAULT now()`, el servidor usará la hora del servidor en lugar de la hora en que se creó el registro localmente, perdiendo el timestamp real.

### Solución

**Paso 1:** Verificar en Supabase Studio el constraint de `fecha_registro` para `caja_sesiones`, `ventas` y `caja_movimientos_extras`.

**Paso 2:** Si la columna acepta NULL o tiene DEFAULT:
- El `remove` actual es seguro pero pierde el timestamp de origen. Se recomienda enviar la fecha de creación local.

**Paso 3:** Eliminar los `map.remove('fecha_registro')` y verificar que `_syncMap` ya incluye `fecha_registro: createdAt`:

```dart
// _syncMap ya devuelve:
// 'fecha_registro': createdAt.toIso8601String()
// No se necesita remove. Si hay conflicto, es un bug en _syncMap, no en los métodos.

Map<String, dynamic> _cajaSesionToJson(CajaSesione r) {
  return {
    ..._syncMap(r.id, r.createdAt, r.updatedAt, r.syncStatus),
    // ← ya NO se llama a map.remove('fecha_registro')
    'caja_id': r.cajaId,
    'usuario_apertura_id': r.usuarioAperturaId,
    // ...
  };
}
```

### Archivos a modificar

- `lib/core/repositories/sync_repository_drift.dart`

### Cómo validar

1. Abrir una sesión de caja offline y cerrarla.
2. Sincronizar.
3. Verificar en Supabase que `caja_sesiones.fecha_registro` tiene el timestamp real de apertura, no el del servidor.

---

## Ítem 2.6 — Doble consulta de variantes pendientes crea race condition

### Problema

**Archivo:** `lib/core/repositories/sync_repository_drift.dart`  
**Método:** `pushCambiosLocales` (líneas ~87–93)

```dart
final pendingVariantes = await _db.inventoryDao.getPendingProductoVariantes();
await _reconcileProductoVarianteUUIDs(pendingVariantes);   // usa snapshot A

await _push(
  'codigo_producto',
  'producto_variantes',
  await _db.inventoryDao.getPendingProductoVariantes(),    // ← re-query: snapshot B
  _productoVarianteToJson,
);
```

Entre la reconciliación y el push se ejecuta código asíncrono. El watcher de Drift puede haber creado una nueva variante en ese intervalo. Esta nueva variante existe en el snapshot B pero **no pasó por `_reconcileProductoVarianteUUIDs`**, pudiendo subir un UUID local que ya existe en Supabase con otro UUID → error 23505.

### Solución

Usar el mismo snapshot en reconciliación y push:

```dart
// ✅ Una sola consulta, misma lista para ambas operaciones:
final pendingVariantes = await _db.inventoryDao.getPendingProductoVariantes();
await _reconcileProductoVarianteUUIDs(pendingVariantes);
await _push(
  'codigo_producto',
  'producto_variantes',
  pendingVariantes,        // ← misma lista, no re-query
  _productoVarianteToJson,
);
```

Aplicar el mismo patrón para inventarios:

```dart
final pendingInventarios = await _db.inventoryDao.getPendingInventarios();
await _reconcileInventarioUUIDs(pendingInventarios);
await _push(
  'inventario_producto',
  'inventarios',
  pendingInventarios,      // ← misma lista
  _inventarioToJson,
  onConflict: 'id',
);
```

### Archivos a modificar

- `lib/core/repositories/sync_repository_drift.dart`

---

## Checklist de cierre del Sprint 2

- [x] 2.1 — Mapeo `tipo_movimiento` Opción B implementado: campo `tipo_movimiento_local` en push, priorizado en fromRemote
- [x] 2.2 — `_markSyncedWithTimestamps` implementado y usando timestamps del servidor
- [x] 2.3 — `_shouldUpdateLocal` trata `sync_error` con comparación de timestamps
- [x] 2.4 — `descripcion` de bodegas incluido en el push (migración 20260627000001 pendiente de aplicar)
- [x] 2.5 — `map.remove('fecha_registro')` se mantiene: venta_producto/caja_sesion/caja_movimiento_extra NO tienen esa columna en Supabase
- [x] 2.6 — Doble consulta de variantes e inventarios unificada a snapshot único
- [ ] Prueba de regresión completa (crear, editar, eliminar, sync en modo offline/online)
- [ ] Verificar que no hay registros en `sync_error` en la base de prueba después de un ciclo completo
