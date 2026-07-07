import 'dart:convert';

import 'package:inventario_v2/core/db/app_database.dart';
import 'package:inventario_v2/features/secretary/domain/models/assistant_operational_context.dart';

import '../data/llm/secretary_llm_models.dart';
import 'draft_engine.dart';

/// Schemas de las herramientas de borrador expuestas al LLM.
/// El borrador NUNCA se ejecuta por tool: la confirmación es siempre un
/// tap/"sí" explícito del usuario en la tarjeta (Req-15).
const List<SecToolDef> secretaryDraftTools = [
  SecToolDef(
    toolId: 'draft.create',
    description:
        'Crea un borrador (tabla temporal) para acumular ítems dictados. '
        'Tipos: "entrada" (ingreso de stock) o "venta". Úsala cuando el '
        'usuario quiera registrar una entrada de productos o una venta.',
    parameters: {
      'type': 'object',
      'properties': {
        'tipo': {
          'type': 'string',
          'enum': ['entrada', 'venta'],
        },
        'bodegaId': {
          'type': 'string',
          'description': 'Bodega destino/origen. Omitir para usar la activa.',
        },
        'clienteNombre': {
          'type': 'string',
          'description': 'Solo ventas: nombre del cliente (obligatorio si es fiado).',
        },
        'saleType': {
          'type': 'string',
          'enum': ['Contado', 'Fiado'],
          'description': 'Solo ventas. Default: Contado.',
        },
        'descripcion': {
          'type': 'string',
          'description': 'Solo entradas: referencia del movimiento.',
        },
      },
      'required': ['tipo'],
    },
  ),
  SecToolDef(
    toolId: 'draft.addItems',
    description:
        'Agrega ítems al borrador activo. Cada ítem se resuelve contra el '
        'catálogo: si es ambiguo o no se encuentra queda en revisión sin '
        'frenar el flujo. Devuelve el estado de cada ítem con su itemId.',
    parameters: {
      'type': 'object',
      'properties': {
        'draftId': {
          'type': 'string',
          'description': 'Omitir para usar el borrador activo de la sesión.',
        },
        'items': {
          'type': 'array',
          'items': {
            'type': 'object',
            'properties': {
              'nombre': {'type': 'string'},
              'cantidad': {'type': 'number'},
              'costoUnitario': {
                'type': 'number',
                'description': 'Costo de compra (entradas).',
              },
              'precioUnitario': {
                'type': 'number',
                'description': 'Precio de venta.',
              },
            },
            'required': ['nombre', 'cantidad'],
          },
        },
      },
      'required': ['items'],
    },
  ),
  SecToolDef(
    toolId: 'draft.updateItem',
    description:
        'Corrige un ítem del borrador (cantidad, costo, precio) o resuelve '
        'una ambigüedad asignando el productoId elegido por el usuario.',
    parameters: {
      'type': 'object',
      'properties': {
        'itemId': {'type': 'string'},
        'cantidad': {'type': 'number'},
        'costoUnitario': {'type': 'number'},
        'precioUnitario': {'type': 'number'},
        'productoId': {
          'type': 'string',
          'description': 'Id del producto elegido entre los candidatos.',
        },
      },
      'required': ['itemId'],
    },
  ),
  SecToolDef(
    toolId: 'draft.removeItem',
    description: 'Elimina un ítem del borrador.',
    parameters: {
      'type': 'object',
      'properties': {
        'itemId': {'type': 'string'},
      },
      'required': ['itemId'],
    },
  ),
  SecToolDef(
    toolId: 'draft.setHeader',
    description:
        'Actualiza datos generales del borrador: bodega, cliente, tipo de '
        'venta (Contado/Fiado) o descripción.',
    parameters: {
      'type': 'object',
      'properties': {
        'draftId': {'type': 'string'},
        'bodegaId': {'type': 'string'},
        'clienteNombre': {'type': 'string'},
        'saleType': {
          'type': 'string',
          'enum': ['Contado', 'Fiado'],
        },
        'descripcion': {'type': 'string'},
      },
    },
  ),
  SecToolDef(
    toolId: 'draft.getState',
    description:
        'Devuelve el estado completo del borrador activo: ítems con sus '
        'itemId, estados, totales y errores de validación pendientes.',
    parameters: {
      'type': 'object',
      'properties': {
        'draftId': {'type': 'string'},
      },
    },
  ),
];

/// Ejecuta las tools `draft.*` dentro del turno. Las demás tools se delegan
/// al ToolExecutor del registry (devuelve null si el toolId no es de draft).
class DraftToolHandler {
  final DraftEngine _engine;
  final AppDatabase _db;
  final String sessionId;
  final AssistantOperationalContext context;

  /// Bodega preferida en AiPreferences (fallback antes de la activa).
  final String? defaultBodegaId;

  /// Último borrador tocado en el turno (para adjuntar la tarjeta al mensaje).
  String? lastDraftId;

  DraftToolHandler({
    required DraftEngine engine,
    required AppDatabase db,
    required this.sessionId,
    required this.context,
    this.defaultBodegaId,
  })  : _engine = engine,
        _db = db;

  Future<Map<String, dynamic>?> handle(
    String toolId,
    Map<String, dynamic> params,
  ) async {
    if (!toolId.startsWith('draft.')) return null;
    try {
      return switch (toolId) {
        'draft.create' => await _create(params),
        'draft.addItems' => await _addItems(params),
        'draft.updateItem' => await _updateItem(params),
        'draft.removeItem' => await _removeItem(params),
        'draft.setHeader' => await _setHeader(params),
        'draft.getState' => await _getState(params),
        _ => {'status': 'error', 'error': 'Tool "$toolId" no registrada.'},
      };
    } catch (e) {
      return {'status': 'error', 'error': e.toString()};
    }
  }

  Future<String?> _resolveDraftId(Map<String, dynamic> params) async {
    final explicit = params['draftId'] as String?;
    if (explicit != null && explicit.isNotEmpty) return explicit;
    if (lastDraftId != null) return lastDraftId;
    final active = await _db.secretaryDao.getActiveDraftForSession(sessionId);
    return active?.id;
  }

  Future<Map<String, dynamic>> _create(Map<String, dynamic> params) async {
    final tipo = params['tipo'] as String? ?? '';
    if (!_engine.supportsType(tipo)) {
      return {'status': 'error', 'error': 'Tipo de borrador inválido: $tipo'};
    }
    final bodegaId = (params['bodegaId'] as String?) ??
        defaultBodegaId ??
        context.selectedWarehouseId;
    if (bodegaId != null && !context.canAccessWarehouse(bodegaId)) {
      return {'status': 'error', 'error': 'No tenés acceso a esa bodega.'};
    }
    final draft = await _engine.createDraft(
      draftType: tipo,
      sessionId: sessionId,
      bodegaId: bodegaId,
      clienteNombre: params['clienteNombre'] as String?,
      saleType: params['saleType'] as String?,
      descripcion: params['descripcion'] as String?,
    );
    lastDraftId = draft.id;
    return {
      'status': 'success',
      'data': {
        'draftId': draft.id,
        'tipo': tipo,
        'bodegaId': bodegaId,
        'nota':
            'Borrador creado. El usuario ve la tabla en pantalla y debe '
            'confirmar manualmente para ejecutar.',
      },
    };
  }

  Future<Map<String, dynamic>> _addItems(Map<String, dynamic> params) async {
    final draftId = await _resolveDraftId(params);
    if (draftId == null) {
      return {
        'status': 'error',
        'error': 'No hay borrador activo. Usa draft__create primero.',
      };
    }
    lastDraftId = draftId;

    final rawList = (params['items'] as List? ?? const [])
        .whereType<Map>()
        .map((m) => RawDraftItem.fromJson(Map<String, dynamic>.from(m)))
        .toList();
    if (rawList.isEmpty) {
      return {'status': 'error', 'error': 'Lista de ítems vacía.'};
    }

    final inserted = await _engine.addItems(
      draftId: draftId,
      rawItems: rawList,
      context: context,
    );
    return {
      'status': 'success',
      'data': {
        'draftId': draftId,
        'items': [for (final i in inserted) _itemToMap(i)],
      },
    };
  }

  Future<Map<String, dynamic>> _updateItem(Map<String, dynamic> params) async {
    final itemId = params['itemId'] as String? ?? '';
    await _engine.updateItem(
      itemId,
      cantidad: (params['cantidad'] as num?)?.toDouble(),
      costoUnitario: (params['costoUnitario'] as num?)?.toDouble(),
      precioUnitario: (params['precioUnitario'] as num?)?.toDouble(),
      productoId: params['productoId'] as String?,
      resolvedName: null,
    );
    return {'status': 'success', 'data': {'itemId': itemId}};
  }

  Future<Map<String, dynamic>> _removeItem(Map<String, dynamic> params) async {
    final itemId = params['itemId'] as String? ?? '';
    await _engine.removeItem(itemId);
    return {'status': 'success', 'data': {'itemId': itemId}};
  }

  Future<Map<String, dynamic>> _setHeader(Map<String, dynamic> params) async {
    final draftId = await _resolveDraftId(params);
    if (draftId == null) {
      return {'status': 'error', 'error': 'No hay borrador activo.'};
    }
    lastDraftId = draftId;
    final bodegaId = params['bodegaId'] as String?;
    if (bodegaId != null && !context.canAccessWarehouse(bodegaId)) {
      return {'status': 'error', 'error': 'No tenés acceso a esa bodega.'};
    }
    await _engine.setHeader(
      draftId,
      bodegaId: bodegaId,
      clienteNombre: params['clienteNombre'] as String?,
      saleType: params['saleType'] as String?,
      descripcion: params['descripcion'] as String?,
    );
    return {'status': 'success', 'data': {'draftId': draftId}};
  }

  Future<Map<String, dynamic>> _getState(Map<String, dynamic> params) async {
    final draftId = await _resolveDraftId(params);
    if (draftId == null) {
      return {'status': 'error', 'error': 'No hay borrador activo.'};
    }
    lastDraftId = draftId;
    final draft = await _db.secretaryDao.getDraftById(draftId);
    if (draft == null) {
      return {'status': 'error', 'error': 'El borrador no existe.'};
    }
    final items = await _db.secretaryDao.getDraftItems(draftId);
    final errores = await _engine.validate(draftId);
    return {
      'status': 'success',
      'data': {
        'draftId': draft.id,
        'tipo': draft.draftType,
        'estado': draft.status,
        'bodegaId': draft.bodegaId,
        'meta': draft.metaJson != null ? jsonDecode(draft.metaJson!) : null,
        'items': [for (final i in items) _itemToMap(i)],
        'total': items.fold<double>(
          0,
          (sum, i) => sum + i.quantity * (i.unitPrice ?? i.unitCost ?? 0),
        ),
        'erroresValidacion': errores,
      },
    };
  }

  Map<String, dynamic> _itemToMap(SecretaryDraftItem i) => {
        'itemId': i.id,
        'nombrePropuesto': i.proposedName,
        'nombreResuelto': i.resolvedName,
        'productoId': i.productId,
        'cantidad': i.quantity,
        'costoUnitario': i.unitCost,
        'precioUnitario': i.unitPrice,
        'estado': i.status,
        if (i.candidatesJson != null)
          'candidatos': jsonDecode(i.candidatesJson!),
      };
}
