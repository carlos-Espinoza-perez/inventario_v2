# Plan 06 - Resolución de entidades (productos, clientes, bodegas)
**Origen:** `requerimiento/Add IA/06_resolucion_de_entidades.md`

---

## Objetivo

Implementar `EntityResolver` que convierte texto libre en entidades reales del sistema. Usa los métodos del DAO que ya existen (`searchProductoByCodeOrName`) como punto de partida, en lugar de duplicar lógica. Emplea `normalizeText` del archivo compartido.

---

## Hallazgo clave

`InventoryDao` ya tiene `searchProductoByCodeOrName(query)`. Este método es el punto de entrada principal. El resolver lo usa primero y solo aplica lógica de ranking propia si hay múltiples resultados.

**Sobre SKU:** El campo `sku` vive en `ProductoVariante`, no en `Producto`. Al buscar por código se usa `codigoPersonalizado` de `Producto` o `sku` de `ProductoVariante` — `searchProductoByCodeOrName` ya maneja esto.

---

## Archivos a crear

| Archivo | Capa | Propósito |
|---|---|---|
| `lib/features/assistant/domain/models/entity_resolution.dart` | domain | Tipo de resultado de resolución |
| `lib/features/assistant/data/entity_resolver.dart` | data | Lógica de matching usando DAOs reales |

> `EntityResolver` va en `data/` porque depende de `AppDatabase`.

---

## Paso 1 — EntityResolution (capa domain, sin dependencias)

```dart
// lib/features/assistant/domain/models/entity_resolution.dart

enum EntityResolutionStatus { resolved, ambiguous, notFound }

class EntityResolution<T> {
  final EntityResolutionStatus status;
  final T? selected;
  final List<T> candidates;
  final String originalQuery;

  const EntityResolution({
    required this.status,
    required this.originalQuery,
    this.selected,
    this.candidates = const [],
  });

  bool get isResolved => status == EntityResolutionStatus.resolved;
  bool get isAmbiguous => status == EntityResolutionStatus.ambiguous;
  bool get isNotFound => status == EntityResolutionStatus.notFound;

  factory EntityResolution.resolved(T entity, String query) => EntityResolution(
        status: EntityResolutionStatus.resolved,
        selected: entity,
        originalQuery: query,
      );

  factory EntityResolution.ambiguous(List<T> candidates, String query) =>
      EntityResolution(
        status: EntityResolutionStatus.ambiguous,
        candidates: candidates,
        originalQuery: query,
      );

  factory EntityResolution.notFound(String query) => EntityResolution(
        status: EntityResolutionStatus.notFound,
        originalQuery: query,
      );
}
```

---

## Paso 2 — EntityResolver (capa data, usa DAOs)

```dart
// lib/features/assistant/data/entity_resolver.dart

import 'package:inventario_v2/core/db/app_database.dart';
import '../domain/models/entity_resolution.dart';
import '../domain/utils/text_normalizer.dart';

class EntityResolver {
  final AppDatabase _db;

  const EntityResolver(this._db);

  // ── Resolución de productos ──────────────────────────────────────────────

  Future<EntityResolution<Producto>> resolveProduct(
    String query, {
    required String empresaId,
  }) async {
    if (query.trim().isEmpty) {
      return EntityResolution.notFound(query);
    }

    // 1. Usar el método del DAO que ya maneja nombre + codigoPersonalizado
    //    searchProductoByCodeOrName filtra por empresaId internamente
    final results = await _db.inventoryDao.searchProductoByCodeOrName(query);

    if (results.isEmpty) {
      return EntityResolution.notFound(query);
    }

    if (results.length == 1) {
      return EntityResolution.resolved(results.first, query);
    }

    // 2. Múltiples resultados: aplicar ranking por solapamiento de palabras
    final nQuery = normalizeText(query);
    final ranked = _rankByWordOverlap(results, nQuery);

    // Si el primer resultado tiene score mucho mayor al segundo, lo tomamos
    if (ranked.length >= 2 &&
        ranked[0].score >= 0.85 &&
        (ranked[0].score - ranked[1].score) > 0.35) {
      return EntityResolution.resolved(ranked[0].item, query);
    }

    // Ambigüedad: devolver los mejores candidatos
    return EntityResolution.ambiguous(
      ranked.take(4).map((r) => r.item).toList(),
      query,
    );
  }

  // ── Resolución de clientes ───────────────────────────────────────────────

  Future<EntityResolution<Cliente>> resolveClient(
    String query, {
    required String empresaId,
  }) async {
    if (query.trim().isEmpty) {
      return EntityResolution.notFound(query);
    }

    final nQuery = normalizeText(query);

    // Obtener todos los clientes de la empresa
    // SalesDao no tiene un searchCliente, así que hacemos contains manual
    // Nota: si la lista de clientes crece mucho, agregar método de búsqueda al DAO
    final allClients = await _db.salesDao.getAllClientesPorEmpresa(empresaId);

    // 1. Coincidencia exacta por nombre normalizado
    final exactMatches = allClients
        .where((c) => normalizeText(c.nombre) == nQuery)
        .toList();
    if (exactMatches.length == 1) {
      return EntityResolution.resolved(exactMatches.first, query);
    }
    if (exactMatches.length > 1) {
      return EntityResolution.ambiguous(exactMatches.take(4).toList(), query);
    }

    // 2. Coincidencia parcial (contains)
    final partialMatches = allClients
        .where((c) => normalizeText(c.nombre).contains(nQuery))
        .toList();
    if (partialMatches.isEmpty) {
      return EntityResolution.notFound(query);
    }
    if (partialMatches.length == 1) {
      return EntityResolution.resolved(partialMatches.first, query);
    }

    // 3. Ranking por solapamiento de palabras
    final ranked = _rankClientsByWordOverlap(partialMatches, nQuery);
    if (ranked.length >= 2 &&
        ranked[0].score >= 0.85 &&
        (ranked[0].score - ranked[1].score) > 0.35) {
      return EntityResolution.resolved(ranked[0].item, query);
    }

    return EntityResolution.ambiguous(
      ranked.take(4).map((r) => r.item).toList(),
      query,
    );
  }

  // ── Resolución de bodega ─────────────────────────────────────────────────

  Future<String?> resolveWarehouseId(
    String query,
    Set<String> allowedWarehouseIds,
  ) async {
    if (query.trim().isEmpty) return null;

    final nQuery = normalizeText(query);

    // Buscar en bodegas permitidas por nombre normalizado
    // Nota: agregar método getAllBodegas al DAO si no existe
    // Por ahora usar bodegaListProvider desde el contexto si se necesita
    // Este método se completa al implementar plan_09
    return null;
  }

  // ── Ranking interno ──────────────────────────────────────────────────────

  List<({Producto item, double score})> _rankByWordOverlap(
    List<Producto> items,
    String normalizedQuery,
  ) {
    final queryWords =
        normalizedQuery.split(RegExp(r'\s+')).where((w) => w.length > 1).toSet();

    final ranked = items.map((item) {
      final itemWords = normalizeText(item.nombre)
          .split(RegExp(r'\s+'))
          .where((w) => w.length > 1)
          .toSet();
      final intersection = queryWords.intersection(itemWords).length;
      final score = queryWords.isEmpty ? 0.0 : intersection / queryWords.length;
      return (item: item, score: score);
    }).toList()
      ..sort((a, b) => b.score.compareTo(a.score));

    return ranked;
  }

  List<({Cliente item, double score})> _rankClientsByWordOverlap(
    List<Cliente> items,
    String normalizedQuery,
  ) {
    final queryWords =
        normalizedQuery.split(RegExp(r'\s+')).where((w) => w.length > 1).toSet();

    final ranked = items.map((item) {
      final itemWords = normalizeText(item.nombre)
          .split(RegExp(r'\s+'))
          .where((w) => w.length > 1)
          .toSet();
      final intersection = queryWords.intersection(itemWords).length;
      final score = queryWords.isEmpty ? 0.0 : intersection / queryWords.length;
      return (item: item, score: score);
    }).toList()
      ..sort((a, b) => b.score.compareTo(a.score));

    return ranked;
  }
}
```

---

## Paso 3 — Método faltante en SalesDao

`EntityResolver` necesita `getAllClientesPorEmpresa(empresaId)`. Verificar si existe en `SalesDao`. Si no existe, agregar:

```dart
// En lib/core/db/daos/sales_dao.dart

Future<List<Cliente>> getAllClientesPorEmpresa(String empresaId) {
  return (select(clientes)
    ..where((c) => c.empresaId.equals(empresaId) & c.estado.equals(true)))
    .get();
}
```

---

## Paso 4 — Embeddings (fase posterior)

Cuando se implemente:
- Solo para productos y clientes
- Guardar: `sourceText`, `sourceHash`, `vectorVersion`
- Permitir reconstruir índice sin perder datos
- No reemplaza consultas exactas, las complementa

No agregar dependencias de embeddings hasta que esta fase inicie.

---

## Criterio de cierre

- [ ] `searchProductoByCodeOrName` es el punto de entrada principal para productos
- [ ] Resultado único → `resolved`; múltiples → `ambiguous` con ranking; ninguno → `notFound`
- [ ] Clientes se buscan por nombre normalizado (exacto → parcial → ranking)
- [ ] `normalizeText` viene del archivo compartido (no duplicada)
- [ ] `EntityResolver` vive en `data/`, no en `domain/`
- [ ] Si `getAllClientesPorEmpresa` no existe en SalesDao, se agrega ahí
