import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventario_v2/core/providers/drift_provider.dart';
import '../entity_resolver.dart';
import '../../domain/models/assistant_operational_context.dart';
import '../../domain/models/conversation_state.dart';
import 'tool_registry.dart';
import 'tool_result.dart';

class ToolExecutor {
  final ToolRegistry _registry;

  ToolExecutor({required ToolRegistry registry}) : _registry = registry;

  Future<ToolResult> execute({
    required String toolId,
    required Map<String, dynamic> params,
    required AssistantOperationalContext operationalContext,
    required Map<String, CollectedVariable> collectedData,
  }) async {
    final context = operationalContext.toContextMap();

    final resolvedParams = _resolveParams(params, collectedData);
    final warehouseValidation = _validateWarehouseScope(
      toolId: toolId,
      params: resolvedParams,
      operationalContext: operationalContext,
    );
    if (warehouseValidation != null) return warehouseValidation;

    return _registry.execute(toolId, resolvedParams, context);
  }

  ToolResult? _validateWarehouseScope({
    required String toolId,
    required Map<String, dynamic> params,
    required AssistantOperationalContext operationalContext,
  }) {
    final allowedIds = operationalContext.allowedWarehouseIds;
    if (allowedIds.isEmpty) {
      return ToolResult.error('No tenes bodegas asignadas para esta consulta.');
    }

    if (params['bodegaIds'] is List) {
      final bodegaIds = (params['bodegaIds'] as List).whereType<String>();
      final blocked = bodegaIds.where((id) => !allowedIds.contains(id));
      if (blocked.isNotEmpty) {
        return ToolResult.error('No tenes acceso a una de las bodegas solicitadas.');
      }
    }

    if (!_usesWarehouse(toolId)) return null;

    final explicitBodegaId = params['bodegaId'] as String?;
    final bodegaId = explicitBodegaId ?? operationalContext.selectedWarehouseId;

    if (bodegaId == null || bodegaId.isEmpty) {
      return ToolResult.askUser('En que bodega queres trabajar?');
    }

    if (!allowedIds.contains(bodegaId)) {
      return ToolResult.error('No tenes acceso a esa bodega.');
    }

    params['bodegaId'] = bodegaId;
    return null;
  }

  bool _usesWarehouse(String toolId) {
    return const {
      'inventory.getStockPorBodega',
      'inventory.getPrecioProducto',
      'inventory.getHistorialProducto',
      'usecase.registrarEntrada',
    }.contains(toolId);
  }

  Map<String, dynamic> _resolveParams(
    Map<String, dynamic> params,
    Map<String, CollectedVariable> collectedData,
  ) {
    return params.map((key, value) {
      if (value is String && value.startsWith(r'$')) {
        final varName = value.substring(1);
        if (varName.contains('.')) {
          final parts = varName.split('.');
          final variable = collectedData[parts[0]]?.value;
          if (variable != null && parts.length == 2) {
            try {
              final map = variable is Map
                  ? variable
                  : (variable as dynamic).toJson() as Map;
              return MapEntry(key, map[parts[1]]);
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

final toolExecutorProvider = Provider<ToolExecutor>((ref) {
  final db = ref.watch(driftDatabaseProvider);
  final resolver = EntityResolver(db);
  final registry = ToolRegistry(db, resolver);
  return ToolExecutor(registry: registry);
});
