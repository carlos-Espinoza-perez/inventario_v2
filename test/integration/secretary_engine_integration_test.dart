import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:inventario_v2/core/db/app_database.dart';
import 'package:inventario_v2/core/db/exceptions/dao_exceptions.dart';
import 'package:inventario_v2/features/secretary/data/entity_resolver.dart';
import 'package:inventario_v2/features/secretary/data/tools/tool_executor.dart';
import 'package:inventario_v2/features/secretary/data/tools/tool_result.dart';
import 'package:inventario_v2/features/secretary/domain/models/assistant_operational_context.dart';
import 'package:inventario_v2/features/secretary/drafts/draft_engine.dart';
import 'package:inventario_v2/features/secretary/drafts/draft_tools.dart';
import 'package:inventario_v2/features/secretary/presentation/providers/draft_provider.dart';

import 'secretary_test_env.dart';

/// Integración del motor del Secretario IA contra la base de datos real
/// (Drift en memoria, negocio sembrado). Sin red ni LLM: valida resolución
/// de productos, tools de consulta, borradores y transacciones completas.
void main() {
  late SecretaryTestEnv env;

  setUp(() async {
    env = SecretaryTestEnv();
    await env.setUp();
  });

  tearDown(() => env.tearDown());

  group('A. EntityResolver (catálogo real)', () {
    test('nombre exacto resuelve el producto', () async {
      final resolver = EntityResolver(env.db);
      final result = await resolver.resolveProduct(
        'Pantalon Jeans',
        empresaId: SecretaryTestEnv.empresaId,
      );
      expect(result.isResolved, isTrue);
      expect(result.selected!.id, SecretaryTestEnv.prodPantalonId);
    });

    test('"gorra" es ambiguo entre roja y azul', () async {
      final resolver = EntityResolver(env.db);
      final result = await resolver.resolveProduct(
        'gorra',
        empresaId: SecretaryTestEnv.empresaId,
      );
      expect(result.isAmbiguous, isTrue);
      expect(result.candidates.length, greaterThanOrEqualTo(2));
    });

    test('plural coloquial "pantalones" resuelve el único pantalón', () async {
      final resolver = EntityResolver(env.db);
      final result = await resolver.resolveProduct(
        'pantalones',
        empresaId: SecretaryTestEnv.empresaId,
      );
      expect(result.isResolved, isTrue);
      expect(result.selected!.id, SecretaryTestEnv.prodPantalonId);
    });

    test('plural "gorras" mantiene la ambigüedad (roja y azul)', () async {
      final resolver = EntityResolver(env.db);
      final result = await resolver.resolveProduct(
        'gorras',
        empresaId: SecretaryTestEnv.empresaId,
      );
      expect(result.isAmbiguous, isTrue);
      expect(result.candidates.length, greaterThanOrEqualTo(2));
    });

    test('plural con atributo "gorras rojas" resuelve la Gorra Roja',
        () async {
      final resolver = EntityResolver(env.db);
      final result = await resolver.resolveProduct(
        'gorras rojas',
        empresaId: SecretaryTestEnv.empresaId,
      );
      expect(result.isResolved, isTrue);
      expect(result.selected!.id, SecretaryTestEnv.prodGorraRojaId);
    });

    test('producto inexistente devuelve notFound', () async {
      final resolver = EntityResolver(env.db);
      final result = await resolver.resolveProduct(
        'taladro industrial xyz',
        empresaId: SecretaryTestEnv.empresaId,
      );
      expect(result.isNotFound, isTrue);
    });

    test('cliente por nombre parcial resuelve', () async {
      final resolver = EntityResolver(env.db);
      final result = await resolver.resolveClient(
        'Maria',
        empresaId: SecretaryTestEnv.empresaId,
      );
      expect(result.isResolved, isTrue);
      expect(result.selected!.id, SecretaryTestEnv.clienteMariaId);
    });
  });

  group('B. Tools de consulta (mismas que usa el LLM)', () {
    ToolExecutor executor() => env.container.read(toolExecutorProvider);

    test('stock de un producto en la bodega activa', () async {
      final result = await executor().execute(
        toolId: 'inventory.getStockPorBodega',
        params: {'productoId': SecretaryTestEnv.prodGorraRojaId},
        operationalContext: env.context,
      );
      expect(result.isSuccess, isTrue, reason: result.errorMessage ?? '');
      expect(result.toContext().toString(), contains('50'));
    });

    test('listado de stock omite productos en cero', () async {
      final result = await executor().execute(
        toolId: 'inventory.getStockPorBodega',
        params: {},
        operationalContext: env.context,
      );
      expect(result.isSuccess, isTrue);
      final texto = result.toContext().toString();
      expect(texto, contains('Gorra Roja'));
      expect(texto, isNot(contains('Camisa Blanca'))); // stock 0
    });

    test('precio del producto', () async {
      final result = await executor().execute(
        toolId: 'inventory.getPrecioProducto',
        params: {'productoId': SecretaryTestEnv.prodGorraRojaId},
        operationalContext: env.context,
      );
      expect(result.isSuccess, isTrue);
      expect(result.toContext().toString(), contains('8'));
    });

    test('ventas del día suman las 3 ventas sembradas', () async {
      final result = await executor().execute(
        toolId: 'sales.getVentasDelDia',
        params: {},
        operationalContext: env.context,
      );
      expect(result.isSuccess, isTrue);
      expect(
        (result.data as Map)['totalVentas'],
        SecretaryTestEnv.totalVentasHoy,
      );
    });

    test('estado de caja: abierta con la sesión sembrada', () async {
      final result = await executor().execute(
        toolId: 'sales.getEstadoCaja',
        params: {},
        operationalContext: env.context,
      );
      expect(result.isSuccess, isTrue);
      final data = result.data as Map;
      expect(data['cajaAbierta'], isTrue);
      expect(data['sesionId'], SecretaryTestEnv.cajaSesionId);
    });

    test('bodega fuera del alcance del usuario se bloquea', () async {
      final contextoRestringido = AssistantOperationalContext(
        empresaId: SecretaryTestEnv.empresaId,
        usuarioId: SecretaryTestEnv.usuarioId,
        rolId: SecretaryTestEnv.rolId,
        permisos: const [],
        selectedWarehouseId: SecretaryTestEnv.bodegaCentralId,
        allowedWarehouses: const [
          AssistantWarehouse(
            id: SecretaryTestEnv.bodegaCentralId,
            nombre: 'Bodega Central',
          ),
        ],
      );
      final result = await executor().execute(
        toolId: 'inventory.getStockPorBodega',
        params: {
          'productoId': SecretaryTestEnv.prodZapatoId,
          'bodegaId': SecretaryTestEnv.bodegaSurId, // no permitida
        },
        operationalContext: contextoRestringido,
      );
      expect(result.status, ToolResultStatus.error);
      expect(result.errorMessage, contains('acceso'));
    });

    test('sin bodega seleccionada pide aclaración en vez de fallar', () async {
      final sinBodega = AssistantOperationalContext(
        empresaId: SecretaryTestEnv.empresaId,
        usuarioId: SecretaryTestEnv.usuarioId,
        rolId: SecretaryTestEnv.rolId,
        permisos: const [],
        allowedWarehouses: const [
          AssistantWarehouse(
            id: SecretaryTestEnv.bodegaCentralId,
            nombre: 'Bodega Central',
          ),
        ],
      );
      final result = await executor().execute(
        toolId: 'inventory.getStockPorBodega',
        params: {'productoId': SecretaryTestEnv.prodGorraRojaId},
        operationalContext: sinBodega,
      );
      expect(result.needsUserInput, isTrue);
    });
  });

  group('C. Ingreso de productos (borrador → movimiento real)', () {
    DraftEngine engine() => env.container.read(draftEngineProvider);

    test('flujo completo: dictado mixto, corrección y ejecución', () async {
      final draft = await engine().createDraft(
        draftType: 'entrada',
        bodegaId: SecretaryTestEnv.bodegaCentralId,
        descripcion: 'Compra al proveedor',
      );

      // 3 ítems: resuelto con costo, ambiguo, desconocido.
      final items = await engine().addItems(
        draftId: draft.id,
        rawItems: const [
          RawDraftItem(nombre: 'Pantalon Jeans', cantidad: 12, costoUnitario: 10),
          RawDraftItem(nombre: 'gorra', cantidad: 5),
          RawDraftItem(nombre: 'producto fantasma', cantidad: 3),
        ],
        context: env.context,
      );

      expect(items[0].status, 'ready');
      expect(items[0].unitCost, 10);
      expect(items[1].status, 'needs_review');
      expect(items[1].candidatesJson, isNotNull);
      expect(items[2].status, 'needs_review');

      // No se puede ejecutar con pendientes.
      expect(await engine().validate(draft.id), isNotEmpty);

      // El usuario resuelve la gorra (elige la roja) y quita el fantasma.
      await engine().updateItem(
        items[1].id,
        productoId: SecretaryTestEnv.prodGorraRojaId,
        resolvedName: 'Gorra Roja',
      );
      await engine().removeItem(items[2].id);
      expect(await engine().validate(draft.id), isEmpty);

      final stockPantalonAntes = await env.stockDe(
        SecretaryTestEnv.prodPantalonId,
        SecretaryTestEnv.bodegaCentralId,
      );

      await engine().execute(draft.id, env.context);

      // El movimiento existe y el stock subió exactamente lo dictado.
      final movimientos = await env.db.select(env.db.movimientos).get();
      expect(movimientos, hasLength(1));
      expect(
        await env.stockDe(
          SecretaryTestEnv.prodPantalonId,
          SecretaryTestEnv.bodegaCentralId,
        ),
        stockPantalonAntes + 12,
      );
      expect(
        await env.stockDe(
          SecretaryTestEnv.prodGorraRojaId,
          SecretaryTestEnv.bodegaCentralId,
        ),
        55, // 50 + 5
      );

      final actualizado = await env.db.secretaryDao.getDraftById(draft.id);
      expect(actualizado!.status, 'executed');
    });

    test('entrada sin bodega no valida', () async {
      final draft = await engine().createDraft(draftType: 'entrada');
      await engine().addItems(
        draftId: draft.id,
        rawItems: const [RawDraftItem(nombre: 'Camisa Blanca', cantidad: 4)],
        context: env.context,
      );
      final errores = await engine().validate(draft.id);
      expect(errores.join(' '), contains('bodega'));
    });

    test('descartar borrador no toca inventario', () async {
      final draft = await engine().createDraft(
        draftType: 'entrada',
        bodegaId: SecretaryTestEnv.bodegaCentralId,
      );
      await engine().addItems(
        draftId: draft.id,
        rawItems: const [RawDraftItem(nombre: 'Gorra Azul', cantidad: 99)],
        context: env.context,
      );
      await engine().discard(draft.id);

      expect(
        await env.stockDe(
          SecretaryTestEnv.prodGorraAzulId,
          SecretaryTestEnv.bodegaCentralId,
        ),
        30,
      );
      final actualizado = await env.db.secretaryDao.getDraftById(draft.id);
      expect(actualizado!.status, 'discarded');
    });
  });

  group('D. Ventas (borrador → venta real con caja)', () {
    DraftEngine engine() => env.container.read(draftEngineProvider);

    test('venta contado descuenta stock, crea venta y pago', () async {
      final draft = await engine().createDraft(
        draftType: 'venta',
        bodegaId: SecretaryTestEnv.bodegaCentralId,
        clienteNombre: 'Juan Perez',
        saleType: 'Contado',
      );
      await engine().addItems(
        draftId: draft.id,
        rawItems: const [
          RawDraftItem(nombre: 'Gorra Roja', cantidad: 2), // precio default 8
          RawDraftItem(nombre: 'Pantalon Jeans', cantidad: 1, precioUnitario: 24),
        ],
        context: env.context,
      );
      expect(await engine().validate(draft.id), isEmpty);

      final ventasAntes = (await env.db.select(env.db.ventas).get()).length;
      await engine().execute(draft.id, env.context);

      final ventas = await env.db.select(env.db.ventas).get();
      expect(ventas.length, ventasAntes + 1);
      final venta = ventas.last;
      expect(venta.totalVenta, 2 * 8 + 24);
      expect(venta.saldoPendiente, 0);

      expect(
        await env.stockDe(
          SecretaryTestEnv.prodGorraRojaId,
          SecretaryTestEnv.bodegaCentralId,
        ),
        48, // 50 - 2
      );
      final pagos = await (env.db.select(env.db.pagosVentas)
            ..where((t) => t.ventaId.equals(venta.id)))
          .get();
      expect(pagos.single.montoPagado, 40);
    });

    test('fiado sin nombre de cliente no valida', () async {
      final draft = await engine().createDraft(
        draftType: 'venta',
        bodegaId: SecretaryTestEnv.bodegaCentralId,
        saleType: 'Fiado',
      );
      await engine().addItems(
        draftId: draft.id,
        rawItems: const [RawDraftItem(nombre: 'Gorra Roja', cantidad: 1)],
        context: env.context,
      );
      final errores = await engine().validate(draft.id);
      expect(errores.join(' '), contains('cliente'));
    });

    test('venta con caja cerrada falla y no toca stock', () async {
      await (env.db.update(env.db.cajaSesiones)
            ..where((t) => t.id.equals(SecretaryTestEnv.cajaSesionId)))
          .write(const CajaSesionesCompanion(estadoSesion: Value('cerrada')));

      final draft = await engine().createDraft(
        draftType: 'venta',
        bodegaId: SecretaryTestEnv.bodegaCentralId,
        saleType: 'Contado',
      );
      await engine().addItems(
        draftId: draft.id,
        rawItems: const [RawDraftItem(nombre: 'Gorra Azul', cantidad: 1)],
        context: env.context,
      );

      final contextoSinCaja = AssistantOperationalContext(
        empresaId: SecretaryTestEnv.empresaId,
        usuarioId: SecretaryTestEnv.usuarioId,
        rolId: SecretaryTestEnv.rolId,
        permisos: const [],
        selectedWarehouseId: SecretaryTestEnv.bodegaCentralId,
        allowedWarehouses: env.context.allowedWarehouses,
        cajaSesionAbierta: false,
      );
      await expectLater(
        engine().execute(draft.id, contextoSinCaja),
        throwsA(isA<CajaSesionNoActivaException>()),
      );
      expect(
        await env.stockDe(
          SecretaryTestEnv.prodGorraAzulId,
          SecretaryTestEnv.bodegaCentralId,
        ),
        30,
      );
    });
  });

  group('E. Tools draft.* (la superficie que usa el LLM)', () {
    late String sessionId;
    late DraftToolHandler handler;

    setUp(() async {
      final session =
          await env.db.secretaryDao.createSession(title: 'Test dictado');
      sessionId = session.id;
      handler = DraftToolHandler(
        engine: env.container.read(draftEngineProvider),
        db: env.db,
        sessionId: sessionId,
        context: env.context,
      );
    });

    test('create sin bodega usa la activa; addItems reporta estados',
        () async {
      final creado = await handler.handle('draft.create', {'tipo': 'entrada'});
      expect(creado!['status'], 'success');
      expect(
        (creado['data'] as Map)['bodegaId'],
        SecretaryTestEnv.bodegaCentralId,
      );

      final agregado = await handler.handle('draft.addItems', {
        'items': [
          {'nombre': 'Zapato Deportivo', 'cantidad': 4, 'costoUnitario': 18},
          {'nombre': 'gorra', 'cantidad': 2},
        ],
      });
      final items = ((agregado!['data'] as Map)['items'] as List).cast<Map>();
      expect(items[0]['estado'], 'ready');
      expect(items[1]['estado'], 'needs_review');
      expect(items[1]['candidatos'], isNotEmpty);
    });

    test('getState devuelve totales y errores de validación', () async {
      await handler.handle('draft.create', {'tipo': 'entrada'});
      await handler.handle('draft.addItems', {
        'items': [
          {'nombre': 'Camisa Blanca', 'cantidad': 10, 'costoUnitario': 5},
        ],
      });
      final estado = await handler.handle('draft.getState', {});
      final data = estado!['data'] as Map;
      expect(data['tipo'], 'entrada');
      expect(data['erroresValidacion'], isEmpty);
      expect((data['items'] as List), hasLength(1));
    });

    test('bodega no permitida se rechaza desde la tool', () async {
      final res = await handler.handle('draft.create', {
        'tipo': 'entrada',
        'bodegaId': 'bodega-ajena-999',
      });
      expect(res!['status'], 'error');
    });

    test('tools no-draft devuelven null (las maneja el registry)', () async {
      expect(
        await handler.handle('inventory.getStockPorBodega', {}),
        isNull,
      );
    });
  });

  group('F. Persistencia del chat (sesiones, mensajes, prefs)', () {
    test('mensajes con seq incremental y metadatos de sesión', () async {
      final session =
          await env.db.secretaryDao.createSession(title: 'Charla test');
      await env.db.secretaryDao
          .appendMessage(sessionId: session.id, role: 'user', content: 'hola');
      await env.db.secretaryDao.appendMessage(
        sessionId: session.id,
        role: 'assistant',
        content: 'Hola, ¿en qué ayudo?',
      );

      final mensajes =
          await env.db.secretaryDao.getLastMessages(session.id, limit: 10);
      expect(mensajes.map((m) => m.seq), [1, 2]);

      final actualizada =
          await env.db.secretaryDao.getSessionById(session.id);
      expect(actualizada!.messageCount, 2);
    });

    test('preferencias: una sola fila por usuario', () async {
      final a = await env.db.secretaryDao.getOrCreatePreferences();
      final b = await env.db.secretaryDao.getOrCreatePreferences();
      expect(a.id, b.id);
      expect(a.empresaId, SecretaryTestEnv.empresaId);
      expect(a.confirmBeforeExecute, isTrue); // default seguro
    });

    test('memorias activas rankeadas y soft-delete', () async {
      await env.db.secretaryDao.upsertMemory(
        AiMemoriesCompanion.insert(
          id: 'mem-1',
          empresaId: SecretaryTestEnv.empresaId,
          usuarioId: SecretaryTestEnv.usuarioId,
          category: 'preference',
          content: 'Siempre trabaja en Bodega Central',
        ),
      );
      var memorias = await env.db.secretaryDao.getActiveMemories(
        empresaId: SecretaryTestEnv.empresaId,
        usuarioId: SecretaryTestEnv.usuarioId,
      );
      expect(memorias, hasLength(1));

      await env.db.secretaryDao.deactivateMemory('mem-1');
      memorias = await env.db.secretaryDao.getActiveMemories(
        empresaId: SecretaryTestEnv.empresaId,
        usuarioId: SecretaryTestEnv.usuarioId,
      );
      expect(memorias, isEmpty);
    });
  });
}
