# Plan 04 - Router Semántico y ReasoningEngine

---

## Objetivo

Implementar el `SemanticRouter` que reemplaza el parser de reglas de v1. El LLM recibe el catálogo de intenciones desde Supabase y el mensaje del usuario, y devuelve un JSON estructurado con la intención detectada, nivel de confianza y entidades extraídas. El `ReasoningEngine` desambigua referencias antes del routing.

---

## Flujo

```
Mensaje del usuario
       │
       ▼
[ReasoningEngine] — ¿Es ambiguo? ("ese", "el primero", "el mismo")
       │                └─ Sí: LLM reescribe el mensaje de forma explícita
       │                └─ No: pasa directo
       ▼
[SemanticRouter]
  ├─ Carga IntentCatalog desde WorkflowLoader
  ├─ Construye prompt con catálogo + historial + mensaje
  ├─ LLM devuelve JSON: { intent, score, entities, reasoning }
  └─ Bandas de confianza → acción
```

---

## Paso 1 — Modelo de resultado del router

```dart
// lib/features/assistant/data/knowledge/knowledge_models.dart
// Agregar a los modelos existentes:

class RouterResult {
  final String intent;
  final double score;
  final String workflowId;
  final String intentDescription;
  final Map<String, dynamic> entities;
  final String reasoning;

  const RouterResult({
    required this.intent,
    required this.score,
    required this.workflowId,
    required this.intentDescription,
    required this.entities,
    required this.reasoning,
  });

  factory RouterResult.fromJson(Map<String, dynamic> j) => RouterResult(
        intent: j['intent'] as String,
        score: (j['score'] as num).toDouble(),
        workflowId: j['workflow_id'] as String,
        intentDescription: j['intent_description'] as String? ?? '',
        entities: Map<String, dynamic>.from(j['entities'] ?? {}),
        reasoning: j['reasoning'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'intent': intent,
        'score': score,
        'workflow_id': workflowId,
        'intent_description': intentDescription,
        'entities': entities,
        'reasoning': reasoning,
      };

  // Bandas de confianza (igual que Arel)
  bool get shouldReject => score < 0.40;
  bool get needsMoreInfo => score >= 0.40 && score < 0.65;
  bool get needsConfirmation => score >= 0.65 && score < 0.85;
  bool get canExecuteDirectly => score >= 0.85;
}
```

---

## Paso 2 — Prompt del SemanticRouter

El prompt es el componente más crítico. Vive en Supabase (tabla `assistant_workflows`, fila `wf_router_prompt`) para poder actualizarlo sin cambiar código.

```
Eres el router semántico de un sistema de inventario llamado Secretario.
Tu única función es identificar QUÉ quiere hacer el usuario y devolver un JSON estructurado.

FECHA Y HORA ACTUAL: {datetime}
EMPRESA: {empresaNombre}
USUARIO: {usuarioNombre}
BODEGA SELECCIONADA: {bodegaNombre}

CATÁLOGO DE INTENCIONES DISPONIBLES:
{intentCatalog}

HISTORIAL RECIENTE DE LA CONVERSACIÓN:
{messageHistory}

MENSAJE ACTUAL DEL USUARIO:
"{userMessage}"

VARIABLES YA RECOLECTADAS EN ESTA SESIÓN:
{collectedData}

INSTRUCCIONES:
1. Analiza el mensaje del usuario considerando el historial.
2. Selecciona el intent que mejor coincide del catálogo.
3. Extrae las entidades mencionadas (producto, cliente, bodega, cantidad, etc.)
4. Si el usuario hace referencia a algo del historial ("el mismo", "ese producto", "el de antes"),
   resuelve la referencia usando el historial y las variables recolectadas.
5. Asigna un score de confianza (0.0 a 1.0).
6. Devuelve SOLO el JSON, sin texto adicional.

FORMATO DE RESPUESTA (JSON):
{
  "intent": "id_del_intent",
  "score": 0.0,
  "workflow_id": "id_del_workflow",
  "intent_description": "descripción breve de lo que quiere hacer",
  "entities": {
    "productQuery": "nombre del producto si aplica",
    "clientQuery": "nombre del cliente si aplica",
    "warehouseQuery": "bodega si aplica",
    "quantity": null,
    "dateRange": null
  },
  "reasoning": "Por qué elegiste este intent"
}
```

---

## Paso 3 — SemanticRouter

```dart
// lib/features/assistant/core/semantic_router.dart

import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../data/openai/openai_client.dart';
import '../data/openai/openai_models.dart';
import '../data/knowledge/workflow_loader.dart';
import '../data/knowledge/knowledge_models.dart';
import '../domain/models/conversation_state.dart';
import '../domain/models/assistant_operational_context.dart';

class SemanticRouter {
  final LLMClient _llm;
  final WorkflowLoader _workflowLoader;

  static const _routerPrompt = '''
Eres el router semántico de un sistema de inventario llamado Secretario.
Tu única función es identificar QUÉ quiere hacer el usuario y devolver un JSON estructurado.

FECHA Y HORA ACTUAL: {datetime}
EMPRESA: {empresaNombre}
USUARIO: {usuarioNombre}
BODEGA SELECCIONADA: {bodegaNombre}

CATÁLOGO DE INTENCIONES DISPONIBLES:
{intentCatalog}

HISTORIAL RECIENTE DE LA CONVERSACIÓN:
{messageHistory}

MENSAJE ACTUAL DEL USUARIO:
"{userMessage}"

VARIABLES YA RECOLECTADAS EN ESTA SESIÓN:
{collectedData}

INSTRUCCIONES:
- Selecciona el intent que mejor coincide del catálogo.
- Extrae las entidades mencionadas.
- Si el usuario referencia algo anterior ("el mismo", "ese", "el primero"), resuélvelo con el historial.
- Asigna un score de confianza (0.0–1.0).
- Devuelve SOLO JSON válido, sin texto adicional.

FORMATO ESPERADO:
{"intent":"...","score":0.0,"workflow_id":"...","intent_description":"...","entities":{},"reasoning":"..."}
''';

  const SemanticRouter({
    required LLMClient llm,
    required WorkflowLoader workflowLoader,
  });

  Future<RouterResult> route(
    String userMessage,
    ConversationState state,
    AssistantOperationalContext context,
  ) async {
    final catalog = await _workflowLoader.loadIntentCatalog();

    final systemPrompt = _buildPrompt(
      userMessage: userMessage,
      catalog: catalog,
      state: state,
      context: context,
    );

    final request = OpenAIRequest(
      model: dotenv.env['OPENAI_MODEL'] ?? 'gpt-4o-mini',
      messages: [
        OpenAIMessage.system(systemPrompt),
        OpenAIMessage.user(userMessage),
      ],
      stream: false,
      temperature: 0.1,    // máxima precisión para routing
      maxTokens: 256,
      responseFormat: {'type': 'json_object'},
    );

    final response = await _llm.chat(request);

    try {
      final json = jsonDecode(response.content) as Map<String, dynamic>;
      return RouterResult.fromJson(json);
    } catch (e) {
      // Si el LLM devuelve JSON malformado, tratar como unsupported
      return RouterResult(
        intent: 'unsupported',
        score: 0.0,
        workflowId: 'wf_direct_answer',
        intentDescription: 'No se pudo detectar la intención',
        entities: {},
        reasoning: 'JSON malformado del LLM',
      );
    }
  }

  String _buildPrompt({
    required String userMessage,
    required IntentCatalog catalog,
    required ConversationState state,
    required AssistantOperationalContext context,
  }) {
    final history = state.messageHistory
        .take(6) // últimos 6 turnos para el router (menos tokens)
        .map((t) => '${t.role}: ${t.content}')
        .join('\n');

    final collectedSummary = state.collectedData.entries
        .where((e) => e.value.relevance > 0.3)
        .map((e) => '${e.key}: ${e.value.value}')
        .join(', ');

    return _routerPrompt
        .replaceAll('{datetime}', DateTime.now().toString())
        .replaceAll('{empresaNombre}', context.empresaId) // TODO: nombre real
        .replaceAll('{usuarioNombre}', context.usuarioId) // TODO: nombre real
        .replaceAll('{bodegaNombre}', context.selectedWarehouseId ?? 'ninguna')
        .replaceAll('{intentCatalog}', catalog.toRouterPromptBlock())
        .replaceAll('{messageHistory}', history.isEmpty ? 'Sin historial' : history)
        .replaceAll('{userMessage}', userMessage)
        .replaceAll('{collectedData}', collectedSummary.isEmpty ? 'ninguna' : collectedSummary);
  }
}
```

---

## Paso 4 — ReasoningEngine

Desambigua referencias como "el mismo", "ese producto", "el primero de la lista".
Solo se activa cuando el mensaje es corto o contiene palabras de referencia.

```dart
// lib/features/assistant/core/reasoning_engine.dart

import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../data/openai/openai_client.dart';
import '../data/openai/openai_models.dart';
import '../domain/models/conversation_state.dart';

class ReasoningEngine {
  final LLMClient _llm;

  static const _referenceWords = [
    'ese', 'esa', 'esos', 'esas', 'el mismo', 'la misma',
    'el primero', 'el segundo', 'el tercero', 'el último',
    'ese producto', 'ese cliente', 'esa bodega',
    'anterior', 'el de antes', 'el mencionado',
  ];

  const ReasoningEngine({required LLMClient llm});

  /// Devuelve el mensaje reescrito si era ambiguo, o el original si no lo era
  Future<String> clarifyIfNeeded(
    String message,
    ConversationState state,
  ) async {
    if (!_isAmbiguous(message)) return message;
    if (state.messageHistory.isEmpty && state.lastShownList.isEmpty) return message;

    final context = _buildContext(state);
    if (context.isEmpty) return message;

    final systemPrompt = '''
Eres un asistente que reescribe mensajes ambiguos de forma explícita.

CONTEXTO DE LA CONVERSACIÓN:
$context

MENSAJE ORIGINAL DEL USUARIO:
"$message"

Si el mensaje hace referencia a algo del contexto (con palabras como "ese", "el mismo", "el primero", etc.),
reescríbelo de forma explícita reemplazando las referencias con los valores concretos.
Si no hay referencia ambigua, devuelve el mensaje original sin cambios.
Devuelve SOLO el mensaje reescrito, sin explicación.
''';

    final response = await _llm.chat(OpenAIRequest(
      model: dotenv.env['OPENAI_MODEL'] ?? 'gpt-4o-mini',
      messages: [OpenAIMessage.system(systemPrompt)],
      stream: false,
      temperature: 0.0,
      maxTokens: 128,
    ));

    return response.content.trim();
  }

  bool _isAmbiguous(String message) {
    final lower = message.toLowerCase();
    // Activar si el mensaje es corto O contiene palabras de referencia
    if (message.split(' ').length <= 3) return true;
    return _referenceWords.any((word) => lower.contains(word));
  }

  String _buildContext(ConversationState state) {
    final parts = <String>[];

    // Últimos 4 turnos del historial
    if (state.messageHistory.isNotEmpty) {
      final recent = state.messageHistory.reversed.take(4).toList().reversed;
      parts.add('Conversación reciente:\n' +
          recent.map((t) => '${t.role}: ${t.content}').join('\n'));
    }

    // Última lista mostrada
    if (state.lastShownList.isNotEmpty) {
      parts.add('Última lista mostrada:\n' +
          state.lastShownList
              .asMap()
              .entries
              .map((e) => '${e.key + 1}. ${e.value.displayName}')
              .join('\n'));
    }

    // Variables relevantes
    final vars = state.collectedData.entries
        .where((e) => e.value.relevance > 0.5)
        .map((e) => '${e.key}: ${e.value.value}')
        .join(', ');
    if (vars.isNotEmpty) parts.add('Datos conocidos: $vars');

    return parts.join('\n\n');
  }
}
```

---

## Bandas de confianza aplicadas en TurnPipeline

| Score | Acción | Mensaje al usuario |
|---|---|---|
| < 0.40 | Rechazar | "No entendí bien. ¿Podés reformularlo?" |
| 0.40 – 0.65 | Pedir más info | "Creo que querés X. ¿Es correcto?" |
| 0.65 – 0.85 | Pedir confirmación | "Entendí que querés X. ¿Procedo?" |
| > 0.85 | Ejecutar directo | — |

Para acciones destructivas (ajuste, salida) el umbral de ejecución directa sube a 0.92.

---

## Criterio de cierre

- [ ] `SemanticRouter.route()` devuelve `RouterResult` válido con JSON estructurado
- [ ] Catálogo de intents viene de Supabase vía `WorkflowLoader`
- [ ] Historial de últimos 6 turnos incluido en el prompt del router
- [ ] Bandas de confianza implementadas en `TurnPipeline`
- [ ] `ReasoningEngine` activa solo cuando el mensaje es ambiguo o corto
- [ ] Fallo del LLM (JSON malformado) devuelve `unsupported` sin crash
