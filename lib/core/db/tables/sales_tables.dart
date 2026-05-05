import 'package:drift/drift.dart';

import 'auth_tables.dart';
import 'cash_tables.dart';
import 'inventory_tables.dart';
import 'sync_table.dart';

class Clientes extends Table with SyncTable {
  TextColumn get empresaId =>
      text().references(Empresas, #id, onDelete: KeyAction.cascade)();
  TextColumn get nombre => text().withLength(min: 1, max: 100)();
  TextColumn get identificacion => text().nullable()();
  TextColumn get celular => text().nullable()();
  TextColumn get direccion => text().nullable()();
  RealColumn get montoCreditoMaximo => real().withDefault(const Constant(0.0))();
  RealColumn get saldoDeudorActual => real().withDefault(const Constant(0.0))();
  @ReferenceName('clientesRegistrados')
  TextColumn get usuarioRegistroId =>
      text().nullable().references(Usuarios, #id, onDelete: KeyAction.cascade)();
  BoolColumn get estado => boolean().withDefault(const Constant(true))();
  DateTimeColumn get fechaEliminacion => dateTime().nullable()();
}

class Ventas extends Table with SyncTable {
  TextColumn get empresaId =>
      text().references(Empresas, #id, onDelete: KeyAction.cascade)();
  TextColumn get clienteId =>
      text().references(Clientes, #id, onDelete: KeyAction.cascade)();
  TextColumn get usuarioId =>
      text().references(Usuarios, #id, onDelete: KeyAction.cascade)();
  TextColumn get cajaSesionId =>
      text().references(CajaSesiones, #id, onDelete: KeyAction.cascade)();
  TextColumn get tipoVenta => text()();
  TextColumn get estadoPago => text()();
  RealColumn get totalVenta => real().withDefault(const Constant(0.0))();
  RealColumn get totalPagado => real().withDefault(const Constant(0.0))();
  RealColumn get saldoPendiente => real().withDefault(const Constant(0.0))();
  DateTimeColumn get fechaVenta => dateTime()();
  DateTimeColumn get fechaVencimiento => dateTime().nullable()();
  BoolColumn get estado => boolean().withDefault(const Constant(true))();
  DateTimeColumn get fechaEliminacion => dateTime().nullable()();
}

class DetalleVentas extends Table with SyncTable {
  TextColumn get ventaId =>
      text().references(Ventas, #id, onDelete: KeyAction.cascade)();
  TextColumn get productoId =>
      text().references(Productos, #id, onDelete: KeyAction.cascade)();
  TextColumn get productoVarianteId =>
      text().nullable().references(ProductoVariantes, #id, onDelete: KeyAction.cascade)();
  RealColumn get cantidad => real()();
  RealColumn get precioUnitario => real()();
  RealColumn get descuento => real().withDefault(const Constant(0.0))();
  RealColumn get subTotal => real().withDefault(const Constant(0.0))();
  RealColumn get costoHistoricoCompra =>
      real().withDefault(const Constant(0.0))();
  DateTimeColumn get fechaEliminacion => dateTime().nullable()();
}

class PagosVentas extends Table with SyncTable {
  TextColumn get ventaId =>
      text().references(Ventas, #id, onDelete: KeyAction.cascade)();
  TextColumn get cajaSesionId =>
      text().references(CajaSesiones, #id, onDelete: KeyAction.cascade)();
  RealColumn get montoPagado => real()();
  TextColumn get metodoPago => text()();
  TextColumn get referencia => text().nullable()();
  @ReferenceName('pagosVentasRegistrados')
  TextColumn get usuarioRegistroId =>
      text().nullable().references(Usuarios, #id, onDelete: KeyAction.cascade)();
  BoolColumn get estado => boolean().withDefault(const Constant(true))();
  DateTimeColumn get fechaRegistro => dateTime()();
  DateTimeColumn get fechaEliminacion => dateTime().nullable()();
}
