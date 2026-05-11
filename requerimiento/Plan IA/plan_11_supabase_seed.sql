-- ============================================================
-- Plan 11 / E12 — Seed de Knowledge Base en Supabase
-- Secretario IA — inventario_v2
-- ============================================================
-- Ejecutar en el SQL Editor de Supabase, en orden.
-- Idempotente: usa INSERT ... ON CONFLICT DO UPDATE.
-- ============================================================


-- ──────────────────────────────────────────────────────────────
-- 1. CREAR TABLAS (si no existen)
-- ──────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS assistant_intent_catalog (
  id                   TEXT PRIMARY KEY,
  empresa_id           TEXT,
  display_name         TEXT NOT NULL,
  description          TEXT NOT NULL,
  workflow_id          TEXT NOT NULL,
  category             TEXT NOT NULL,
  requires_permissions TEXT[] DEFAULT '{}',
  requires_cash_open   BOOLEAN DEFAULT false,
  requires_warehouse   BOOLEAN DEFAULT false,
  active               BOOLEAN DEFAULT true,
  created_at           TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS assistant_workflows (
  id          TEXT PRIMARY KEY,
  nombre      TEXT NOT NULL,
  descripcion TEXT,
  definition  JSONB NOT NULL,
  version     INTEGER DEFAULT 1,
  active      BOOLEAN DEFAULT true,
  updated_at  TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS assistant_tools_catalog (
  id            TEXT PRIMARY KEY,
  description   TEXT NOT NULL,
  input_schema  JSONB NOT NULL,
  output_schema JSONB NOT NULL,
  category      TEXT NOT NULL,
  active        BOOLEAN DEFAULT true
);


-- ──────────────────────────────────────────────────────────────
-- 2. INTENT CATALOG — 12 intents (base + E12 nuevos)
-- ──────────────────────────────────────────────────────────────

INSERT INTO assistant_intent_catalog
  (id, display_name, description, workflow_id, category, requires_permissions, requires_warehouse, requires_cash_open)
VALUES

-- Consultas de inventario
('query_stock_product',
 'Consultar stock de producto',
 'Activar cuando el usuario pregunta cuántas unidades hay de un producto, cuánto stock tiene, si hay en inventario, cuánto queda, disponibilidad. Ejemplos: "cuánto hay de coca cola", "tengo camisa talla M", "stock de nike air", "cuánto me queda de harina".',
 'wf_query_stock', 'query', '{"product.read"}', true, false),

('query_price_product',
 'Consultar precio de producto',
 'Activar cuando el usuario pregunta el precio de un producto, cuánto cuesta, a qué precio está, el valor de algo. Ejemplos: "cuánto cuesta la coca cola", "precio del arroz", "a cómo está el azúcar", "qué precio tiene la camisa".',
 'wf_query_price', 'query', '{"product.read"}', false, false),

('query_historial_producto',
 'Historial de movimientos de un producto',
 'Activar cuando el usuario quiere ver los movimientos, entradas, salidas, o el historial de un producto específico. Ejemplos: "historial de coca cola", "movimientos del arroz este mes", "qué entradas tuvo la camisa", "cuándo fue la última entrada de harina".',
 'wf_query_historial', 'query', '{"product.read"}', false, false),

('query_top_productos',
 'Productos más vendidos',
 'Activar cuando el usuario pregunta cuáles productos se venden más, el ranking de ventas, los más populares, los que más rotan. Ejemplos: "qué es lo que más se vende", "top productos del mes", "cuáles son los más vendidos", "ranking de ventas".',
 'wf_query_top_productos', 'query', '{"sales.read"}', false, false),

-- Consultas de ventas y caja
('query_ventas_dia',
 'Resumen de ventas del día',
 'Activar cuando el usuario pregunta cuánto se vendió hoy, el total de ventas, cómo va el día, el resumen del día. Ejemplos: "cuánto se vendió hoy", "cómo va el día", "resumen de ventas", "total del día", "cuánto llevamos vendido".',
 'wf_query_ventas_dia', 'query', '{"sales.read"}', false, false),

('query_estado_caja',
 'Estado de la caja / sesión de caja',
 'Activar cuando el usuario pregunta si la caja está abierta, cuánto hay en caja, cómo va la caja, el efectivo en caja, el estado de la sesión de caja. Ejemplos: "cómo está la caja", "cuánto hay en efectivo", "la caja está abierta", "resumen de caja".',
 'wf_query_caja', 'query', '{"sales.read"}', false, false),

('query_deuda_cliente',
 'Deuda de un cliente específico',
 'Activar cuando el usuario pregunta cuánto debe un cliente específico, el fiado de alguien, la deuda de una persona. Ejemplos: "cuánto debe Juan", "fiado de María López", "deuda del cliente Pérez", "qué debe Pedro".',
 'wf_query_deuda_cliente', 'query', '{"sales.read"}', false, false),

('query_resumen_deudas',
 'Resumen general de deudas/fiados',
 'Activar cuando el usuario quiere ver todas las deudas, el total de fiados, quiénes deben, el listado de créditos pendientes. Ejemplos: "quiénes deben", "total de fiados", "resumen de deudas", "listado de créditos", "cuánto me deben en total".',
 'wf_query_resumen_deudas', 'query', '{"sales.read"}', false, false),

-- Acciones con borrador
('action_register_entry',
 'Registrar entrada de inventario',
 'Activar cuando el usuario quiere registrar mercadería que llegó, hacer una entrada al inventario, recibir productos, agregar stock. Ejemplos: "llegó mercadería", "vamos a hacer una entrada", "recibí 24 cajas de coca cola", "registrar entrada", "ingresaron productos".',
 'wf_register_entry', 'action', '{"warehouse.update"}', true, false),

('action_register_sale',
 'Registrar una venta',
 'Activar cuando el usuario quiere hacer una venta, cobrar algo, registrar que vendió un producto. Ejemplos: "vender 3 camisas", "cobrar al cliente", "registrar venta", "vendí 2 botellas de agua", "hacer una venta".',
 'wf_register_sale', 'action', '{"sales.create"}', true, true),

-- Utilidades
('greeting',
 'Saludo o conversación general',
 'Activar cuando el mensaje es un saludo, despedida, pregunta sobre el asistente mismo, agradecimiento, o conversación general sin intención de negocio. Ejemplos: "hola", "buenos días", "gracias", "qué podés hacer", "quién sos".',
 'wf_direct_answer', 'utility', '{}', false, false),

('unsupported_query',
 'Consulta fuera del dominio',
 'Activar cuando la pregunta no tiene relación con inventario, ventas, productos, stock ni caja. Cubre preguntas de clima, recetas, noticias, etc.',
 'wf_direct_answer', 'utility', '{}', false, false)

ON CONFLICT (id) DO UPDATE SET
  display_name         = EXCLUDED.display_name,
  description          = EXCLUDED.description,
  workflow_id          = EXCLUDED.workflow_id,
  category             = EXCLUDED.category,
  requires_permissions = EXCLUDED.requires_permissions,
  requires_warehouse   = EXCLUDED.requires_warehouse,
  requires_cash_open   = EXCLUDED.requires_cash_open,
  active               = EXCLUDED.active;


-- ──────────────────────────────────────────────────────────────
-- 3. WORKFLOWS
-- ──────────────────────────────────────────────────────────────

INSERT INTO assistant_workflows (id, nombre, descripcion, definition)
VALUES

-- wf_direct_answer: respuesta directa sin tools
('wf_direct_answer', 'Respuesta directa', 'Saludo, preguntas generales, unsupported',
 '{
   "id": "wf_direct_answer",
   "nombre": "Respuesta directa",
   "type": "query",
   "session_accumulates": false,
   "required_fields": [],
   "steps": []
 }'::jsonb),

-- wf_query_stock
('wf_query_stock', 'Consultar stock de producto', 'Consulta stock real desde Drift',
 '{
   "id": "wf_query_stock",
   "nombre": "Consultar stock de producto",
   "type": "query",
   "session_accumulates": false,
   "required_fields": [
     {"name": "productQuery", "question": "¿De qué producto querés saber el stock?", "type": "string"}
   ],
   "steps": [
     {
       "id": "resolve_product",
       "tool": "entity_resolver.resolveProduct",
       "params": {"query": "$productQuery"},
       "store_result_as": "resolvedProduct",
       "on_ambiguous": "ask_user_to_select",
       "on_not_found": "answer_not_found"
     },
     {
       "id": "get_stock",
       "tool": "inventory.getStockPorBodega",
       "params": {"productoId": "$resolvedProduct.id", "bodegaId": "$context.selectedWarehouseId"},
       "store_result_as": "stockData"
     }
   ]
 }'::jsonb),

-- wf_query_price
('wf_query_price', 'Consultar precio de producto', 'Consulta precio desde Drift',
 '{
   "id": "wf_query_price",
   "nombre": "Consultar precio de producto",
   "type": "query",
   "session_accumulates": false,
   "required_fields": [
     {"name": "productQuery", "question": "¿De qué producto querés saber el precio?", "type": "string"}
   ],
   "steps": [
     {
       "id": "resolve_product",
       "tool": "entity_resolver.resolveProduct",
       "params": {"query": "$productQuery"},
       "store_result_as": "resolvedProduct",
       "on_ambiguous": "ask_user_to_select",
       "on_not_found": "answer_not_found"
     },
     {
       "id": "get_price",
       "tool": "inventory.getPrecioProducto",
       "params": {"productoId": "$resolvedProduct.id"},
       "store_result_as": "precioData"
     }
   ]
 }'::jsonb),

-- wf_query_historial
('wf_query_historial', 'Historial de movimientos', 'Movimientos de un producto',
 '{
   "id": "wf_query_historial",
   "nombre": "Historial de movimientos de producto",
   "type": "query",
   "session_accumulates": false,
   "required_fields": [
     {"name": "productQuery", "question": "¿De qué producto querés ver el historial?", "type": "string"}
   ],
   "steps": [
     {
       "id": "resolve_product",
       "tool": "entity_resolver.resolveProduct",
       "params": {"query": "$productQuery"},
       "store_result_as": "resolvedProduct",
       "on_ambiguous": "ask_user_to_select",
       "on_not_found": "answer_not_found"
     },
     {
       "id": "get_historial",
       "tool": "inventory.getHistorialProducto",
       "params": {"productoId": "$resolvedProduct.id"},
       "store_result_as": "historialData"
     }
   ]
 }'::jsonb),

-- wf_query_top_productos
('wf_query_top_productos', 'Top productos más vendidos', 'Ranking de ventas',
 '{
   "id": "wf_query_top_productos",
   "nombre": "Top productos más vendidos",
   "type": "query",
   "session_accumulates": false,
   "required_fields": [],
   "steps": [
     {
       "id": "get_ventas",
       "tool": "sales.getVentasDelDia",
       "params": {},
       "store_result_as": "ventasData"
     }
   ]
 }'::jsonb),

-- wf_query_ventas_dia
('wf_query_ventas_dia', 'Resumen de ventas del día', 'Total vendido hoy',
 '{
   "id": "wf_query_ventas_dia",
   "nombre": "Resumen de ventas del día",
   "type": "query",
   "session_accumulates": false,
   "required_fields": [],
   "steps": [
     {
       "id": "get_ventas",
       "tool": "sales.getVentasDelDia",
       "params": {},
       "store_result_as": "ventasData"
     }
   ]
 }'::jsonb),

-- wf_query_caja
('wf_query_caja', 'Estado de caja', 'Sesión de caja activa',
 '{
   "id": "wf_query_caja",
   "nombre": "Estado de la caja",
   "type": "query",
   "session_accumulates": false,
   "required_fields": [],
   "steps": [
     {
       "id": "get_caja",
       "tool": "sales.getEstadoCaja",
       "params": {},
       "store_result_as": "cajaData"
     }
   ]
 }'::jsonb),

-- wf_query_deuda_cliente
('wf_query_deuda_cliente', 'Deuda de un cliente', 'Fiado de cliente específico',
 '{
   "id": "wf_query_deuda_cliente",
   "nombre": "Deuda de un cliente",
   "type": "query",
   "session_accumulates": false,
   "required_fields": [
     {"name": "clientQuery", "question": "¿De qué cliente querés ver la deuda?", "type": "string"}
   ],
   "steps": [
     {
       "id": "resolve_client",
       "tool": "entity_resolver.resolveClient",
       "params": {"query": "$clientQuery"},
       "store_result_as": "resolvedClient",
       "on_ambiguous": "ask_user_to_select",
       "on_not_found": "answer_not_found"
     },
     {
       "id": "get_deuda",
       "tool": "sales.getDeudaCliente",
       "params": {"clienteId": "$resolvedClient.id"},
       "store_result_as": "deudaData"
     }
   ]
 }'::jsonb),

-- wf_query_resumen_deudas
('wf_query_resumen_deudas', 'Resumen general de deudas', 'Todos los fiados',
 '{
   "id": "wf_query_resumen_deudas",
   "nombre": "Resumen general de deudas",
   "type": "query",
   "session_accumulates": false,
   "required_fields": [],
   "steps": [
     {
       "id": "get_deudas",
       "tool": "sales.getResumenDeudas",
       "params": {},
       "store_result_as": "deudasData"
     }
   ]
 }'::jsonb),

-- wf_register_entry
('wf_register_entry', 'Registrar entrada de inventario', 'Flujo con borrador',
 '{
   "id": "wf_register_entry",
   "nombre": "Registrar entrada de inventario",
   "type": "action",
   "session_accumulates": false,
   "required_fields": [
     {"name": "productQuery", "question": "¿Qué producto vas a ingresar?", "type": "string"},
     {"name": "quantity", "question": "¿Cuántas unidades?", "type": "number"}
   ],
   "steps": [
     {
       "id": "resolve_product",
       "tool": "entity_resolver.resolveProduct",
       "params": {"query": "$productQuery"},
       "store_result_as": "resolvedProduct",
       "on_ambiguous": "ask_user_to_select",
       "on_not_found": "answer_not_found"
     },
     {
       "id": "prepare_entry",
       "tool": "usecase.registrarEntrada",
       "params": {
         "items": [{"productoId": "$resolvedProduct.id", "cantidad": "$quantity"}]
       },
       "store_result_as": "draftData"
     }
   ]
 }'::jsonb),

-- wf_register_sale
('wf_register_sale', 'Registrar venta', 'Flujo de venta con borrador',
 '{
   "id": "wf_register_sale",
   "nombre": "Registrar venta",
   "type": "action",
   "session_accumulates": false,
   "required_fields": [
     {"name": "productQuery", "question": "¿Qué producto vas a vender?", "type": "string"},
     {"name": "quantity", "question": "¿Cuántas unidades?", "type": "number"}
   ],
   "steps": [
     {
       "id": "resolve_product",
       "tool": "entity_resolver.resolveProduct",
       "params": {"query": "$productQuery"},
       "store_result_as": "resolvedProduct",
       "on_ambiguous": "ask_user_to_select",
       "on_not_found": "answer_not_found"
     },
     {
       "id": "get_price",
       "tool": "inventory.getPrecioProducto",
       "params": {"productoId": "$resolvedProduct.id"},
       "store_result_as": "precioData"
     },
     {
       "id": "prepare_sale",
       "tool": "usecase.registrarVenta",
       "params": {
         "items": [{"productoId": "$resolvedProduct.id", "cantidad": "$quantity"}]
       },
       "store_result_as": "draftData"
     }
   ]
 }'::jsonb)

ON CONFLICT (id) DO UPDATE SET
  nombre      = EXCLUDED.nombre,
  descripcion = EXCLUDED.descripcion,
  definition  = EXCLUDED.definition,
  version     = assistant_workflows.version + 1,
  updated_at  = now();


-- ──────────────────────────────────────────────────────────────
-- 4. TOOLS CATALOG — 9 tools del ToolRegistry
-- ──────────────────────────────────────────────────────────────

INSERT INTO assistant_tools_catalog (id, description, input_schema, output_schema, category)
VALUES

('entity_resolver.resolveProduct',
 'Busca un producto por nombre, código o descripción parcial. Devuelve el producto exacto o una lista de candidatos si hay ambigüedad.',
 '{"query": "string (requerido) — nombre o código del producto", "empresaId": "string (opcional)"}',
 '{"status": "resolved | ambiguous | notFound", "selected": "Producto | null", "candidates": "Producto[]"}',
 'entity'),

('entity_resolver.resolveClient',
 'Busca un cliente por nombre. Devuelve el cliente exacto o candidatos si hay ambigüedad.',
 '{"query": "string (requerido) — nombre del cliente", "empresaId": "string (opcional)"}',
 '{"status": "resolved | ambiguous | notFound", "selected": "Cliente | null", "candidates": "Cliente[]"}',
 'entity'),

('inventory.getStockPorBodega',
 'Obtiene el stock actual de un producto en una bodega específica. Suma todas las variantes.',
 '{"productoId": "string (requerido)", "bodegaId": "string (requerido)"}',
 '{"cantidad": "number — total de unidades disponibles", "bodegaId": "string"}',
 'inventory'),

('inventory.getPrecioProducto',
 'Obtiene el precio de venta de un producto. Prioriza precio de bodega, luego precio base, luego último precio de venta.',
 '{"productoId": "string (requerido)", "bodegaId": "string (opcional)"}',
 '{"precio": "number", "fuente": "string — bodega | precio base | último precio", "productoNombre": "string"}',
 'inventory'),

('inventory.getHistorialProducto',
 'Obtiene el historial de movimientos (entradas y salidas) de un producto. Máx 50 registros recientes.',
 '{"productoId": "string (requerido)", "bodegaId": "string (opcional)"}',
 '{"movimientos": "array de movimientos con fecha, tipo, cantidad y referencia"}',
 'inventory'),

('sales.getVentasDelDia',
 'Devuelve el total de ventas del día actual. Si se pasa bodegaIds filtra por esas bodegas.',
 '{"bodegaIds": "string[] (opcional)"}',
 '{"totalVentas": "number — suma de todas las ventas del día"}',
 'sales'),

('sales.getEstadoCaja',
 'Devuelve el estado actual de la sesión de caja: si está abierta, efectivo, crédito y ganancia del turno.',
 '{}',
 '{"cajaAbierta": "boolean", "sesionId": "string | null", "ventasEfectivo": "number", "ventasCredito": "number", "ganancia": "number"}',
 'sales'),

('sales.getDeudaCliente',
 'Obtiene el monto adeudado por un cliente específico (ventas al fiado no cobradas).',
 '{"clienteId": "string (requerido)"}',
 '{"reporte": "array de ventas pendientes del cliente", "clienteId": "string"}',
 'sales'),

('sales.getResumenDeudas',
 'Devuelve el resumen de todos los fiados pendientes: quiénes deben y cuánto.',
 '{}',
 '{"reporte": "array con clientes y montos adeudados", "totalFiados": "number — suma total de fiados"}',
 'sales'),

('usecase.registrarEntrada',
 'Prepara un borrador de entrada de inventario. NO ejecuta directamente — activa el flujo de confirmación. El usuario debe revisar y confirmar antes de que se aplique al stock.',
 '{"bodegaId": "string (requerido)", "items": "array de {productoId, cantidad, costo}"}',
 '{"__requires_draft": true, "__draft_type": "entry", "bodegaId": "string", "items": "array"}',
 'usecase'),

('usecase.registrarVenta',
 'Prepara un borrador de venta. NO ejecuta directamente — activa el flujo de confirmación. Requiere caja abierta.',
 '{"cajaSesionId": "string (requerido)", "items": "array de {productoId, cantidad, precio}"}',
 '{"__requires_draft": true, "__draft_type": "sale", "cajaSesionId": "string", "items": "array"}',
 'usecase')

ON CONFLICT (id) DO UPDATE SET
  description   = EXCLUDED.description,
  input_schema  = EXCLUDED.input_schema,
  output_schema = EXCLUDED.output_schema,
  category      = EXCLUDED.category,
  active        = EXCLUDED.active;


-- ──────────────────────────────────────────────────────────────
-- 5. VERIFICACIÓN FINAL
-- ──────────────────────────────────────────────────────────────

-- Ejecutar para confirmar que todo se insertó correctamente:
SELECT 'intent_catalog' AS tabla, count(*) AS filas FROM assistant_intent_catalog WHERE active = true
UNION ALL
SELECT 'workflows', count(*) FROM assistant_workflows WHERE active = true
UNION ALL
SELECT 'tools_catalog', count(*) FROM assistant_tools_catalog WHERE active = true;
