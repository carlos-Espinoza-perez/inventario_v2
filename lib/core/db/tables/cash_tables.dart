import 'package:drift/drift.dart';

import 'auth_tables.dart';
import 'sync_table.dart';

class Cajas extends Table with SyncTable {
  TextColumn get empresaId =>
      text().references(Empresas, #id, onDelete: KeyAction.cascade)();
  TextColumn get bodegaId =>
      text().references(Bodegas, #id, onDelete: KeyAction.cascade)();
  TextColumn get nombre => text().withLength(min: 1, max: 100)();
  @ReferenceName('cajasRegistradas')
  TextColumn get usuarioRegistroId => text().nullable().references(
    Usuarios,
    #id,
    onDelete: KeyAction.cascade,
  )();
  BoolColumn get estado => boolean().withDefault(const Constant(true))();
  DateTimeColumn get fechaEliminacion => dateTime().nullable()();
}

class CajaSesiones extends Table with SyncTable {
  TextColumn get cajaId =>
      text().references(Cajas, #id, onDelete: KeyAction.cascade)();
  @ReferenceName('cajaSesionesAperturadasPor')
  TextColumn get usuarioAperturaId =>
      text().references(Usuarios, #id, onDelete: KeyAction.cascade)();
  @ReferenceName('cajaSesionesCerradasPor')
  TextColumn get usuarioCierreId => text().nullable().references(
    Usuarios,
    #id,
    onDelete: KeyAction.cascade,
  )();
  DateTimeColumn get fechaApertura => dateTime()();
  DateTimeColumn get fechaCierre => dateTime().nullable()();
  RealColumn get montoInicial => real().withDefault(const Constant(0.0))();
  RealColumn get totalVentasSistema =>
      real().withDefault(const Constant(0.0))();
  RealColumn get totalEfectivoReal => real().withDefault(const Constant(0.0))();
  RealColumn get diferencia => real().withDefault(const Constant(0.0))();
  TextColumn get estadoSesion => text()();
  DateTimeColumn get fechaEliminacion => dateTime().nullable()();
}

class CajaMovimientosExtras extends Table with SyncTable {
  TextColumn get cajaSesionId =>
      text().references(CajaSesiones, #id, onDelete: KeyAction.cascade)();
  TextColumn get referenciaVentaId => text().nullable()();
  TextColumn get tipo => text()();
  TextColumn get motivo => text().nullable()();
  RealColumn get monto => real().withDefault(const Constant(0.0))();
  @ReferenceName('movimientosCajaRegistrados')
  TextColumn get usuarioRegistroId => text().nullable().references(
    Usuarios,
    #id,
    onDelete: KeyAction.cascade,
  )();
  BoolColumn get estado => boolean().withDefault(const Constant(true))();
  DateTimeColumn get fechaEliminacion => dateTime().nullable()();
}
