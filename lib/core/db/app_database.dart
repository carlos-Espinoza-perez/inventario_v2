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
import 'tables/assistant_tables.dart';
import 'daos/auth_dao.dart';
import 'daos/inventory_dao.dart';
import 'daos/sales_dao.dart';
import 'daos/logistics_dao.dart';

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
    AssistantEntrySessions,
    AssistantEntrySessionItems,
  ],
  daos: [AuthDao, InventoryDao, SalesDao, LogisticsDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        await _createIndexes();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 5) {
          await m.createTable(assistantEntrySessions);
          await m.createTable(assistantEntrySessionItems);
          await _createIndexes();
        }
        if (from < 6) {
          await m.addColumn(
            detalleMovimientos,
            detalleMovimientos.productoVarianteId,
          );
          await _backfillDetalleMovimientoVariantIds();
          await _createIndexes();
        } else if (from != to) {
          await transaction(() async {
            await m.deleteTable('assistant_entry_session_items');
            await m.deleteTable('assistant_entry_sessions');
            await m.deleteTable('detalle_movimientos');
            await m.deleteTable('movimientos');
            await m.deleteTable('pagos_ventas');
            await m.deleteTable('caja_movimientos_extras');
            await m.deleteTable('detalle_ventas');
            await m.deleteTable('ventas');
            await m.deleteTable('clientes');
            await m.deleteTable('inventarios');
            await m.deleteTable('producto_variantes');
            await m.deleteTable('productos');
            await m.deleteTable('categorias');
            await m.deleteTable('caja_sesiones');
            await m.deleteTable('cajas');
            await m.deleteTable('accesos_rol');
            await m.deleteTable('roles');
            await m.deleteTable('bodegas_usuarios');
            await m.deleteTable('bodegas');
            await m.deleteTable('usuarios');
            await m.deleteTable('empresas');
            await m.createAll();
          });
          await _createIndexes();
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
      'CREATE INDEX IF NOT EXISTS idx_assistant_entry_sessions_active ON assistant_entry_sessions (empresa_id, usuario_id, bodega_id, status)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_assistant_entry_items_session ON assistant_entry_session_items (session_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_detalle_movimientos_producto_variante_id ON detalle_movimientos (producto_variante_id)',
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
