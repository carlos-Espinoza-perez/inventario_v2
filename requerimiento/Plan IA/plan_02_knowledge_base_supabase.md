# Plan 02 - Knowledge Base en Supabase

---

## Objetivo

Definir la estructura de la base de conocimiento del Secretario: tablas en Supabase, formato JSON de workflows e intents, y el `WorkflowLoader` que los descarga, valida y cachea localmente. La inteligencia de negocio vive en estos JSON — agregar un nuevo workflow no requiere cambiar código.

---

## Principio central

> "La inteligencia está en los datos, no en el código."

Agregar soporte para un nuevo intent (ej: "consultar historial de proveedor") = agregar una fila en Supabase. Sin nuevo código, sin nuevo build de la app.

---

## Tablas en Supabase

### `assistant_intent_catalog`

El catálogo de intenciones que recibe el router semántico.

```sql
CREATE TABLE assistant_intent_catalog (
  id            TEXT PRIMARY KEY,         -- ej: "query_stock_product"
  empresa_id    TEXT,                     -- NULL = global para todas las empresas
  display_name  TEXT NOT NULL,            -- "Consultar stock de producto"
  description   TEXT NOT NULL,            -- descripción para el LLM (CRÍTICA)
  workflow_id   TEXT NOT NULL,            -- qué workflow ejecutar
  category      TEXT NOT NULL,            -- "query" | "action" | "utility"
  requires_permissions TEXT[],            -- ["product.read"]
  requires_cash_open   BOOLEAN DEFAULT false,
  requires_warehouse   BOOLEAN DEFAULT false,
  active        BOOLEAN DEFAULT true,
  created_at    TIMESTAMPTZ DEFAULT now()
);
```

**Ejemplo de filas:**

```json
[
  {
    "id": "query_stock_product",
    "display_name": "Consultar stock de producto",
    "description": "Activar cuando el usuario pregunta cuántas unidades hay de un producto, cuánto stock tiene, si hay en inventario, cuánto queda, disponibilidad. Ejemplos: 'cuánto hay de coca cola', 'tengo camisa talla M', 'stock de nike air'.",
    "workflow_id": "wf_query_stock",
    "category": "query",
    "requires_permissions": ["product.read"],
    "requires_warehouse": true
  },
  {
    "id": "action_register_entry",
    "display_name": "Registrar entrada de inventario",
    "description": "Activar cuando el usuario quiere registrar mercadería que llegó, hacer una entrada, recibir productos, agregar stock. Ejemplos: 'llegó mercadería', 'vamos a hacer una entrada', 'recibí 24 cajas de coca cola'.",
    "workflow_id": "wf_register_entry",
    "category": "action",
    "requires_permissions": ["warehouse.update"],
    "requires_warehouse": true
  },
  {
    "id": "greeting",
    "display_name": "Saludo o pregunta general",
    "description": "Activar cuando el mensaje es un saludo, despedida, pregunta sobre el asistente, o conversación general sin intención de negocio específica.",
    "workflow_id": "wf_direct_answer",
    "category": "utility",
    "requires_permissions": []
  }
]
```

> La calidad de `description` es lo más importante del sistema. Cuanto más precisa y con más ejemplos, mejor funciona el router.

---

### `assistant_workflows`

Cada workflow define qué herramientas usar y en qué orden.

```sql
CREATE TABLE assistant_workflows (
  id            TEXT PRIMARY KEY,
  nombre        TEXT NOT NULL,
  descripcion   TEXT,
  definition    JSONB NOT NULL,    -- el workflow completo en JSON
  version       INTEGER DEFAULT 1,
  active        BOOLEAN DEFAULT true,
  updated_at    TIMESTAMPTZ DEFAULT now()
);
```

**Formato del campo `definition` (JSONB):**

```json
{
  "id": "wf_query_stock",
  "nombre": "Consultar stock de producto",
  "type": "query",
  "required_fields": [
    {
      "name": "productQuery",
      "question": "¿De qué producto querés saber el stock?",
      "type": "string"
    }
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
      "params": {
        "productoId": "$resolvedProduct.id",
        "bodegaId": "$context.selectedWarehouseId"
      },
      "store_result_as": "stockData"
    },
    {
      "id": "generate_response",
      "tool": "llm.generateAnswer",
      "params": {
        "data": ["$resolvedProduct", "$stockData"],
        "instruction": "Responde con el stock del producto de forma clara y concisa."
      }
    }
  ]
}
```

**Workflow de acción con borrador:**

```json
{
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
      "params": { "sessionId": "$sessionId" },
      "store_result_as": "draftItems",
      "loop_until": "user_says_done"
    },
    {
      "id": "confirm_draft",
      "tool": "draft.showConfirmation",
      "params": { "items": "$draftItems", "bodegaId": "$context.selectedWarehouseId" }
    },
    {
      "id": "execute",
      "tool": "usecase.registrarEntrada",
      "params": {
        "bodegaId": "$context.selectedWarehouseId",
        "items": "$draftItems"
      },
      "store_result_as": "result",
      "on_success": "answer_success",
      "on_error": "answer_error"
    }
  ]
}
```

---

### `assistant_tools_catalog`

Catálogo de herramientas disponibles para el ReAct loop. El LLM lo recibe para saber qué puede hacer.

```sql
CREATE TABLE assistant_tools_catalog (
  id            TEXT PRIMARY KEY,    -- "inventory.getStockPorBodega"
  description   TEXT NOT NULL,       -- descripción para el LLM
  input_schema  JSONB NOT NULL,      -- parámetros de entrada
  output_schema JSONB NOT NULL,      -- qué devuelve
  category      TEXT NOT NULL,       -- "inventory" | "sales" | "entity" | "llm" | "usecase"
  active        BOOLEAN DEFAULT true
);
```

**Ejemplos:**

```json
[
  {
    "id": "inventory.getStockPorBodega",
    "description": "Obtiene el stock actual de un producto en una bodega específica",
    "input_schema": {
      "productoId": "string (requerido)",
      "bodegaId": "string (requerido)"
    },
    "output_schema": {
      "cantidadActual": "number",
      "productoNombre": "string",
      "bodegaNombre": "string"
    },
    "category": "inventory"
  },
  {
    "id": "entity_resolver.resolveProduct",
    "description": "Busca un producto por nombre o código. Devuelve uno o varios candidatos.",
    "input_schema": {
      "query": "string (requerido)",
      "empresaId": "string (requerido)"
    },
    "output_schema": {
      "status": "resolved | ambiguous | notFound",
      "selected": "Producto | null",
      "candidates": "Producto[]"
    },
    "category": "entity"
  },
  {
    "id": "sales.getVentasDelDia",
    "description": "Devuelve el resumen de ventas del día actual",
    "input_schema": {
      "bodegaIds": "string[] (opcional)"
    },
    "output_schema": {
      "totalVentas": "number",
      "cantidadVentas": "number",
      "ventasEfectivo": "number",
      "ventasCredito": "number"
    },
    "category": "sales"
  }
]
```

---

## WorkflowLoader — carga y caché local

```dart
// lib/features/assistant/data/knowledge/workflow_loader.dart

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'knowledge_models.dart';

class WorkflowLoader {
  final SupabaseClient _supabase;

  // Caché en memoria para la sesión actual
  static final Map<String, WorkflowDefinition> _cache = {};
  static IntentCatalog? _intentCatalogCache;
  static List<ToolDefinition>? _toolsCatalogCache;

  const WorkflowLoader(this._supabase);

  /// Carga el catálogo de intents (con caché de sesión)
  Future<IntentCatalog> loadIntentCatalog() async {
    if (_intentCatalogCache != null) return _intentCatalogCache!;

    final rows = await _supabase
        .from('assistant_intent_catalog')
        .select()
        .eq('active', true);

    _intentCatalogCache = IntentCatalog.fromRows(rows);
    return _intentCatalogCache!;
  }

  /// Carga un workflow por ID (con caché de sesión)
  Future<WorkflowDefinition> load(String workflowId) async {
    if (_cache.containsKey(workflowId)) return _cache[workflowId]!;

    final row = await _supabase
        .from('assistant_workflows')
        .select('definition')
        .eq('id', workflowId)
        .eq('active', true)
        .single();

    final definition = WorkflowDefinition.fromJson(
      row['definition'] as Map<String, dynamic>,
    );
    _cache[workflowId] = definition;
    return definition;
  }

  /// Carga el catálogo de tools (con caché de sesión)
  Future<List<ToolDefinition>> loadToolsCatalog() async {
    if (_toolsCatalogCache != null) return _toolsCatalogCache!;

    final rows = await _supabase
        .from('assistant_tools_catalog')
        .select()
        .eq('active', true);

    _toolsCatalogCache = rows
        .map((r) => ToolDefinition.fromJson(r as Map<String, dynamic>))
        .toList();
    return _toolsCatalogCache!;
  }

  /// Invalida el caché (llamar cuando se actualicen workflows en Supabase)
  static void invalidateCache() {
    _cache.clear();
    _intentCatalogCache = null;
    _toolsCatalogCache = null;
  }
}
```

---

## KnowledgeModels — tipos Dart para los JSON

```dart
// lib/features/assistant/data/knowledge/knowledge_models.dart

class IntentCatalog {
  final List<IntentDefinition> intents;

  const IntentCatalog({required this.intents});

  factory IntentCatalog.fromRows(List<Map<String, dynamic>> rows) {
    return IntentCatalog(
      intents: rows
          .map((r) => IntentDefinition.fromJson(r))
          .toList(),
    );
  }

  /// Genera el bloque de texto que recibe el LLM para el router
  String toRouterPromptBlock() {
    return intents.map((i) =>
      '- ${i.id}: "${i.description}"'
    ).join('\n');
  }
}

class IntentDefinition {
  final String id;
  final String displayName;
  final String description;
  final String workflowId;
  final String category;
  final List<String> requiresPermissions;
  final bool requiresCashOpen;
  final bool requiresWarehouse;

  const IntentDefinition({
    required this.id,
    required this.displayName,
    required this.description,
    required this.workflowId,
    required this.category,
    required this.requiresPermissions,
    required this.requiresCashOpen,
    required this.requiresWarehouse,
  });

  factory IntentDefinition.fromJson(Map<String, dynamic> j) => IntentDefinition(
    id: j['id'] as String,
    displayName: j['display_name'] as String,
    description: j['description'] as String,
    workflowId: j['workflow_id'] as String,
    category: j['category'] as String,
    requiresPermissions: List<String>.from(j['requires_permissions'] ?? []),
    requiresCashOpen: j['requires_cash_open'] ?? false,
    requiresWarehouse: j['requires_warehouse'] ?? false,
  );
}

class WorkflowDefinition {
  final String id;
  final String nombre;
  final String type;        // "query" | "action_with_draft" | "direct_answer"
  final bool sessionAccumulates;
  final List<RequiredField> requiredFields;
  final List<WorkflowStep> steps;

  const WorkflowDefinition({
    required this.id,
    required this.nombre,
    required this.type,
    required this.sessionAccumulates,
    required this.requiredFields,
    required this.steps,
  });

  factory WorkflowDefinition.fromJson(Map<String, dynamic> j) =>
      WorkflowDefinition(
        id: j['id'] as String,
        nombre: j['nombre'] as String,
        type: j['type'] as String,
        sessionAccumulates: j['session_accumulates'] ?? false,
        requiredFields: (j['required_fields'] as List? ?? [])
            .map((f) => RequiredField.fromJson(f as Map<String, dynamic>))
            .toList(),
        steps: (j['steps'] as List? ?? [])
            .map((s) => WorkflowStep.fromJson(s as Map<String, dynamic>))
            .toList(),
      );
}

class WorkflowStep {
  final String id;
  final String tool;          // "inventory.getStockPorBodega"
  final Map<String, dynamic> params;
  final String? storeResultAs;
  final String? onAmbiguous;
  final String? onNotFound;
  final String? onSuccess;
  final String? onError;
  final String? loopUntil;

  const WorkflowStep({
    required this.id,
    required this.tool,
    required this.params,
    this.storeResultAs,
    this.onAmbiguous,
    this.onNotFound,
    this.onSuccess,
    this.onError,
    this.loopUntil,
  });

  factory WorkflowStep.fromJson(Map<String, dynamic> j) => WorkflowStep(
    id: j['id'] as String,
    tool: j['tool'] as String,
    params: Map<String, dynamic>.from(j['params'] ?? {}),
    storeResultAs: j['store_result_as'] as String?,
    onAmbiguous: j['on_ambiguous'] as String?,
    onNotFound: j['on_not_found'] as String?,
    onSuccess: j['on_success'] as String?,
    onError: j['on_error'] as String?,
    loopUntil: j['loop_until'] as String?,
  );
}

class RequiredField {
  final String name;
  final String question;
  final String type;

  const RequiredField({
    required this.name,
    required this.question,
    required this.type,
  });

  factory RequiredField.fromJson(Map<String, dynamic> j) => RequiredField(
    name: j['name'] as String,
    question: j['question'] as String,
    type: j['type'] as String,
  );
}

class ToolDefinition {
  final String id;
  final String description;
  final Map<String, dynamic> inputSchema;
  final Map<String, dynamic> outputSchema;
  final String category;

  const ToolDefinition({
    required this.id,
    required this.description,
    required this.inputSchema,
    required this.outputSchema,
    required this.category,
  });

  factory ToolDefinition.fromJson(Map<String, dynamic> j) => ToolDefinition(
    id: j['id'] as String,
    description: j['description'] as String,
    inputSchema: Map<String, dynamic>.from(j['input_schema'] ?? {}),
    outputSchema: Map<String, dynamic>.from(j['output_schema'] ?? {}),
    category: j['category'] as String,
  );

  /// Formato compacto para el prompt del LLM
  String toPromptEntry() =>
      '- $id: $description\n  Input: $inputSchema';
}
```

---

## Criterio de cierre

- [ ] Tablas creadas en Supabase con datos iniciales (mínimo 7 intents + sus workflows)
- [ ] `WorkflowLoader` carga desde Supabase y cachea en memoria
- [ ] `IntentCatalog.toRouterPromptBlock()` genera texto legible para el LLM
- [ ] Agregar un nuevo intent = agregar fila en Supabase, sin cambiar código
- [ ] Caché se invalida al detectar cambios de versión en los workflows
