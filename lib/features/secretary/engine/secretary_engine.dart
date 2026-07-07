import 'dart:convert';

import 'package:inventario_v2/core/constants/app_constants.dart';
import 'package:inventario_v2/core/services/app_logger.dart';
import 'package:inventario_v2/features/secretary/data/tools/tool_executor.dart';
import 'package:inventario_v2/features/secretary/domain/models/assistant_operational_context.dart';

import '../data/llm/secretary_llm_client.dart';
import '../data/llm/secretary_llm_models.dart';

/// Eventos que el motor emite hacia la UI durante un turno.
sealed class SecretaryTurnEvent {
  const SecretaryTurnEvent();
}

/// Fragmento de texto de la respuesta final (streaming).
class TurnTextDelta extends SecretaryTurnEvent {
  final String content;
  const TurnTextDelta(this.content);
}

/// El motor está ejecutando una herramienta (para indicador en la UI).
class TurnToolRunning extends SecretaryTurnEvent {
  final String toolId;
  const TurnToolRunning(this.toolId);
}

/// Fin del turno con el texto completo y la traza técnica.
class TurnCompleted extends SecretaryTurnEvent {
  final String content;
  final List<Map<String, dynamic>> toolCallsLog;
  final List<Map<String, dynamic>> toolResultsLog;
  final int totalPromptTokens;
  final int totalCompletionTokens;
  final int iterations;

  const TurnCompleted({
    required this.content,
    required this.toolCallsLog,
    required this.toolResultsLog,
    required this.totalPromptTokens,
    required this.totalCompletionTokens,
    required this.iterations,
  });
}

/// Motor conversacional del secretario: loop de function calling nativo.
/// Reemplaza el ReAct de JSON libre del assistant anterior.
class SecretaryEngine {
  final SecretaryLlmClient _llm;
  final ToolExecutor _toolExecutor;

  SecretaryEngine({
    required SecretaryLlmClient llm,
    required ToolExecutor toolExecutor,
  })  : _llm = llm,
        _toolExecutor = toolExecutor;

  /// Ejecuta un turno completo. [messages] debe incluir el system prompt y el
  /// historial (incluido el mensaje nuevo del usuario).
  ///
  /// [localToolHandler] intercepta tools propias del secretario (ej. draft.*)
  /// antes de delegar al ToolExecutor del registry; devuelve null si no
  /// maneja el toolId.
  Stream<SecretaryTurnEvent> runTurn({
    required List<SecMessage> messages,
    required List<SecToolDef> tools,
    required AssistantOperationalContext context,
    Future<Map<String, dynamic>?> Function(
      String toolId,
      Map<String, dynamic> params,
    )? localToolHandler,
  }) async* {
    final conversation = List<SecMessage>.from(messages);
    final toolCallsLog = <Map<String, dynamic>>[];
    final toolResultsLog = <Map<String, dynamic>>[];
    var totalPrompt = 0;
    var totalCompletion = 0;
    final maxIterations = AppConstants.assistantMaxReactIterations;

    for (var iteration = 1; iteration <= maxIterations; iteration++) {
      final isLast = iteration == maxIterations;
      final request = SecLlmRequest(
        model: AppConstants.openAiModel,
        messages: conversation,
        // En la última iteración no se ofrecen tools: fuerza respuesta final.
        tools: isLast ? const [] : tools,
        temperature: AppConstants.openAiTemperature,
        maxTokens: AppConstants.openAiMaxTokens,
      );

      SecLlmCompleted? completed;
      await for (final event in _llm.streamChat(request)) {
        switch (event) {
          case SecLlmDelta(:final content):
            yield TurnTextDelta(content);
          case SecLlmCompleted():
            completed = event;
        }
      }

      if (completed == null) {
        throw StateError('El stream del LLM terminó sin evento de cierre.');
      }
      totalPrompt += completed.promptTokens ?? 0;
      totalCompletion += completed.completionTokens ?? 0;

      if (!completed.wantsTools) {
        yield TurnCompleted(
          content: completed.content,
          toolCallsLog: toolCallsLog,
          toolResultsLog: toolResultsLog,
          totalPromptTokens: totalPrompt,
          totalCompletionTokens: totalCompletion,
          iterations: iteration,
        );
        return;
      }

      // El modelo pidió herramientas: ejecutarlas y continuar el loop.
      conversation.add(SecMessage.assistantToolCalls(completed.toolCalls));
      for (final call in completed.toolCalls) {
        yield TurnToolRunning(call.toolId);
        toolCallsLog.add({
          'id': call.id,
          'tool': call.toolId,
          'arguments': call.argumentsJson,
        });

        Map<String, dynamic> resultMap;
        try {
          final localResult = localToolHandler != null
              ? await localToolHandler(
                  call.toolId,
                  Map<String, dynamic>.from(call.arguments),
                )
              : null;
          if (localResult != null) {
            resultMap = localResult;
          } else {
            final result = await _toolExecutor.execute(
              toolId: call.toolId,
              params: Map<String, dynamic>.from(call.arguments),
              operationalContext: context,
            );
            resultMap = result.toContext();
          }
        } catch (e) {
          AppLogger.warn(
            '[Secretary][Engine] Tool ${call.toolId} lanzó excepción: $e',
          );
          resultMap = {'status': 'error', 'error': e.toString()};
        }

        toolResultsLog.add({'id': call.id, 'result': resultMap});
        conversation.add(
          SecMessage.toolResult(toolCallId: call.id, result: resultMap),
        );
      }
    }

    // No debería llegar aquí: la última iteración va sin tools y retorna.
    throw StateError(
      'El motor superó $maxIterations iteraciones sin respuesta final.',
    );
  }
}

/// Serializa la traza para ChatTurnTraces.
String encodeTraceJson(List<Map<String, dynamic>> entries) =>
    jsonEncode(entries);
