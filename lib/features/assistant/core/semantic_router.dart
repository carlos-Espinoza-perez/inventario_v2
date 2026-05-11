import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventario_v2/core/constants/app_constants.dart';
import '../data/openai/openai_client.dart';
import '../data/openai/openai_models.dart';
import '../data/openai/openai_providers.dart';
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
- Extrae las entidades mencionadas (producto, cliente, bodega, cantidad, etc.).
- Si el usuario referencia algo anterior ("el mismo", "ese", "el primero"), resuélvelo con el historial.
- Asigna un score de confianza (0.0–1.0).
- Devuelve SOLO JSON válido, sin texto adicional.

FORMATO ESPERADO:
{"intent":"...","score":0.0,"workflow_id":"...","intent_description":"...","entities":{"productQuery":null,"clientQuery":null,"quantity":null},"reasoning":"..."}
''';

  SemanticRouter({
    required LLMClient llm,
    required WorkflowLoader workflowLoader,
  })  : _llm = llm,
        _workflowLoader = workflowLoader;

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
      model: AppConstants.openAiModel,
      messages: [
        OpenAIMessage.system(systemPrompt),
        OpenAIMessage.user(userMessage),
      ],
      stream: false,
      temperature: 0.1,
      maxTokens: 256,
      responseFormat: {'type': 'json_object'},
    );

    try {
      final response = await _llm.chat(request);
      final json = jsonDecode(response.content) as Map<String, dynamic>;
      final result = RouterResult.fromJson(json);
      return _withCatalogWorkflow(result, catalog);
    } catch (_) {
      return RouterResult(
        intent: 'greeting',
        score: 0.0,
        workflowId: 'wf_direct_answer',
        intentDescription: 'No se pudo detectar la intención',
        entities: {},
        reasoning: 'Error al parsear respuesta del LLM',
        requiresWarehouse: false,
      );
    }
  }

  RouterResult _withCatalogWorkflow(
    RouterResult result,
    IntentCatalog catalog,
  ) {
    final matches = catalog.intents.where((i) => i.id == result.intent);
    if (matches.isEmpty) return result;

    final intent = matches.first;
    return RouterResult(
      intent: result.intent,
      score: result.score,
      workflowId: intent.workflowId,
      intentDescription: result.intentDescription.isNotEmpty
          ? result.intentDescription
          : intent.description,
      entities: result.entities,
      reasoning: result.reasoning,
      requiresWarehouse: intent.requiresWarehouse,
    );
  }

  String _buildPrompt({
    required String userMessage,
    required IntentCatalog catalog,
    required ConversationState state,
    required AssistantOperationalContext context,
  }) {
    final history = state.messageHistory
        .reversed
        .take(6)
        .toList()
        .reversed
        .map((t) => '${t.role}: ${t.content}')
        .join('\n');

    final collectedSummary = state.collectedData.entries
        .where((e) => e.value.relevance > 0.3)
        .map((e) => '${e.key}: ${e.value.value}')
        .join(', ');

    return _routerPrompt
        .replaceAll('{datetime}', DateTime.now().toIso8601String())
        .replaceAll('{empresaNombre}', context.empresaId)
        .replaceAll('{bodegaNombre}', context.selectedWarehouseId ?? 'ninguna')
        .replaceAll('{intentCatalog}', catalog.toRouterPromptBlock())
        .replaceAll(
            '{messageHistory}', history.isEmpty ? 'Sin historial' : history)
        .replaceAll('{userMessage}', userMessage)
        .replaceAll(
            '{collectedData}',
            collectedSummary.isEmpty ? 'ninguna' : collectedSummary);
  }
}

final semanticRouterProvider = Provider<SemanticRouter>((ref) {
  return SemanticRouter(
    llm: ref.watch(llmClientProvider),
    workflowLoader: ref.watch(workflowLoaderProvider),
  );
});
