-- Actualizacion del catalogo IA para flujo acumulativo de entradas.
-- Ejecutar en Supabase despues de desplegar la version Flutter que incluye
-- las tablas locales assistant_entry_sessions y assistant_entry_session_items.

update public.assistant_intent_catalog
set
  description = 'Activar cuando el usuario quiere registrar mercaderia que llego, hacer una entrada, recibir productos, agregar stock o acumular productos comprados en un borrador temporal. Ejemplos: "entraron 10 zapatos", "compre 2 docenas de desodorantes a 100 para vender a 200", "tambien 12 pantalones", "confirmar entrada".',
  requires_warehouse = true,
  active = true
where id = 'action_register_entry';

insert into public.assistant_tools_catalog
  (id, description, input_schema, output_schema, category, active)
values
  (
    'entry_session.startOrResume',
    'Inicia o reanuda una sesion local persistente de entrada para la bodega activa.',
    '{"bodegaId":"string requerido"}',
    '{"sessionId":"string","status":"active"}',
    'entry_session',
    true
  ),
  (
    'entry_session.addItems',
    'Agrega productos a la sesion local de entrada. Puede crear lineas para productos existentes, ambiguos o nuevos.',
    '{"items":"array de {nombre,cantidad,costo?,precio?}","bodegaId":"string requerido"}',
    '{"draft":"AssistantEntrySessionDraft","pending":"string[]"}',
    'entry_session',
    true
  ),
  (
    'entry_session.showDraft',
    'Muestra el borrador acumulado de entrada antes de guardar.',
    '{"sessionId":"string opcional"}',
    '{"draft":"AssistantEntrySessionDraft"}',
    'entry_session',
    true
  ),
  (
    'entry_session.updateItem',
    'Actualiza categoria, costo, precio, cantidad o producto seleccionado en una linea del borrador.',
    '{"lineId":"string opcional","field":"string","value":"any"}',
    '{"draft":"AssistantEntrySessionDraft"}',
    'entry_session',
    true
  ),
  (
    'entry_session.confirm',
    'Confirma la entrada: crea productos nuevos si aplica y registra el movimiento de inventario local.',
    '{"sessionId":"string opcional"}',
    '{"confirmed":true,"movementId":"string opcional"}',
    'entry_session',
    true
  ),
  (
    'entry_session.cancel',
    'Cancela la sesion temporal de entrada sin guardar inventario.',
    '{"sessionId":"string opcional"}',
    '{"cancelled":true}',
    'entry_session',
    true
  ),
  (
    'entity_resolver.resolveCategory',
    'Sugiere una categoria existente segun el nombre del producto; usa General si no hay coincidencia clara.',
    '{"productName":"string requerido","empresaId":"string opcional"}',
    '{"categoryId":"string","categoryName":"string","score":"number"}',
    'entity_resolver',
    true
  ),
  (
    'usecase.createProductDraft',
    'Prepara una linea de producto nuevo dentro del borrador de entrada; no crea el producto hasta confirmar.',
    '{"nombre":"string","categoriaId":"string","cantidad":"number","costo":"number opcional","precio":"number opcional"}',
    '{"draftItem":"AssistantEntryDraftLine"}',
    'usecase',
    true
  )
on conflict (id) do update set
  description = excluded.description,
  input_schema = excluded.input_schema,
  output_schema = excluded.output_schema,
  category = excluded.category,
  active = excluded.active;

update public.assistant_workflows
set definition = '{
  "id": "wf_register_entry",
  "nombre": "Registrar entrada acumulativa de inventario",
  "type": "action",
  "session_accumulates": true,
  "required_fields": [],
  "steps": [
    {
      "id": "start_or_resume",
      "tool": "entry_session.startOrResume",
      "params": { "bodegaId": "$context.selectedWarehouseId" },
      "store_result_as": "entrySession"
    },
    {
      "id": "add_items",
      "tool": "entry_session.addItems",
      "params": { "bodegaId": "$context.selectedWarehouseId", "items": "$entities.items" },
      "store_result_as": "entryDraft"
    },
    {
      "id": "show_draft",
      "tool": "entry_session.showDraft",
      "params": { "sessionId": "$entrySession.sessionId" },
      "store_result_as": "entryDraft"
    }
  ]
}'::jsonb,
active = true
where id = 'wf_register_entry';
