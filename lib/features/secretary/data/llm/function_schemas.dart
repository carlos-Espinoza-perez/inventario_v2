import 'secretary_llm_models.dart';

/// Schemas JSON de las herramientas del ToolRegistry existente expuestas al
/// modelo vía function calling. F1: solo herramientas de lectura.
///
/// Los toolId coinciden con los del registry
/// (lib/features/secretary/data/tools/tool_registry.dart); el nombre API
/// reemplaza puntos por '__' porque OpenAI no admite puntos.
const List<SecToolDef> secretaryReadOnlyTools = [
  SecToolDef(
    toolId: 'entity_resolver.resolveProduct',
    description:
        'Busca un producto del catálogo por nombre o descripción parcial. '
        'Úsala SIEMPRE antes de consultar stock, precio o historial para '
        'obtener el productoId real. Puede devolver candidatos si es ambiguo.',
    parameters: {
      'type': 'object',
      'properties': {
        'query': {
          'type': 'string',
          'description': 'Nombre o descripción del producto tal como lo dijo el usuario',
        },
      },
      'required': ['query'],
    },
  ),
  SecToolDef(
    toolId: 'entity_resolver.resolveClient',
    description:
        'Busca un cliente por nombre. Úsala antes de consultar deudas de un '
        'cliente específico para obtener su clienteId.',
    parameters: {
      'type': 'object',
      'properties': {
        'query': {
          'type': 'string',
          'description': 'Nombre del cliente',
        },
      },
      'required': ['query'],
    },
  ),
  SecToolDef(
    toolId: 'inventory.getStockPorBodega',
    description:
        'Consulta el stock de una bodega. Con productoId devuelve la cantidad '
        'de ese producto; sin productoId devuelve el listado (top 20) de '
        'productos con existencias.',
    parameters: {
      'type': 'object',
      'properties': {
        'productoId': {
          'type': 'string',
          'description': 'Id del producto (obtenido con entity_resolver__resolveProduct). Omitir para listado general.',
        },
        'bodegaId': {
          'type': 'string',
          'description': 'Id de la bodega. Omitir para usar la bodega activa del usuario.',
        },
      },
    },
  ),
  SecToolDef(
    toolId: 'inventory.getPrecioProducto',
    description: 'Consulta el precio de venta vigente de un producto.',
    parameters: {
      'type': 'object',
      'properties': {
        'productoId': {
          'type': 'string',
          'description': 'Id del producto (obtenido con entity_resolver__resolveProduct)',
        },
        'bodegaId': {
          'type': 'string',
          'description': 'Id de la bodega. Omitir para usar la bodega activa.',
        },
      },
      'required': ['productoId'],
    },
  ),
  SecToolDef(
    toolId: 'inventory.getHistorialProducto',
    description:
        'Consulta los movimientos históricos (entradas/salidas) de un producto.',
    parameters: {
      'type': 'object',
      'properties': {
        'productoId': {
          'type': 'string',
          'description': 'Id del producto (obtenido con entity_resolver__resolveProduct)',
        },
        'bodegaId': {
          'type': 'string',
          'description': 'Id de la bodega. Omitir para usar la bodega activa.',
        },
      },
      'required': ['productoId'],
    },
  ),
  SecToolDef(
    toolId: 'sales.getVentasDelDia',
    description: 'Total de ventas del día de hoy.',
    parameters: {
      'type': 'object',
      'properties': {
        'bodegaIds': {
          'type': 'array',
          'items': {'type': 'string'},
          'description': 'Ids de bodegas a incluir. Omitir para todas las visibles.',
        },
      },
    },
  ),
  SecToolDef(
    toolId: 'sales.getDeudaCliente',
    description:
        'Deuda (fiado) pendiente de un cliente específico.',
    parameters: {
      'type': 'object',
      'properties': {
        'clienteId': {
          'type': 'string',
          'description': 'Id del cliente (obtenido con entity_resolver__resolveClient)',
        },
      },
      'required': ['clienteId'],
    },
  ),
  SecToolDef(
    toolId: 'sales.getResumenDeudas',
    description:
        'Resumen de fiados: monto total adeudado y cantidad de clientes con deuda.',
    parameters: {'type': 'object', 'properties': {}},
  ),
  SecToolDef(
    toolId: 'sales.getEstadoCaja',
    description:
        'Estado de la caja actual: si está abierta, ventas en efectivo, '
        'crédito pendiente y ganancia de la sesión.',
    parameters: {'type': 'object', 'properties': {}},
  ),
];
