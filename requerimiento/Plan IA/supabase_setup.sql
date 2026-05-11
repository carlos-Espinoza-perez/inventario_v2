-- ============================================================
-- SECRETARIO IA — Setup de Knowledge Base en Supabase
-- Ejecutar en: Supabase Dashboard → SQL Editor → New query
-- ============================================================


-- ============================================================
-- 1. TABLAS
-- ============================================================

CREATE TABLE IF NOT EXISTS assistant_intent_catalog (
  id                    TEXT PRIMARY KEY,
  empresa_id            TEXT,
  display_name          TEXT NOT NULL,
  description           TEXT NOT NULL,
  workflow_id           TEXT NOT NULL,
  category              TEXT NOT NULL CHECK (category IN ('query', 'action', 'utility')),
  requires_permissions  TEXT[] DEFAULT '{}',
  requires_cash_open    BOOLEAN DEFAULT false,
  requires_warehouse    BOOLEAN DEFAULT false,
  active                BOOLEAN DEFAULT true,
  created_at            TIMESTAMPTZ DEFAULT now()
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
  category      TEXT NOT NULL CHECK (category IN ('inventory', 'sales', 'entity', 'llm', 'usecase', 'session', 'draft')),
  active        BOOLEAN DEFAULT true
);


-- ============================================================
-- 2. INTENT CATALOG — 7 intents iniciales
-- ============================================================

INSERT INTO assistant_intent_catalog
  (id, display_name, description, workflow_id, category, requires_permissions, requires_warehouse)
VALUES
  (
    'query_stock_product',
    'Consultar stock de producto',
    'Activar cuando el usuario pregunta cuántas unidades hay de un producto, cuánto stock tiene, si hay en inventario, cuánto queda, disponibilidad. Ejemplos: "cuánto hay de coca cola", "tengo camisa talla M", "stock de nike air", "queda algo de arroz".',
    'wf_query_stock',
    'query',
    ARRAY['product.read'],
    true
  ),
  (
    'query_product_price',
    'Consultar precio de producto',
    'Activar cuando el usuario pregunta el precio de un producto, cuánto cuesta, cuál es el valor, precio de venta. Ejemplos: "cuánto cuesta la coca cola", "precio del arroz", "a cuánto está la camisa".',
    'wf_query_price',
    'query',
    ARRAY['product.read'],
    false
  ),
  (
    'query_sales_today',
    'Consultar ventas del día',
    'Activar cuando el usuario pregunta por las ventas de hoy, cuánto se vendió, resumen del día, total de ventas. Ejemplos: "cuánto vendimos hoy", "ventas del día", "cómo va el día", "resumen de ventas".',
    'wf_query_sales_today',
    'query',
    ARRAY['sales.read'],
    false
  ),
  (
    'query_cash_status',
    'Consultar estado de caja',
    'Activar cuando el usuario pregunta por el estado de la caja, si está abierta, cuánto hay en caja, saldo actual, efectivo en caja. Ejemplos: "cómo está la caja", "cuánto hay en caja", "estado de la caja", "saldo de caja".',
    'wf_query_cash',
    'query',
    ARRAY['cash.read'],
    false
  ),
  (
    'action_register_entry',
    'Registrar entrada de inventario',
    'Activar cuando el usuario quiere registrar mercadería que llegó, hacer una entrada, recibir productos, agregar stock. Ejemplos: "llegó mercadería", "vamos a hacer una entrada", "recibí 24 cajas de coca cola", "quiero registrar una entrada".',
    'wf_register_entry',
    'action',
    ARRAY['warehouse.update'],
    true
  ),
  (
    'action_register_sale',
    'Registrar venta',
    'Activar cuando el usuario quiere registrar una venta, vender un producto, hacer una factura, cobrar. Ejemplos: "quiero registrar una venta", "vendí 3 unidades de arroz", "hacer una venta", "cobrar al cliente".',
    'wf_register_sale',
    'action',
    ARRAY['sales.create'],
    false
  ),
  (
    'greeting',
    'Saludo o pregunta general',
    'Activar cuando el mensaje es un saludo, despedida, pregunta sobre el asistente, agradecimiento, o conversación general sin intención de negocio específica. Ejemplos: "hola", "gracias", "qué puedes hacer", "buenos días".',
    'wf_direct_answer',
    'utility',
    ARRAY[]::TEXT[],
    false
  )
ON CONFLICT (id) DO UPDATE SET
  display_name         = EXCLUDED.display_name,
  description          = EXCLUDED.description,
  workflow_id          = EXCLUDED.workflow_id,
  requires_permissions = EXCLUDED.requires_permissions,
  requires_warehouse   = EXCLUDED.requires_warehouse;


-- ============================================================
-- 3. WORKFLOWS
-- ============================================================

INSERT INTO assistant_workflows (id, nombre, descripcion, definition) VALUES

-- Consultar stock
('wf_query_stock', 'Consultar stock de producto', 'Busca un producto y devuelve su stock en la bodega activa', '{
  "id": "wf_query_stock",
  "nombre": "Consultar stock de producto",
  "type": "query",
  "session_accumulates": false,
  "required_fields": [
    { "name": "productQuery", "question": "¿De qué producto querés saber el stock?", "type": "string" }
  ],
  "steps": [
    {
      "id": "resolve_product",
      "tool": "entity_resolver.resolveProduct",
      "params": { "query": "$productQuery", "empresaId": "$context.empresaId" },
      "store_result_as": "resolvedProduct",
      "on_ambiguous": "ask_user_to_select",
      "on_not_found": "answer_not_found"
    },
    {
      "id": "get_stock",
      "tool": "inventory.getStockPorBodega",
      "params": { "productoId": "$resolvedProduct.id", "bodegaId": "$context.selectedWarehouseId" },
      "store_result_as": "stockData"
    },
    {
      "id": "generate_response",
      "tool": "llm.generateAnswer",
      "params": {
        "data": ["$resolvedProduct", "$stockData"],
        "instruction": "Responde con el stock actual del producto de forma clara y concisa. Si el stock es 0, indícalo claramente."
      }
    }
  ]
}'),

-- Consultar precio
('wf_query_price', 'Consultar precio de producto', 'Busca un producto y devuelve su precio de venta', '{
  "id": "wf_query_price",
  "nombre": "Consultar precio de producto",
  "type": "query",
  "session_accumulates": false,
  "required_fields": [
    { "name": "productQuery", "question": "¿De qué producto querés saber el precio?", "type": "string" }
  ],
  "steps": [
    {
      "id": "resolve_product",
      "tool": "entity_resolver.resolveProduct",
      "params": { "query": "$productQuery", "empresaId": "$context.empresaId" },
      "store_result_as": "resolvedProduct",
      "on_ambiguous": "ask_user_to_select",
      "on_not_found": "answer_not_found"
    },
    {
      "id": "get_price",
      "tool": "inventory.getPrecioProducto",
      "params": { "productoId": "$resolvedProduct.id" },
      "store_result_as": "priceData"
    },
    {
      "id": "generate_response",
      "tool": "llm.generateAnswer",
      "params": {
        "data": ["$resolvedProduct", "$priceData"],
        "instruction": "Responde con el precio de venta del producto de forma clara."
      }
    }
  ]
}'),

-- Ventas del día
('wf_query_sales_today', 'Consultar ventas del día', 'Devuelve el resumen de ventas del día actual', '{
  "id": "wf_query_sales_today",
  "nombre": "Consultar ventas del día",
  "type": "query",
  "session_accumulates": false,
  "required_fields": [],
  "steps": [
    {
      "id": "get_sales",
      "tool": "sales.getVentasDelDia",
      "params": { "empresaId": "$context.empresaId" },
      "store_result_as": "salesData"
    },
    {
      "id": "generate_response",
      "tool": "llm.generateAnswer",
      "params": {
        "data": ["$salesData"],
        "instruction": "Presenta el resumen de ventas del día con total, cantidad de ventas, ventas en efectivo y crédito de forma organizada."
      }
    }
  ]
}'),

-- Estado de caja
('wf_query_cash', 'Consultar estado de caja', 'Devuelve el estado actual de la caja registradora', '{
  "id": "wf_query_cash",
  "nombre": "Consultar estado de caja",
  "type": "query",
  "session_accumulates": false,
  "required_fields": [],
  "steps": [
    {
      "id": "get_cash",
      "tool": "sales.getEstadoCaja",
      "params": { "empresaId": "$context.empresaId" },
      "store_result_as": "cashData"
    },
    {
      "id": "generate_response",
      "tool": "llm.generateAnswer",
      "params": {
        "data": ["$cashData"],
        "instruction": "Informa el estado de la caja: si está abierta o cerrada, el saldo actual, y cuándo fue abierta. Sé conciso."
      }
    }
  ]
}'),

-- Registrar entrada
('wf_register_entry', 'Registrar entrada de inventario', 'Registra mercadería recibida con borrador y confirmación', '{
  "id": "wf_register_entry",
  "nombre": "Registrar entrada de inventario",
  "type": "action_with_draft",
  "session_accumulates": true,
  "required_fields": [],
  "steps": [
    {
      "id": "start_session",
      "tool": "session.startEntry",
      "params": { "bodegaId": "$context.selectedWarehouseId" },
      "store_result_as": "sessionId"
    },
    {
      "id": "collect_items",
      "tool": "session.collectItems",
      "params": { "sessionId": "$sessionId", "empresaId": "$context.empresaId" },
      "store_result_as": "draftItems",
      "loop_until": "user_says_done"
    },
    {
      "id": "confirm_draft",
      "tool": "draft.showConfirmation",
      "params": { "items": "$draftItems", "bodegaId": "$context.selectedWarehouseId", "type": "entry" }
    },
    {
      "id": "execute",
      "tool": "usecase.registrarEntrada",
      "params": { "bodegaId": "$context.selectedWarehouseId", "items": "$draftItems" },
      "store_result_as": "result",
      "on_success": "answer_success",
      "on_error": "answer_error"
    }
  ]
}'),

-- Registrar venta
('wf_register_sale', 'Registrar venta', 'Registra una venta con borrador y confirmación', '{
  "id": "wf_register_sale",
  "nombre": "Registrar venta",
  "type": "action_with_draft",
  "session_accumulates": true,
  "required_fields": [],
  "steps": [
    {
      "id": "start_session",
      "tool": "session.startSale",
      "params": { "bodegaId": "$context.selectedWarehouseId" },
      "store_result_as": "sessionId"
    },
    {
      "id": "collect_items",
      "tool": "session.collectItems",
      "params": { "sessionId": "$sessionId", "empresaId": "$context.empresaId" },
      "store_result_as": "draftItems",
      "loop_until": "user_says_done"
    },
    {
      "id": "confirm_draft",
      "tool": "draft.showConfirmation",
      "params": { "items": "$draftItems", "bodegaId": "$context.selectedWarehouseId", "type": "sale" }
    },
    {
      "id": "execute",
      "tool": "usecase.registrarVenta",
      "params": { "bodegaId": "$context.selectedWarehouseId", "items": "$draftItems" },
      "store_result_as": "result",
      "on_success": "answer_success",
      "on_error": "answer_error"
    }
  ]
}'),

-- Respuesta directa (saludo / utilidad)
('wf_direct_answer', 'Respuesta directa', 'Responde directamente sin herramientas', '{
  "id": "wf_direct_answer",
  "nombre": "Respuesta directa",
  "type": "direct_answer",
  "session_accumulates": false,
  "required_fields": [],
  "steps": [
    {
      "id": "generate_response",
      "tool": "llm.generateAnswer",
      "params": {
        "data": [],
        "instruction": "Responde de forma natural y amigable. Eres un asistente de inventario. Si te saludan, saluda de vuelta y ofrece ayuda. Si te preguntan qué puedes hacer, explica brevemente tus capacidades: consultar stock, precios, ventas del día, estado de caja, y registrar entradas y ventas."
      }
    }
  ]
}')

ON CONFLICT (id) DO UPDATE SET
  nombre      = EXCLUDED.nombre,
  definition  = EXCLUDED.definition,
  updated_at  = now();


-- ============================================================
-- 4. TOOLS CATALOG
-- ============================================================

INSERT INTO assistant_tools_catalog (id, description, input_schema, output_schema, category) VALUES

('entity_resolver.resolveProduct',
 'Busca un producto por nombre, descripción o código SKU. Devuelve uno o varios candidatos.',
 '{"query": "string (requerido) — nombre o código del producto", "empresaId": "string (requerido)"}',
 '{"status": "resolved | ambiguous | notFound", "selected": "Producto | null", "candidates": "Producto[]"}',
 'entity'),

('entity_resolver.resolveClient',
 'Busca un cliente por nombre o teléfono.',
 '{"query": "string (requerido)", "empresaId": "string (requerido)"}',
 '{"status": "resolved | ambiguous | notFound", "selected": "Cliente | null", "candidates": "Cliente[]"}',
 'entity'),

('inventory.getStockPorBodega',
 'Obtiene el stock actual de un producto en una bodega específica.',
 '{"productoId": "string (requerido)", "bodegaId": "string (requerido)"}',
 '{"cantidadActual": "number", "cantidadReservada": "number", "productoNombre": "string", "bodegaNombre": "string"}',
 'inventory'),

('inventory.getPrecioProducto',
 'Obtiene el precio base y último costo de un producto.',
 '{"productoId": "string (requerido)"}',
 '{"precioBase": "number", "ultimoCosto": "number", "productoNombre": "string"}',
 'inventory'),

('inventory.getHistorialProducto',
 'Obtiene el historial de movimientos recientes de un producto.',
 '{"productoId": "string (requerido)", "limit": "number (opcional, default 10)"}',
 '{"movimientos": "Movimiento[]", "totalEntradas": "number", "totalSalidas": "number"}',
 'inventory'),

('sales.getVentasDelDia',
 'Devuelve el resumen de ventas del día actual.',
 '{"empresaId": "string (requerido)"}',
 '{"totalVentas": "number", "cantidadVentas": "number", "ventasEfectivo": "number", "ventasCredito": "number"}',
 'sales'),

('sales.getDeudaCliente',
 'Devuelve el saldo pendiente de un cliente.',
 '{"clienteId": "string (requerido)"}',
 '{"totalDeuda": "number", "cantidadFacturas": "number", "clienteNombre": "string"}',
 'sales'),

('sales.getEstadoCaja',
 'Devuelve el estado actual de la sesión de caja abierta.',
 '{"empresaId": "string (requerido)"}',
 '{"abierta": "boolean", "saldoActual": "number", "abiertaEn": "datetime | null", "cajaNombre": "string | null"}',
 'sales'),

('session.startEntry',
 'Inicia una sesión de entrada de inventario. Devuelve un ID de sesión temporal.',
 '{"bodegaId": "string (requerido)"}',
 '{"sessionId": "string"}',
 'session'),

('session.startSale',
 'Inicia una sesión de venta. Devuelve un ID de sesión temporal.',
 '{"bodegaId": "string (requerido)"}',
 '{"sessionId": "string"}',
 'session'),

('session.collectItems',
 'Agrega items a la sesión activa. El LLM llama esto cuando el usuario dice qué producto y cantidad.',
 '{"sessionId": "string (requerido)", "empresaId": "string (requerido)"}',
 '{"items": "DraftItem[]", "subtotal": "number"}',
 'session'),

('draft.showConfirmation',
 'Muestra al usuario un borrador con todos los items para confirmación antes de ejecutar.',
 '{"items": "DraftItem[] (requerido)", "bodegaId": "string (requerido)", "type": "entry | sale (requerido)"}',
 '{"confirmed": "boolean"}',
 'draft'),

('usecase.registrarEntrada',
 'Ejecuta el use case de entrada de inventario. Solo llamar después de confirmación del usuario.',
 '{"bodegaId": "string (requerido)", "items": "DraftItem[] (requerido)"}',
 '{"success": "boolean", "movimientoId": "string | null", "error": "string | null"}',
 'usecase'),

('usecase.registrarVenta',
 'Ejecuta el use case de registro de venta. Solo llamar después de confirmación del usuario.',
 '{"bodegaId": "string (requerido)", "items": "DraftItem[] (requerido)"}',
 '{"success": "boolean", "ventaId": "string | null", "error": "string | null"}',
 'usecase'),

('llm.generateAnswer',
 'El LLM genera la respuesta final en lenguaje natural usando los datos recolectados.',
 '{"data": "any[] (requerido) — datos a incluir en la respuesta", "instruction": "string (requerido) — qué hacer con los datos"}',
 '{"answerText": "string"}',
 'llm')

ON CONFLICT (id) DO UPDATE SET
  description   = EXCLUDED.description,
  input_schema  = EXCLUDED.input_schema,
  output_schema = EXCLUDED.output_schema;


-- ============================================================
-- 5. ROW LEVEL SECURITY (opcional pero recomendado)
-- ============================================================

-- Permitir lectura pública autenticada (el anon key puede leer)
ALTER TABLE assistant_intent_catalog ENABLE ROW LEVEL SECURITY;
ALTER TABLE assistant_workflows       ENABLE ROW LEVEL SECURITY;
ALTER TABLE assistant_tools_catalog   ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Lectura autenticada - intents"
  ON assistant_intent_catalog FOR SELECT
  TO authenticated USING (true);

CREATE POLICY "Lectura autenticada - workflows"
  ON assistant_workflows FOR SELECT
  TO authenticated USING (active = true);

CREATE POLICY "Lectura autenticada - tools"
  ON assistant_tools_catalog FOR SELECT
  TO authenticated USING (active = true);


-- ============================================================
-- VERIFICACIÓN FINAL
-- ============================================================

SELECT 'Intents:' AS tabla, count(*) AS filas FROM assistant_intent_catalog
UNION ALL
SELECT 'Workflows:', count(*) FROM assistant_workflows
UNION ALL
SELECT 'Tools:', count(*) FROM assistant_tools_catalog;
