import 'package:drift/drift.dart';

import 'auth_tables.dart';
import 'inventory_tables.dart';
import 'sync_table.dart';

class Movimientos extends Table with SyncTable {
  TextColumn get empresaId =>
      text().references(Empresas, #id, onDelete: KeyAction.cascade)();
  @ReferenceName('movimientosComoOrigen')
  TextColumn get bodegaOrigenId =>
      text().nullable().references(Bodegas, #id, onDelete: KeyAction.cascade)();
  @ReferenceName('movimientosComoDestino')
  TextColumn get bodegaDestinoId =>
      text().nullable().references(Bodegas, #id, onDelete: KeyAction.cascade)();
  TextColumn get tipoMovimiento => text()();
  TextColumn get estadoMovimiento => text()();
  TextColumn get descripcion => text().nullable()();
  TextColumn get usuarioRegistroId => text().nullable().references(
    Usuarios,
    #id,
    onDelete: KeyAction.cascade,
  )();
  BoolColumn get estado => boolean().withDefault(const Constant(true))();
  DateTimeColumn get fechaEliminacion => dateTime().nullable()();
}

class DetalleMovimientos extends Table with SyncTable {
  TextColumn get movimientoId =>
      text().references(Movimientos, #id, onDelete: KeyAction.cascade)();
  TextColumn get productoId =>
      text().references(Productos, #id, onDelete: KeyAction.cascade)();
  TextColumn get productoVarianteId => text().nullable().references(
    ProductoVariantes,
    #id,
    onDelete: KeyAction.setNull,
  )();
  RealColumn get cantidad => real()();
  RealColumn get costoProveedor => real().withDefault(const Constant(0.0))();
  TextColumn get cargosAdicionalesJson => text().nullable()();
  RealColumn get costoUnitarioFinal =>
      real().withDefault(const Constant(0.0))();
  TextColumn get variantesJson => text().nullable()();
  DateTimeColumn get fechaEliminacion => dateTime().nullable()();
}
