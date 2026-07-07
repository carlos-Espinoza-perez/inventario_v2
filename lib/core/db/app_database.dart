import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

import 'tables/auth_tables.dart';
import 'tables/cash_tables.dart';
import 'tables/inventory_tables.dart';
import 'tables/sales_tables.dart';
import 'tables/logistics_tables.dart';
import 'tables/log_tables.dart';
import 'tables/secretary_tables.dart';
import 'daos/auth_dao.dart';
import 'daos/inventory_dao.dart';
import 'daos/sales_dao.dart';
import 'daos/logistics_dao.dart';
import 'daos/secretary_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Empresas,
    Usuarios,
    Bodegas,
    BodegasUsuarios,
    Roles,
    AccesosRol,
    Cajas,
    CajaSesiones,
    CajaMovimientosExtras,
    Categorias,
    Productos,
    ProductoVariantes,
    Inventarios,
    Clientes,
    Ventas,
    DetalleVentas,
    PagosVentas,
    Movimientos,
    DetalleMovimientos,
    AppLogs,
    ChatSessions,
    ChatMessages,
    AiMemories,
    AiPreferences,
    ChatTurnTraces,
    SecretaryDrafts,
    SecretaryDraftItems,
  ],
  daos: [AuthDao, InventoryDao, SalesDao, LogisticsDao, SecretaryDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Para tests de integración: permite inyectar un ejecutor en memoria
  /// (NativeDatabase.memory()) en lugar del archivo real del dispositivo.
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 10;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        await _createIndexes();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // from < 5 creaba las tablas del assistant viejo; ya no es necesario
        // porque v10 las elimina (quien salta de v4 a v10 nunca las usa).
        if (from < 6) {
          await m.addColumn(
            detalleMovimientos,
            detalleMovimientos.productoVarianteId,
          );
          await _backfillDetalleMovimientoVariantIds();
          await _createIndexes();
        }
        if (from < 7) {
          await m.createTable(appLogs);
        }
        if (from < 8) {
          await m.createTable(chatSessions);
          await m.createTable(chatMessages);
          await m.createTable(aiMemories);
          await m.createTable(aiPreferences);
          await m.createTable(chatTurnTraces);
          await m.createTable(secretaryDrafts);
          await m.createTable(secretaryDraftItems);
          await _createIndexes();
        }
        if (from >= 8 && from < 9) {
          // v8 ya tenía chat_turn_traces sin estas columnas de diagnóstico;
          // quien venía de <8 las creó completas con createTable.
          await m.addColumn(chatTurnTraces, chatTurnTraces.requestJson);
          await m.addColumn(chatTurnTraces, chatTurnTraces.errorText);
        }
        if (from < 10) {
          // Retirada del assistant viejo (SEC-IA-001 F7.4): sus borradores
          // eran temporales y locales, no hay datos que migrar.
          await customStatement(
            'DROP TABLE IF EXISTS assistant_entry_session_items',
          );
          await customStatement(
            'DROP TABLE IF EXISTS assistant_entry_sessions',
          );
        }
      },
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
        await _createIndexes();
      },
    );
  }

  Future<void> _createIndexes() async {
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_usuarios_empresa_id ON usuarios (empresa_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_bodegas_empresa_id ON bodegas (empresa_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_productos_empresa_id ON productos (empresa_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_producto_variantes_producto_id ON producto_variantes (producto_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_producto_variantes_sku ON producto_variantes (sku)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_inventarios_bodega_id ON inventarios (bodega_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_inventarios_producto_variante_id ON inventarios (producto_variante_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_ventas_empresa_id ON ventas (empresa_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_ventas_caja_sesion_id ON ventas (caja_sesion_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_caja_sesiones_caja_id ON caja_sesiones (caja_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_caja_sesiones_usuario_apertura_id ON caja_sesiones (usuario_apertura_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_caja_movimientos_extras_caja_sesion_id ON caja_movimientos_extras (caja_sesion_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_sync_status_productos ON productos (sync_status)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_sync_status_ventas ON ventas (sync_status)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_sync_status_caja_movimientos_extras ON caja_movimientos_extras (sync_status)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_detalle_movimientos_producto_variante_id ON detalle_movimientos (producto_variante_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_chat_sessions_usuario_actividad ON chat_sessions (usuario_id, last_message_at)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_chat_messages_session_seq ON chat_messages (session_id, seq)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_ai_memories_usuario_activas ON ai_memories (usuario_id, is_active)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_secretary_draft_items_draft ON secretary_draft_items (draft_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_sync_status_chat_sessions ON chat_sessions (sync_status)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_sync_status_chat_messages ON chat_messages (sync_status)',
    );
  }

  Future<void> _backfillDetalleMovimientoVariantIds() async {
    await customStatement(r'''
      UPDATE detalle_movimientos
      SET producto_variante_id = (
        SELECT pv.id
        FROM producto_variantes pv
        WHERE pv.producto_id = detalle_movimientos.producto_id
          AND pv.sku = json_extract(detalle_movimientos.variantes_json, '$[0].sku')
        LIMIT 1
      )
      WHERE producto_variante_id IS NULL
        AND variantes_json IS NOT NULL
        AND json_valid(variantes_json)
        AND json_extract(variantes_json, '$[0].sku') IS NOT NULL
    ''');
  }

  Future<void> replaceEmpresaData(Empresa empresa, Usuario usuario) async {
    return transaction(() async {
      await delete(empresas).go();
      await delete(usuarios).go();

      await into(empresas).insert(empresa);
      await into(usuarios).insert(usuario);
    });
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'app_database.sqlite'));

    if (Platform.isAndroid) {
      // await applyWorkaroundToOpenSqlite3OnOldAndroidDevices();
    }

    final cachebase = await getTemporaryDirectory();
    sqlite3.tempDirectory = cachebase.path;

    return NativeDatabase.createInBackground(file);
  });
}
