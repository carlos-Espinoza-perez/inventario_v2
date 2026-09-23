import 'package:inventario_v2/core/db/app_database.dart';

/// Snapshot mínimo de una tabla para verificar "no cambió nada" entre dos
/// puntos de un turno: conteo de filas + un checksum liviano calculado en
/// Dart a partir del contenido de cada fila (detecta también un UPDATE que
/// no cambia el conteo, ej. `cantidad_actual` de una fila existente).
class TableSnapshot {
  final int rowCount;
  final int checksum;

  const TableSnapshot({required this.rowCount, required this.checksum});

  bool differsFrom(TableSnapshot other) =>
      rowCount != other.rowCount || checksum != other.checksum;
}

/// Tablas que puede snapshotear `db_unchanged_tables` en los escenarios,
/// tal como se escriben en el YAML (snake_case, nombre SQL real).
const snapshotableTables = {
  'productos',
  'producto_variantes',
  'inventarios',
  'ventas',
  'detalle_ventas',
  'pagos_ventas',
  'clientes',
  'caja_sesiones',
  'caja_movimientos_extras',
};

Future<TableSnapshot> snapshotTable(AppDatabase db, String tableName) async {
  if (!snapshotableTables.contains(tableName)) {
    throw ArgumentError(
      'Tabla "$tableName" no está en la lista de tablas snapshoteables '
      '(db_snapshot.dart::snapshotableTables). Agregala si hace falta.',
    );
  }
  final rows = await db.customSelect('SELECT * FROM $tableName').get();
  var checksum = 0;
  for (final row in rows) {
    // El orden de columnas de `row.data` es estable (viene del cursor de
    // SQLite en el orden de la tabla), así que basta concatenar los
    // valores en ese orden.
    final rowText = row.data.values.map((v) => v.toString()).join('|');
    checksum = (checksum * 31 + rowText.hashCode) & 0x7fffffff;
  }
  return TableSnapshot(rowCount: rows.length, checksum: checksum);
}

Future<Map<String, TableSnapshot>> snapshotTables(
  AppDatabase db,
  List<String> tableNames,
) async {
  final result = <String, TableSnapshot>{};
  for (final name in tableNames) {
    result[name] = await snapshotTable(db, name);
  }
  return result;
}

/// Compara dos snapshots (antes/después de un turno) y devuelve los
/// nombres de tabla que cambiaron.
List<String> diffSnapshots(
  Map<String, TableSnapshot> before,
  Map<String, TableSnapshot> after,
) {
  final changed = <String>[];
  for (final name in before.keys) {
    final b = before[name]!;
    final a = after[name];
    if (a == null || b.differsFrom(a)) changed.add(name);
  }
  return changed;
}
