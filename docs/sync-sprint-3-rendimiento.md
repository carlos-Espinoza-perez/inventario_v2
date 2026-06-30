# Sprint 3 — Rendimiento y Escalabilidad de Sincronización

**Prioridad:** 🟠 MAYOR — Resolver antes de superar los 1.000 registros por tabla  
**Esfuerzo estimado:** 5 días de desarrollo  
**Rama sugerida:** `feat/sync-sprint-3-performance`  
**Prerequisito:** Sprint 1 y Sprint 2 completados  
**Contexto:** Auditoría offline-first del 2026-06-26

---

## Objetivo

Implementar pull incremental con cursor para evitar descargas completas en cada sync, añadir Exponential Backoff para proteger Supabase en reconexiones masivas, y corregir el consumo excesivo de RAM en búsquedas de catálogo.

---

## Ítem 3.1 — Pull sin cursor: descarga completa de cada tabla en cada sync

### Problema

**Archivo:** `lib/core/repositories/sync_repository_drift.dart`  
**Método:** `_pull` (línea ~733)  
**Configuración:** `supabase/config.toml` línea con `max_rows = 1000`

```dart
final rows = await _supabase.from(remoteTableName).select(); // ← sin filtro
```

Cada llamada a `pullRemoteChanges()` descarga el 100% de cada una de las 19 tablas. Con el límite de PostgREST configurado en `max_rows = 1000`, las tablas que superen 1.000 filas (`ventas`, `detalle_ventas`, `detalle_movimientos`) serán **truncadas silenciosamente** — el app nunca sabrá que hay más datos.

**Impacto en producción:**
- Empresa con 1.500 ventas: las últimas 500 nunca se descargan.
- Cada reconexión descarga cientos de filas que el app ya tiene, desperdiciando ancho de banda y tiempo.

### Solución: Pull incremental con cursor por tabla

La estrategia es guardar la fecha del último pull exitoso por tabla y filtrar con `gte('ultima_actualizacion', lastPullAt)`.

#### Paso 1: Crear una tabla o `SharedPreferences` para guardar cursores

Opción A (más simple): `SharedPreferences` con una clave por tabla.  
Opción B (más robusta): Tabla local `sync_cursors` en Drift.

**Opción A — SharedPreferences:**

```dart
import 'package:shared_preferences/shared_preferences.dart';

class SyncCursorStore {
  static const _prefix = 'sync_cursor_';

  static Future<DateTime?> getLastPullAt(String tableName) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('$_prefix$tableName');
    return stored != null ? DateTime.tryParse(stored) : null;
  }

  static Future<void> setLastPullAt(String tableName, DateTime dt) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_prefix$tableName', dt.toIso8601String());
  }

  static Future<void> resetAll() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith(_prefix));
    for (final key in keys) {
      await prefs.remove(key);
    }
  }
}
```

#### Paso 2: Modificar `_pull` para usar el cursor

```dart
Future<void> _pull(
  String localTableName,
  String remoteTableName,
  Future<void> Function(Map<String, dynamic>) onUpsert, {
  bool forceFull = false,     // ← para el primer pull tras instalación
}) async {
  AppLogger.info('[Sync][Pull] Consultando $remoteTableName -> $localTableName');

  try {
    // Obtener cursor de la última sincronización exitosa
    final lastPullAt = forceFull
        ? null
        : await SyncCursorStore.getLastPullAt(localTableName);

    // Usar la fecha actual como marca de inicio (antes de la query)
    final pullStartTime = DateTime.now().toUtc();

    // Construir query con o sin cursor
    var query = _supabase.from(remoteTableName).select();
    if (lastPullAt != null) {
      // Descargar solo lo que cambió desde el último pull
      query = query.gte('ultima_actualizacion', lastPullAt.toIso8601String());
      AppLogger.info('[Sync][Pull] Incremental desde ${lastPullAt.toIso8601String()}');
    } else {
      AppLogger.info('[Sync][Pull] Pull completo (primer sync o reset)');
    }

    // Paginación para superar el límite de max_rows = 1000
    const pageSize = 500;
    int offset = 0;
    int totalSynced = 0;
    bool hasMore = true;

    while (hasMore) {
      final page = await query
          .order('ultima_actualizacion', ascending: true)
          .range(offset, offset + pageSize - 1);

      for (final row in page) {
        try {
          final map = Map<String, dynamic>.from(row);
          if (await _shouldUpdateLocal(localTableName, map)) {
            await onUpsert(map);
            totalSynced++;
          }
        } catch (itemErr) {
          final errorStr = itemErr.toString();
          if (errorStr.contains('FOREIGN KEY constraint failed') ||
              errorStr.contains('code 787')) {
            final map = Map<String, dynamic>.from(row);
            await _createGhostEntitiesIfMissing(map);
            try {
              await onUpsert(map);
              totalSynced++;
            } catch (retryErr) {
              AppLogger.error(
                '[Sync][Pull] Retry fallido en $localTableName: $row',
                retryErr,
              );
            }
          } else {
            AppLogger.error(
              '[Sync][Pull] Fallo al insertar fila en $localTableName: $row',
              itemErr,
            );
          }
        }
      }

      hasMore = page.length == pageSize;
      offset += pageSize;
    }

    // Guardar cursor solo si el pull completó sin errores generales
    await SyncCursorStore.setLastPullAt(localTableName, pullStartTime);
    AppLogger.info(
      '[Sync][Pull] $totalSynced filas sincronizadas en $localTableName',
    );

  } catch (e, st) {
    AppLogger.error(
      '[Sync][Pull] Fallo general al descargar de $remoteTableName',
      e,
      st,
    );
    // NO actualizar el cursor si hubo error general — se reintentará completo
  }
}
```

#### Paso 3: Pull completo en primera instalación

En `pullRemoteChanges`, añadir un flag para forzar pull completo:

```dart
Future<void> pullRemoteChanges({bool forceFull = false}) async {
  await _pull('empresas', 'empresa', ..., forceFull: forceFull);
  await _pull('roles', 'rol', ..., forceFull: forceFull);
  // ... todas las tablas
}
```

En `auto_sync_provider.dart`, la primera vez que se ejecuta sync (sesión nueva):

```dart
// En runFullSync, detectar si es primer sync:
final isFirstSync = await SyncCursorStore.getLastPullAt('ventas') == null;
await repo.pullRemoteChanges(forceFull: isFirstSync);
```

#### Paso 4: Exponer reset del cursor para soporte

```dart
// En SyncRepository, método público para reset de emergencia:
Future<void> resetSyncCursors() async {
  await SyncCursorStore.resetAll();
  AppLogger.info('[Sync] Cursores reseteados. Próximo pull será completo.');
}
```

### Archivos a modificar

- `lib/core/repositories/sync_repository_drift.dart`
- Nuevo archivo: `lib/core/repositories/sync_cursor_store.dart`
- `lib/core/providers/auto_sync_provider.dart`

### Dependencias nuevas

Ninguna. `shared_preferences` ya debería estar en el proyecto.

### Cómo validar

1. Hacer un pull completo inicial (sin cursor). Verificar que todas las filas se descargan con paginación.
2. Crear 3 registros nuevos en Supabase Studio.
3. Hacer pull incremental. Verificar que solo se descargan los 3 nuevos registros, no toda la tabla.
4. Con una tabla de 1.500 ventas, verificar que la paginación descarga todas (no se trunca en 1.000).
5. Simular un error de red a mitad del pull. Verificar que el cursor NO se actualiza y el siguiente pull es completo.

---

## Ítem 3.2 — Sin Exponential Backoff: thundering herd al reconectarse

### Problema

**Archivo:** `lib/core/providers/auto_sync_provider.dart`  
**Métodos:** `_updateConnectionStatus` (línea ~171) y `_onLocalChange` (línea ~190)

```dart
// Reconexión: dispara sync inmediatamente
if (hasConnection && wasOffline) {
  runFullSync();   // ← inmediato, sin espera
}

// Cambio local: debounce fijo de 2 segundos
void _onLocalChange() {
  _debounceTimer?.cancel();
  _debounceTimer = Timer(const Duration(seconds: 2), triggerSyncNow);
}
```

Si Supabase sufre una interrupción breve y cientos de dispositivos reconectan simultáneamente, todos lanzan `runFullSync()` en el mismo instante, amplificando la carga y potencialmente extendiendo la caída.

Si el sync falla repetidamente (ej: error 429 rate limit), el sistema reintenta cada 2 segundos sin aumento progresivo de la espera.

### Solución: Exponential Backoff con jitter

```dart
// En AutoSync:

int _syncRetryCount = 0;
static const int _maxRetryCount = 8;         // máximo 8 reintentos
static const Duration _baseDelay = Duration(seconds: 2);
static const Duration _maxDelay = Duration(minutes: 5);

/// Calcula el tiempo de espera con jitter para evitar sincronización simultánea
Duration _backoffDelay() {
  if (_syncRetryCount == 0) return Duration.zero;
  final expDelay = _baseDelay * (1 << _syncRetryCount.clamp(0, 10));
  final capped = expDelay > _maxDelay ? _maxDelay : expDelay;
  // Jitter: ±25% del delay para desincronizar dispositivos
  final jitter = Duration(
    milliseconds: (capped.inMilliseconds * 0.25 * (DateTime.now().millisecond / 1000)).toInt(),
  );
  return capped + jitter;
}

Future<void> runFullSync() async {
  final currentState = state.value;
  if (currentState?.isSyncing == true) return;

  // ... (verificación de sesión y conectividad sin cambio)

  try {
    state = AsyncData(currentState!.copyWith(isSyncing: true, lastError: null));

    final repo = await ref.read(syncRepositoryProvider.future);
    await repo.pushCambiosLocales();
    await repo.pullRemoteChanges();

    // ✅ Éxito: resetear contador de reintentos
    _syncRetryCount = 0;

    state = AsyncData(currentState.copyWith(
      isSyncing: false,
      lastError: null,
      lastSync: DateTime.now(),
    ));

  } catch (e, st) {
    AppLogger.error('[AutoSync] Fallo en Full Sync (intento $_syncRetryCount)', e, st);

    // ✅ Incrementar contador y programar reintento con backoff
    if (_syncRetryCount < _maxRetryCount) {
      _syncRetryCount++;
      final delay = _backoffDelay();
      AppLogger.info('[AutoSync] Reintentando en ${delay.inSeconds}s (intento $_syncRetryCount)');
      Future.delayed(delay, runFullSync);
    } else {
      AppLogger.warn('[AutoSync] Máximo de reintentos alcanzado. Sync suspendido hasta próxima reconexión.');
      _syncRetryCount = 0;  // reset para la próxima reconexión
    }

    state = AsyncData((currentState ?? const SyncState()).copyWith(
      isSyncing: false,
      lastError: e.toString(),
      retryCount: _syncRetryCount,  // exponer en UI (ver Sprint 4)
    ));
  }
}

void _updateConnectionStatus(List<ConnectivityResult> results) {
  final hasConnection = !results.contains(ConnectivityResult.none);
  final wasOffline = state.value?.isOnline == false;

  state = AsyncData((state.value ?? const SyncState()).copyWith(isOnline: hasConnection));

  if (hasConnection && wasOffline) {
    // ✅ Resetear contador al reconectarse (nueva oportunidad)
    _syncRetryCount = 0;
    // Pequeña espera aleatoria para desincronizar múltiples dispositivos
    final jitter = Duration(milliseconds: DateTime.now().millisecond % 3000);
    Future.delayed(jitter, runFullSync);
    RemoteLogger.flushPending();
  }
}
```

### Archivos a modificar

- `lib/core/providers/auto_sync_provider.dart`
- `lib/core/providers/auto_sync_provider.g.dart` (regenerar si se añaden campos al `SyncState`)

### Cómo validar

1. Simular 5 fallos consecutivos de sync (apagar Supabase o usar una URL incorrecta temporalmente).
2. Verificar en los logs que los intentos son: 2s, 4s, 8s, 16s, 32s... hasta el máximo de 5 minutos.
3. Reconectar. Verificar que el contador se resetea y el siguiente sync es inmediato (con jitter < 3s).
4. Verificar que `SyncState.retryCount` refleja correctamente el número de reintentos en la UI.

---

## Ítem 3.3 — Carga de 2.000 productos en RAM para búsqueda fuzzy

### Problema

**Archivos:**
- `lib/features/inventory/data/repository/inventario_repository.dart` (línea ~135)
- `lib/features/inventory/data/repositories/inventario_repository.dart` (línea ~19)

```dart
// buscarProductosPorSimilitud:
final allProducts = await (_db.select(_db.productos)
  ..where((tbl) => tbl.estado.equals(true))
  ..limit(2000)).get();   // ← 2.000 objetos Dart en memoria

// searchCatalogItems:
final allItems = await _db.inventoryDao.getCatalogItems(
  bodegaId: bodegaId,
  limit: 2000             // ← también 2.000 items
);
```

En dispositivos con RAM limitada (512 MB), cargar 2.000 productos más sus variantes e inventarios puede causar:
- **ANR (Application Not Responding)** en Android si el main thread queda bloqueado.
- Terminación del proceso por el OOM Killer del OS.
- Latencia visible al usuario (>500ms para renderizar resultados).

### Solución: Búsqueda SQL primero, fuzzy solo sobre resultados acotados

El DAO ya tiene búsqueda SQL con `LIKE` en `searchProductosList`. La estrategia es:

1. Ejecutar búsqueda SQL con `LIKE` para obtener candidatos (máximo 100).
2. Aplicar `FuzzySearch` solo a esos 100 resultados.
3. Devolver los mejores 15.

```dart
// En InventarioRepository (ambas versiones):

Future<List<ProductCatalogItemDrift>> searchCatalogItems(
  String query,
  String bodegaId,
) async {
  final queryTrimmed = query.trim();
  if (queryTrimmed.isEmpty) {
    return _db.inventoryDao.getCatalogItems(bodegaId: bodegaId, limit: 15);
  }

  // ✅ Paso 1: Pre-filtrado SQL — máximo 100 candidatos
  final sqlCandidates = await _db.inventoryDao.getCatalogItems(
    bodegaId: bodegaId,
    query: queryTrimmed,   // LIKE aplicado en el DAO
    limit: 100,            // ← reducido de 2.000 a 100
  );

  if (sqlCandidates.isEmpty) return [];

  // ✅ Paso 2: Fuzzy solo sobre los candidatos SQL
  final queryWords = queryTrimmed
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty)
      .toList();

  final filtered = sqlCandidates.where((item) {
    final targetText =
        '${item.producto.nombre} ${item.producto.codigoPersonalizado ?? ''}';
    return queryWords.every((qWord) => FuzzySearch.isMatch(qWord, targetText));
  }).toList();

  return filtered.take(15).toList();
}

Future<List<Producto>> buscarProductosPorSimilitud(String query) async {
  final queryTrimmed = query.trim();
  if (queryTrimmed.isEmpty) {
    return _db.inventoryDao.searchProductosList('');
  }

  // ✅ SQL primero: máximo 100 candidatos con LIKE
  final sqlCandidates = await _db.inventoryDao.searchProductosList(queryTrimmed);
  // searchProductosList ya limita a 15 con LIKE — si necesitamos más candidatos
  // para fuzzy, crear un método searchProductosListExpanded(query, limit: 100)

  final queryWords = queryTrimmed
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty)
      .toList();

  final filtered = sqlCandidates.where((producto) {
    final targetText =
        '${producto.nombre} ${producto.codigoPersonalizado ?? ''}';
    return queryWords.every((qWord) => FuzzySearch.isMatch(qWord, targetText));
  }).toList();

  return filtered.take(15).toList();
}
```

Si `searchProductosList` del DAO limita a 15 resultados con LIKE (insuficiente para fuzzy), añadir un método con límite mayor:

```dart
// En inventory_dao.dart:
Future<List<Producto>> searchProductosListExpanded(
  String query, {
  int limit = 100,
}) async {
  final normalized = query.trim();
  if (normalized.isEmpty) {
    return (select(productos)
          ..where((tbl) => tbl.estado.equals(true))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.nombre)])
          ..limit(limit))
        .get();
  }

  final cleanQuery = normalized.replaceAll('%', '').replaceAll('_', '');
  final words = cleanQuery
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty)
      .toList();

  final q = select(productos)..where((tbl) => tbl.estado.equals(true));
  for (final word in words) {
    q.where((tbl) =>
        tbl.nombre.like('%$word%') | tbl.codigoPersonalizado.like('%$word%'));
  }

  return (q..limit(limit)).get();
}
```

### Archivos a modificar

- `lib/features/inventory/data/repository/inventario_repository.dart`
- `lib/features/inventory/data/repositories/inventario_repository.dart`
- `lib/core/db/daos/inventory_dao.dart` (nuevo método `searchProductosListExpanded`)

### Cómo validar

1. Crear un catálogo de 3.000 productos en la BD de prueba.
2. Abrir el POS o la pantalla de búsqueda.
3. Medir el tiempo de respuesta de una búsqueda con Android Profiler (Memory tab).
4. Verificar que el heap no supera 30 MB adicionales durante la búsqueda.
5. Verificar que los resultados siguen siendo correctos (mismos productos que antes).

---

## Checklist de cierre del Sprint 3

- [x] 3.1 — `SyncCursorStore` implementado con paginación y pull incremental
- [x] 3.1 — Pull completo solo en primer sync o reset manual
- [x] 3.1 — Todas las 19 tablas en `pullRemoteChanges` usan el nuevo `_pull` con cursor
- [x] 3.2 — `_backoffDelay()` implementado con jitter y máximo de 5 minutos
- [x] 3.2 — Reconexión aplica pequeño jitter aleatorio en lugar de sync inmediato
- [x] 3.2 — `SyncState` expone `retryCount` para la UI
- [x] 3.3 — `searchCatalogItems` y `buscarProductosPorSimilitud` usan SQL pre-filtrado
- [x] 3.3 — Nuevo método `searchProductosListExpanded` en `InventoryDao`
- [ ] Benchmark de búsqueda antes y después con 3.000 productos
- [ ] Prueba de regresión de pull incremental: verificar que datos nuevos y editados llegan correctamente
