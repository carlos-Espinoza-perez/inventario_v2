import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventario_v2/features/secretary/data/llm/function_schemas.dart';
import 'package:inventario_v2/features/secretary/data/llm/secretary_llm_client.dart';
import 'package:inventario_v2/features/secretary/data/llm/secretary_llm_models.dart';
import 'package:inventario_v2/features/secretary/data/tools/tool_executor.dart';
import 'package:inventario_v2/features/secretary/drafts/draft_tools.dart';
import 'package:inventario_v2/features/secretary/engine/secretary_engine.dart';
import 'package:inventario_v2/features/secretary/engine/system_prompt_builder.dart';
import 'package:inventario_v2/features/secretary/presentation/providers/draft_provider.dart';

import 'secretary_test_env.dart';

/// E2E con el LLM REAL vía openai-proxy: pregunta en lenguaje natural →
/// function calling → tools contra la DB sembrada → respuesta con el dato.
///
/// Tiene costo (centavos) y necesita red + OPENAI_API_KEY en Supabase, por
/// eso está tras una compuerta:
///   $env:SECRETARY_LLM_TESTS='1'; flutter test test/integration/secretary_llm_e2e_test.dart
void main() {
  final envFile = File('.env');
  final habilitado = envFile.existsSync() &&
      Platform.environment['SECRETARY_LLM_TESTS'] == '1';
  final skip = habilitado
      ? null
      : 'E2E con LLM real: correr con SECRETARY_LLM_TESTS=1 (usa red y '
          'gasta tokens).';

  late SecretaryTestEnv env;

  setUp(() async {
    dotenv.testLoad(fileInput: envFile.existsSync()
        ? envFile.readAsStringSync()
        : 'SUPABASE_URL=x\nSUPABASE_ANON_KEY=x');
    env = SecretaryTestEnv();
    await env.setUp();
    // flutter_test intercepta HttpClient (devuelve 400 vacío); este E2E
    // necesita red real hacia el proxy.
    HttpOverrides.global = null;
  });

  tearDown(() => env.tearDown());

  Future<TurnCompleted> turno(
    String pregunta, {
    DraftToolHandler? draftHandler,
  }) async {
    final engine = SecretaryEngine(
      llm: SecretaryLlmClient(),
      toolExecutor: env.container.read(toolExecutorProvider),
    );
    final systemPrompt = SystemPromptBuilder().build(context: env.context);
    TurnCompleted? completed;
    await for (final event in engine.runTurn(
      messages: [
        SecMessage.system(systemPrompt),
        SecMessage.user(pregunta),
      ],
      tools: [...secretaryReadOnlyTools, ...secretaryDraftTools],
      context: env.context,
      localToolHandler: draftHandler?.handle,
    )) {
      if (event is TurnCompleted) completed = event;
    }
    expect(completed, isNotNull, reason: 'El turno no completó.');
    return completed!;
  }

  test(
    'consulta de stock: responde con el dato real de la DB (20 pantalones)',
    () async {
      final r = await turno(
        '¿Cuánto stock hay de Pantalon Jeans en Bodega Central?',
      );
      expect(r.content, contains('20'));
      expect(
        r.toolCallsLog.toString(),
        contains('inventory.getStockPorBodega'),
      );
    },
    skip: skip,
    timeout: const Timeout(Duration(minutes: 2)),
  );

  test(
    'pregunta genérica en plural: busca en vez de pedir el nombre',
    () async {
      // Caso reportado en dispositivo: "cuántos pantalones tengo" respondía
      // "necesito el nombre o descripción" sin llamar ninguna tool.
      final r = await turno('¿Cuántos pantalones tengo?');
      expect(
        r.toolCallsLog, isNotEmpty,
        reason: 'Debe buscar, no pedir aclaración. Respuesta: ${r.content}',
      );
      expect(r.content, contains('20'));
    },
    skip: skip,
    timeout: const Timeout(Duration(minutes: 2)),
  );

  test(
    'ventas del día: suma real de las 3 ventas sembradas (180)',
    () async {
      final r = await turno('¿Cuánto vendí hoy en total?');
      expect(r.content, contains('180'));
    },
    skip: skip,
    timeout: const Timeout(Duration(minutes: 2)),
  );

  test(
    'producto ambiguo: pregunta cuál gorra en vez de inventar',
    () async {
      final r = await turno('¿Qué precio tiene la gorra?');
      final texto = r.content.toLowerCase();
      // Debe mencionar ambas opciones o pedir aclaración, nunca elegir sola.
      expect(
        texto.contains('roja') && texto.contains('azul') ||
            texto.contains('cuál') ||
            texto.contains('cual'),
        isTrue,
        reason: 'Respuesta: ${r.content}',
      );
    },
    skip: skip,
    timeout: const Timeout(Duration(minutes: 2)),
  );

  test(
    'ingreso dictado por chat: crea el borrador con el ítem (sin ejecutar)',
    () async {
      final session =
          await env.db.secretaryDao.createSession(title: 'E2E entrada');
      final handler = DraftToolHandler(
        engine: env.container.read(draftEngineProvider),
        db: env.db,
        sessionId: session.id,
        context: env.context,
      );

      final r = await turno(
        'Registrá una entrada: 5 unidades de Pantalon Jeans a 10 dólares '
        'de costo, en Bodega Central.',
        draftHandler: handler,
      );

      expect(handler.lastDraftId, isNotNull,
          reason: 'El LLM no creó borrador. Respuesta: ${r.content}');
      final items =
          await env.db.secretaryDao.getDraftItems(handler.lastDraftId!);
      expect(items, isNotEmpty);
      expect(items.first.quantity, 5);

      // Req-15: la tool NUNCA ejecuta; el movimiento no debe existir aún.
      expect(await env.db.select(env.db.movimientos).get(), isEmpty);
      final draft =
          await env.db.secretaryDao.getDraftById(handler.lastDraftId!);
      expect(draft!.status, 'active');
    },
    skip: skip,
    timeout: const Timeout(Duration(minutes: 2)),
  );
}
