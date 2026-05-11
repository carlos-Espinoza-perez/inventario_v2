# Plan 05 - ToolExecutor — Los DAOs como herramientas del agente

---

## Objetivo

Implementar el `ToolExecutor` y el `ToolRegistry`: el sistema que convierte el JSON `{ "tool": "inventory.getStockPorBodega", "params": {...} }` que devuelve el LLM en una llamada real al DAO correspondiente. Los DAOs de Drift son las "herramientas" del agente.

---

## Principio

El LLM **nunca** llama directamente a Drift. El LLM dice qué tool usar y con qué parámetros. El `ToolExecutor` resuelve los parámetros, llama al DAO, y devuelve el resultado.

---

## Paso 1 — ToolResult tipado

```dart
// lib/features/assistant/data/tools/tool_result.dart

enum ToolResultStatus { success, notFound, ambiguous, error, requiresUserInput }

class ToolResult {
  final ToolResultStatus status;
  final dynamic data;          // dato real del DAO
  final String? errorMessage;
  final List<dynamic>? candidates; // si status == ambiguous
  final String? userQuestion;      // si status == requiresUserInput

  const ToolResult({
    required this.status,
    this.data,
    this.errorMessage,
    this.candidates,
    this.userQuestion,
  });

  bool get isSuccess => status == ToolResultStatus.success;
  bool get isAmbiguous => status == ToolResultStatus.ambiguous;
  bool get needsUserInput => status == ToolResultStatus.requiresUserInput;

  factory ToolResult.success(dynamic data) =>
      ToolResult(status: ToolResultStatus.success, data: data);

  factory ToolResult.notFound([String? message]) =>
      ToolResult(status: ToolResultStatus.notFound, errorMessage: message);

  factory ToolResult.ambiguous(List<dynamic> candidates) =>
      ToolResult(status: ToolResultStatus.ambiguous, candidates: candidates);

  factory ToolResult.error(String message) =>
      ToolResult(status: ToolResultStatus.error, errorMessage: message);

  factory ToolResult.askUser(String question) =>
      ToolResult(status: ToolResultStatus.requiresUserInput, userQuestion: question);

  /// Serializa para incluir en el contexto del LLM
  Map<String, dynamic> toContext() => {
        'status': status.name,
        if (data != null) 'data': _serializeData(data),
        if (errorMessage != null) 'error': errorMessage,
        if (candidates != null)
          'candidates': candidates!.map(_serializeData).toList(),
      };

  dynamic _serializeData(dynamic d) {
    if (d == null) return null;
    if (d is String || d is num || d is bool) return d;
    if (d is Map) return d;
    if (d is List) return d.map(_serializeData).toList();
    // Para objetos Drift, intentar toJson() o convertir manualmente
    try {
      return (d as dynamic).toJson();
    } catch (_) {
      return d.toString();
    }
  }
}
```

---

## Paso 2 — ToolRegistry

El registro mapea IDs de tools a funciones Dart. Agregar una nueva tool = agregar una entrada en el mapa.

```dart
// lib/features/assistant/data/tools/tool_registry.dart

import 'package:inventario_v2/core/db/app_database.dart';
import '../entity_resolver.dart';
import 'tool_result.dart';

typedef ToolFunction = Future<ToolResult> Function(
  Map<String, dynamic> params,
  Map<String, dynamic> context, // contexto operativo serializado
);

class ToolRegistry {
  final AppDatabase _db;
  final EntityResolver _resolver;

  late final Map<String, ToolFunction> _tools;

  ToolRegistry(this._db, this._resolver) {
    _tools = _buildRegistry();
  }

  bool has(String toolId) => _tools.containsKey(toolId);

  Future<ToolResult> execute(
    String toolId,
    Map<String, dynamic> params,
    Map<String, dynamic> context,
  ) async {
    final fn = _tools[toolId];
    if (fn == null) {
      return ToolResult.error('Tool "$toolId" no existe en el registro.');
    }
    try {
      return await fn(params, context);
    } catch (e) {
      return ToolResult.error('Error ejecutando "$toolId": $e');
    }
  }

  Map<String, ToolFunction> _buildRegistry() => {

    // ── Inventario ────────────────────────────────────────────────────────

    'entity_resolver.resolveProduct': (params, ctx) async {
      final query = params['query'] as String? ?? '';
      final empresaId = params['empresaId'] as String? ?? ctx['empresaId'] as String? ?? '';
      final result = await _resolver.resolveProduct(query, empresaId: empresaId);
      if (result.isResolved) return ToolResult.success(result.selected);
      if (result.isAmbiguous) return ToolResult.ambiguous(result.candidates);
      return ToolResult.notFound('No encontré un producto parecido a "$query".');
    },

    'entity_resolver.resolveClient': (params, ctx) async {
      final query = params['query'] as String? ?? '';
      final empresaId = params['empresaId'] as String? ?? ctx['empresaId'] as String? ?? '';
      final result = await _resolver.resolveClient(query, empresaId: empresaId);
      if (result.isResolved) return ToolResult.success(result.selected);
      if (result.isAmbiguous) return ToolResult.ambiguous(result.candidates);
      return ToolResult.notFound('No encontré un cliente con nombre "$query".');
    },

    'inventory.getStockPorBodega': (params, ctx) async {
      final productoId = params['productoId'] as String? ?? '';
      final bodegaId = params['bodegaId'] as String? ?? ctx['selectedWarehouseId'] as String? ?? '';
      if (bodegaId.isEmpty) return ToolResult.askUser('¿En qué bodega querés consultar el stock?');
      final stockList = await _db.inventoryDao.getStockRealPorBodega(bodegaId);
      final item = stockList.where((s) => s.productoId == productoId).toList();
      final total = item.fold(0.0, (sum, s) => sum + s.cantidadActual);
      return ToolResult.success({'cantidad': total, 'bodegaId': bodegaId});
    },

    'inventory.getPrecioProducto': (params, ctx) async {
      final productoId = params['productoId'] as String? ?? '';
      final bodegaId = params['bodegaId'] as String? ?? ctx['selectedWarehouseId'] as String?;
      final producto = await _db.inventoryDao.getProductoById(productoId);
      if (producto == null) return ToolResult.notFound();
      final precios = await _db.inventoryDao.getPreciosProductoPorBodega(productoId);

      double? precio;
      String fuente = '';

      if (bodegaId != null) {
        final enBodega = precios
            .where((p) => p.bodegaId == bodegaId && (p.precioVenta ?? 0) > 0)
            .firstOrNull;
        if (enBodega != null) { precio = enBodega.precioVenta; fuente = 'bodega'; }
      }
      precio ??= (producto.precioBase != null && producto.precioBase! > 0)
          ? producto.precioBase
          : null;
      if (precio == producto.precioBase) fuente = 'precio base';
      if (precio == null && producto.ultimoPrecioVenta > 0) {
        precio = producto.ultimoPrecioVenta;
        fuente = 'último precio de venta';
      }

      return ToolResult.success({
        'precio': precio ?? 0,
        'fuente': fuente,
        'productoNombre': producto.nombre,
      });
    },

    'inventory.getHistorialProducto': (params, ctx) async {
      final productoId = params['productoId'] as String? ?? '';
      final bodegaId = params['bodegaId'] as String?;
      final historial = await _db.inventoryDao.getHistorialProducto(productoId, bodegaId);
      return ToolResult.success(historial);
    },

    // ── Ventas ────────────────────────────────────────────────────────────

    'sales.getVentasDelDia': (params, ctx) async {
      final bodegaIds = (params['bodegaIds'] as List?)?.cast<String>()
          ?? (ctx['allowedWarehouseIds'] as List?)?.cast<String>()
          ?? [];
      final stats = await _db.salesDao.getVentasDelDia(bodegaIds: bodegaIds);
      return ToolResult.success(stats);
    },

    'sales.getDeudaCliente': (params, ctx) async {
      final clienteId = params['clienteId'] as String? ?? '';
      final bodegaIds = (ctx['allowedWarehouseIds'] as List?)?.cast<String>() ?? [];
      final reporte = await _db.salesDao.getReceivablesReport(bodegaIds: bodegaIds);
      // Filtrar por cliente específico
      return ToolResult.success({
        'reporte': reporte,
        'clienteId': clienteId,
      });
    },

    'sales.getResumenDeudas': (params, ctx) async {
      final bodegaIds = (ctx['allowedWarehouseIds'] as List?)?.cast<String>() ?? [];
      final reporte = await _db.salesDao.getReceivablesReport(bodegaIds: bodegaIds);
      final total = await _db.salesDao.getMontoTotalFiados();
      return ToolResult.success({'reporte': reporte, 'totalFiados': total});
    },

    'sales.getEstadoCaja': (params, ctx) async {
      final sesion = await _db.salesDao.getCajaSesionActivaActual();
      if (sesion == null) return ToolResult.success({'cajaAbierta': false});
      final efectivo = await _db.salesDao.getVentasEfectivoSesion(sesion.id);
      final credito = await _db.salesDao.getVentasCreditoPendienteSesion(sesion.id);
      final ganancia = await _db.salesDao.getGananciaSesion(sesion.id);
      return ToolResult.success({
        'cajaAbierta': true,
        'sesionId': sesion.id,
        'ventasEfectivo': efectivo,
        'ventasCredito': credito,
        'ganancia': ganancia,
      });
    },

    // ── Use Cases (acciones con confirmación) ─────────────────────────────

    'usecase.registrarEntrada': (params, ctx) async {
      // Este tool no ejecuta directamente — señala que se necesita borrador
      // El StepwiseOrchestrator detecta este tipo y activa el flujo de borrador
      return ToolResult.success({
        '__requires_draft': true,
        '__draft_type': 'entry',
        'bodegaId': params['bodegaId'] ?? ctx['selectedWarehouseId'],
        'items': params['items'] ?? [],
      });
    },

    'usecase.registrarVenta': (params, ctx) async {
      return ToolResult.success({
        '__requires_draft': true,
        '__draft_type': 'sale',
        'cajaSesionId': ctx['openCashSessionId'],
        'items': params['items'] ?? [],
      });
    },
  };
}
```

---

## Paso 3 — ToolExecutor (fachada pública)

```dart
// lib/features/assistant/data/tools/tool_executor.dart

import '../domain/models/assistant_operational_context.dart';
import '../domain/models/conversation_state.dart';
import 'tool_registry.dart';
import 'tool_result.dart';

class ToolExecutor {
  final ToolRegistry _registry;

  const ToolExecutor({required ToolRegistry registry});

  Future<ToolResult> execute({
    required String toolId,
    required Map<String, dynamic> params,
    required AssistantOperationalContext operationalContext,
    required Map<String, CollectedVariable> collectedData,
  }) async {
    // Construir contexto operativo serializado para las tools
    final context = {
      'empresaId': operationalContext.empresaId,
      'usuarioId': operationalContext.usuarioId,
      'selectedWarehouseId': operationalContext.selectedWarehouseId,
      'allowedWarehouseIds': operationalContext.allowedWarehouseIds.toList(),
      'openCashSessionId': operationalContext.openCashSessionId,
    };

    // Resolver variables del CollectedData en los parámetros
    // Si un param tiene valor "$variableName", sustituir con el valor real
    final resolvedParams = _resolveParams(params, collectedData);

    return _registry.execute(toolId, resolvedParams, context);
  }

  /// Resuelve referencias a variables: "$productoId" → valor real de CollectedData
  Map<String, dynamic> _resolveParams(
    Map<String, dynamic> params,
    Map<String, CollectedVariable> collectedData,
  ) {
    return params.map((key, value) {
      if (value is String && value.startsWith(r'$')) {
        final varName = value.substring(1);
        // Manejar paths como "$resolvedProduct.id"
        if (varName.contains('.')) {
          final parts = varName.split('.');
          final variable = collectedData[parts[0]]?.value;
          if (variable != null && parts.length == 2) {
            try {
              return MapEntry(key, (variable as dynamic).toJson()[parts[1]]
                  ?? (variable as Map)[parts[1]]);
            } catch (_) {
              return MapEntry(key, null);
            }
          }
        }
        return MapEntry(key, collectedData[varName]?.value);
      }
      return MapEntry(key, value);
    });
  }
}
```

---

## Agregar nuevas tools

Para agregar soporte para un nuevo módulo (ej: proveedores, transferencias):

1. Agregar el método al DAO correspondiente si no existe
2. Agregar la entrada en `ToolRegistry._buildRegistry()`:
   ```dart
   'proveedores.getDeudaProveedor': (params, ctx) async {
     // llamada al DAO
   },
   ```
3. Agregar la fila en `assistant_tools_catalog` en Supabase con la descripción para el LLM
4. Listo. El sistema ya puede usar esa tool sin cambiar más código

---

## Criterio de cierre

- [ ] `ToolRegistry` registra todas las tools de inventario, ventas y entity resolver
- [ ] `ToolExecutor` resuelve variables `$varName` desde `CollectedData`
- [ ] `ToolResult` cubre los 5 estados posibles
- [ ] `ToolResult.toContext()` serializa datos de Drift para el LLM
- [ ] Tools de Use Cases señalan `__requires_draft: true` en lugar de ejecutar directamente
- [ ] Agregar nueva tool = una entrada en el registro + una fila en Supabase
