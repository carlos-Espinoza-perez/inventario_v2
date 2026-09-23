import 'package:inventario_v2/features/secretary/data/llm/function_schemas.dart';
import 'package:inventario_v2/features/secretary/data/llm/secretary_llm_client.dart';
import 'package:inventario_v2/features/secretary/data/llm/secretary_llm_models.dart';
import 'package:inventario_v2/features/secretary/data/tools/tool_executor.dart';
import 'package:inventario_v2/features/secretary/drafts/draft_tools.dart';
import 'package:inventario_v2/features/secretary/engine/secretary_engine.dart';
import 'package:inventario_v2/features/secretary/engine/system_prompt_builder.dart';
import 'package:inventario_v2/features/secretary/presentation/providers/draft_provider.dart';

import 'db_snapshot.dart';
import 'scenario.dart';
import 'secretary_harness_seed.dart';
import 'turn_verifier.dart';

/// Resultado de un turno ya ejecutado y verificado.
class TurnRunResult {
  final String user;
  final String response;
  final List<Map<String, dynamic>> toolCallsLog;
  final List<Map<String, dynamic>> toolResultsLog;
  final int promptTokens;
  final int completionTokens;
  final int latencyMs;
  final bool draftActive;
  final String? draftId;

  /// Tablas que SÍ cambiaron aunque el escenario esperaba que no (subset de
  /// `expect.dbUnchangedTables`). Vacía si no se pidió verificar nada o si
  /// todo quedó como se esperaba.
  final List<String> unexpectedDbChanges;

  /// Fallos de `verifyTurn` + los de `unexpectedDbChanges`. Vacía = pasó.
  final List<String> failures;

  const TurnRunResult({
    required this.user,
    required this.response,
    required this.toolCallsLog,
    required this.toolResultsLog,
    required this.promptTokens,
    required this.completionTokens,
    required this.latencyMs,
    required this.draftActive,
    required this.draftId,
    required this.unexpectedDbChanges,
    required this.failures,
  });

  bool get passed => failures.isEmpty;

  double get estimatedCostUsd =>
      promptTokens / 1e6 * 0.15 + completionTokens / 1e6 * 0.60;

  Map<String, dynamic> toJsonl() => {
        'user': user,
        'response': response,
        'toolCalls': toolCallsLog,
        'toolResults': toolResultsLog,
        'promptTokens': promptTokens,
        'completionTokens': completionTokens,
        'latencyMs': latencyMs,
        'draftActive': draftActive,
        'draftId': draftId,
        'unexpectedDbChanges': unexpectedDbChanges,
        'failures': failures,
        'passed': passed,
      };
}

class ScenarioRunResult {
  final HarnessScenario scenario;
  final List<TurnRunResult> turns;

  const ScenarioRunResult({required this.scenario, required this.turns});

  bool get passed => turns.every((t) => t.passed);
  int get promptTokens => turns.fold(0, (s, t) => s + t.promptTokens);
  int get completionTokens => turns.fold(0, (s, t) => s + t.completionTokens);
  double get costUsd => turns.fold(0.0, (s, t) => s + t.estimatedCostUsd);
  List<int> get latencies => [for (final t in turns) t.latencyMs];
}

/// Ejecuta escenarios contra el motor REAL del Secretario IA (LLM real vía
/// el proxy que apunte `AppConstants` en ese momento — el harness es
/// responsable de que eso sea el Supabase LOCAL, ver harness_env.dart).
///
/// Un `SecretaryHarnessRunner` corre UN escenario por conversación: arma
/// una sola sesión (system prompt + historial creciente + un
/// `DraftToolHandler` compartido entre turnos) para que un borrador creado
/// en el turno 2 se pueda confirmar en el turno 4, igual que en la app.
class SecretaryHarnessRunner {
  final SecretaryHarnessSeed seed;

  SecretaryHarnessRunner({required this.seed});

  /// [forceVoiceMode] pisa `scenario.voiceMode` cuando no es null — para
  /// correr cualquier escenario bajo las reglas de modo voz desde
  /// `--dart-define=HARNESS_VOICE_MODE=true` sin duplicar YAML.
  Future<ScenarioRunResult> run(
    HarnessScenario scenario, {
    bool? forceVoiceMode,
  }) async {
    final voiceMode = forceVoiceMode ?? scenario.voiceMode;
    final engine = SecretaryEngine(
      llm: SecretaryLlmClient(),
      toolExecutor: seed.container.read(toolExecutorProvider),
    );
    final draftHandler = DraftToolHandler(
      engine: seed.container.read(draftEngineProvider),
      db: seed.db,
      sessionId: 'harness-${scenario.id}',
      context: seed.context,
    );
    final systemPrompt = SystemPromptBuilder().build(
      context: seed.context,
      voiceMode: voiceMode,
    );

    final history = <SecMessage>[SecMessage.system(systemPrompt)];
    final turnResults = <TurnRunResult>[];

    for (final turn in scenario.turns) {
      final before = turn.expect.dbUnchangedTables.isEmpty
          ? const <String, TableSnapshot>{}
          : await snapshotTables(seed.db, turn.expect.dbUnchangedTables);

      if (turn.confirmDraft) {
        turnResults.add(
          await _runConfirmDraft(turn, draftHandler.lastDraftId, before),
        );
        continue;
      }

      history.add(SecMessage.user(turn.user!));
      final startedAt = DateTime.now();

      final completed = await _runTurnWithRetry(
        engine: engine,
        history: history,
        draftHandler: draftHandler,
      );
      final latencyMs = DateTime.now().difference(startedAt).inMilliseconds;

      if (completed == null) {
        turnResults.add(
          TurnRunResult(
            user: turn.user!,
            response: '',
            toolCallsLog: const [],
            toolResultsLog: const [],
            promptTokens: 0,
            completionTokens: 0,
            latencyMs: latencyMs,
            draftActive: false,
            draftId: null,
            unexpectedDbChanges: const [],
            failures: const ['El turno no devolvió TurnCompleted (¿timeout o error?).'],
          ),
        );
        continue;
      }

      history.add(SecMessage.assistant(completed.content));

      final draftId = draftHandler.lastDraftId;
      var draftActive = false;
      if (draftId != null) {
        final draft = await seed.db.secretaryDao.getDraftById(draftId);
        draftActive = draft?.status == 'active';
      }

      final unexpectedDbChanges = <String>[];
      if (turn.expect.dbUnchangedTables.isNotEmpty) {
        final after =
            await snapshotTables(seed.db, turn.expect.dbUnchangedTables);
        unexpectedDbChanges.addAll(diffSnapshots(before, after));
      }

      final toolIds = [
        for (final call in completed.toolCallsLog) call['tool'] as String,
      ];
      final failures = [
        ...verifyTurn(
          turn.expect,
          HarnessTurnResult(
            responseText: completed.content,
            toolIds: toolIds,
            draftActive: draftActive,
          ),
        ),
        for (final table in unexpectedDbChanges)
          'La tabla "$table" cambió y el escenario esperaba que no cambiara',
      ];

      turnResults.add(
        TurnRunResult(
          user: turn.user!,
          response: completed.content,
          toolCallsLog: completed.toolCallsLog,
          toolResultsLog: completed.toolResultsLog,
          promptTokens: completed.totalPromptTokens,
          completionTokens: completed.totalCompletionTokens,
          latencyMs: latencyMs,
          draftActive: draftActive,
          draftId: draftId,
          unexpectedDbChanges: unexpectedDbChanges,
          failures: failures,
        ),
      );
    }

    return ScenarioRunResult(scenario: scenario, turns: turnResults);
  }

  /// El edge-runtime LOCAL de `supabase functions serve` es intermitentemente
  /// inestable (confirmado a mano vía curl durante SEC-IA-003: ~30-40% de
  /// las llamadas fallan con un "400: There was an error parsing the body"
  /// genérico que no viene de OpenAI — desaparece solo al reintentar, sin
  /// cambiar nada de la petición). No es un bug del Secretario ni de
  /// producción (que no tiene cold/warm cycles por request); es un
  /// artefacto de correr el proxy en Docker local. Sin este reintento, la
  /// mitad de los escenarios "fallarían" por ruido de infraestructura, no
  /// por el motor. NO se reintenta ante errores reales de OpenAI (4xx que sí
  /// traen `type`/`code`, ej. quota o modelo inválido) — esos deben fallar
  /// y quedar reportados tal cual.
  Future<TurnCompleted?> _runTurnWithRetry({
    required SecretaryEngine engine,
    required List<SecMessage> history,
    required DraftToolHandler draftHandler,
    int maxAttempts = 3,
  }) async {
    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        TurnCompleted? completed;
        await for (final event in engine.runTurn(
          messages: history,
          tools: [...secretaryReadOnlyTools, ...secretaryDraftTools],
          context: seed.context,
          localToolHandler: draftHandler.handle,
        )) {
          if (event is TurnCompleted) completed = event;
        }
        return completed;
      } on SecretaryLlmException catch (e) {
        final isLocalRuntimeFlake = e.statusCode == 400 &&
            e.message.contains('error parsing the body');
        if (!isLocalRuntimeFlake || attempt == maxAttempts) rethrow;
        await Future.delayed(Duration(milliseconds: 300 * attempt));
      }
    }
    return null; // inalcanzable (el loop siempre retorna o relanza)
  }

  /// Simula tocar el botón "Confirmar" de la tarjeta del borrador:
  /// `DraftEngine.execute()` directo, el MISMO camino que
  /// `SecretaryChatNotifier.confirmDraft()` en la app — nunca una tool del
  /// LLM (Req-15). No manda nada al modelo, así que no gasta tokens.
  Future<TurnRunResult> _runConfirmDraft(
    HarnessTurn turn,
    String? draftId,
    Map<String, TableSnapshot> before,
  ) async {
    const label = '[confirmar borrador]';
    if (draftId == null) {
      return const TurnRunResult(
        user: label,
        response: '',
        toolCallsLog: [],
        toolResultsLog: [],
        promptTokens: 0,
        completionTokens: 0,
        latencyMs: 0,
        draftActive: false,
        draftId: null,
        unexpectedDbChanges: [],
        failures: [
          'confirm_draft: true pero no hay un borrador activo (ningún '
              'turno anterior llamó draft.create/addItems).',
        ],
      );
    }

    final startedAt = DateTime.now();
    String response;
    try {
      await seed.container
          .read(draftEngineProvider)
          .execute(draftId, seed.context);
      response = 'Listo, registré la operación correctamente.';
    } catch (e) {
      response = 'No pude registrar la operación: $e';
    }
    final latencyMs = DateTime.now().difference(startedAt).inMilliseconds;

    final draft = await seed.db.secretaryDao.getDraftById(draftId);
    final draftActive = draft?.status == 'active';

    final unexpectedDbChanges = <String>[];
    if (turn.expect.dbUnchangedTables.isNotEmpty) {
      final after =
          await snapshotTables(seed.db, turn.expect.dbUnchangedTables);
      unexpectedDbChanges.addAll(diffSnapshots(before, after));
    }

    final failures = [
      ...verifyTurn(
        turn.expect,
        HarnessTurnResult(
          responseText: response,
          toolIds: const [],
          draftActive: draftActive,
        ),
      ),
      for (final table in unexpectedDbChanges)
        'La tabla "$table" cambió y el escenario esperaba que no cambiara',
    ];

    return TurnRunResult(
      user: label,
      response: response,
      toolCallsLog: const [],
      toolResultsLog: const [],
      promptTokens: 0,
      completionTokens: 0,
      latencyMs: latencyMs,
      draftActive: draftActive,
      draftId: draftId,
      unexpectedDbChanges: unexpectedDbChanges,
      failures: failures,
    );
  }
}
