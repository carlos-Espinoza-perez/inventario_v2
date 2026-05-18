import 'package:inventario_v2/core/providers/drift_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sync_status_provider.g.dart';

class TableSyncStats {
  final String tableName;
  final String displayName;
  final int total;
  final int synced;
  final int pending;
  final int errors;

  const TableSyncStats({
    required this.tableName,
    required this.displayName,
    required this.total,
    required this.synced,
    required this.pending,
    required this.errors,
  });
}

@riverpod
class SyncStatusReport extends _$SyncStatusReport {
  @override
  Future<List<TableSyncStats>> build() async {
    final db = ref.watch(driftDatabaseProvider);

    final tables = [
      ('empresas', 'Empresas'),
      ('roles', 'Roles'),
      ('accesos_rol', 'Permisos de Rol'),
      ('usuarios', 'Usuarios'),
      ('bodegas', 'Bodegas'),
      ('bodegas_usuarios', 'Asignaciones Bodega'),
      ('cajas', 'Cajas'),
      ('caja_sesiones', 'Sesiones de Caja'),
      ('caja_movimientos_extras', 'Movimientos Extra Caja'),
      ('categorias', 'Categorías'),
      ('productos', 'Productos'),
      ('producto_variantes', 'Variantes de Producto'),
      ('inventarios', 'Inventarios'),
      ('clientes', 'Clientes'),
      ('ventas', 'Ventas'),
      ('detalle_ventas', 'Detalle de Ventas'),
      ('pagos_ventas', 'Pagos de Ventas'),
      ('movimientos', 'Movimientos de Inventario'),
      ('detalle_movimientos', 'Detalle de Movimientos'),
    ];

    final result = <TableSyncStats>[];

    for (final t in tables) {
      final tableName = t.$1;
      final displayName = t.$2;

      try {
        final rows = await db.customSelect(
          "SELECT sync_status, COUNT(*) as cnt FROM $tableName GROUP BY sync_status",
        ).get();

        int synced = 0;
        int pending = 0;
        int errors = 0;

        for (final row in rows) {
          final status = row.read<String>('sync_status');
          final cnt = row.read<int>('cnt');

          if (status == 'synced') {
            synced += cnt;
          } else if (status == 'pending_insert' || status == 'pending_update') {
            pending += cnt;
          } else if (status == 'sync_error') {
            errors += cnt;
          }
        }

        final total = synced + pending + errors;

        result.add(
          TableSyncStats(
            tableName: tableName,
            displayName: displayName,
            total: total,
            synced: synced,
            pending: pending,
            errors: errors,
          ),
        );
      } catch (e) {
        // Tabla podría no tener la estructura o estar bloqueada
        result.add(
          TableSyncStats(
            tableName: tableName,
            displayName: displayName,
            total: 0,
            synced: 0,
            pending: 0,
            errors: 0,
          ),
        );
      }
    }

    return result;
  }

  Future<void> refreshStats() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(build);
  }
}
