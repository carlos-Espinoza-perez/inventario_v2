import 'package:drift/drift.dart';

import 'sync_table.dart';

class Empresas extends Table with SyncTable {
  TextColumn get nombre => text().withLength(min: 1, max: 100)();
  TextColumn get nombreComercial => text().nullable()();
  TextColumn get ruc => text().nullable()();
  TextColumn get configuracion => text().nullable()();
  BoolColumn get estado => boolean().withDefault(const Constant(true))();
  TextColumn get usuarioRegistroId => text().nullable()();
  DateTimeColumn get fechaEliminacion => dateTime().nullable()();
}

class Usuarios extends Table with SyncTable {
  TextColumn get empresaId =>
      text().references(Empresas, #id, onDelete: KeyAction.cascade)();
  TextColumn get rolId =>
      text().references(Roles, #id, onDelete: KeyAction.cascade)();
  TextColumn get nombreCompleto => text().withLength(min: 1, max: 120)();
  TextColumn get correo => text().nullable()();
  TextColumn get passwordHash => text().nullable()();
  TextColumn get pinOffline => text().nullable()();
  @ReferenceName('usuariosCreados')
  TextColumn get usuarioRegistroId => text().nullable().references(
    Usuarios,
    #id,
    onDelete: KeyAction.cascade,
  )();
  TextColumn get bodegaDefaultId =>
      text().nullable().references(Bodegas, #id, onDelete: KeyAction.cascade)();
  BoolColumn get estado => boolean().withDefault(const Constant(true))();
  DateTimeColumn get fechaEliminacion => dateTime().nullable()();
}

class Bodegas extends Table with SyncTable {
  TextColumn get empresaId =>
      text().references(Empresas, #id, onDelete: KeyAction.cascade)();
  TextColumn get nombre => text().withLength(min: 1, max: 100)();
  TextColumn get direccion => text().nullable()();
  TextColumn get descripcion => text().nullable()();
  BoolColumn get esPuntoVenta => boolean().withDefault(const Constant(false))();
  @ReferenceName('bodegasRegistradas')
  TextColumn get usuarioRegistroId => text().nullable()();
  BoolColumn get estado => boolean().withDefault(const Constant(true))();
  DateTimeColumn get fechaEliminacion => dateTime().nullable()();
}

class BodegasUsuarios extends Table with SyncTable {
  TextColumn get usuarioId =>
      text().references(Usuarios, #id, onDelete: KeyAction.cascade)();
  TextColumn get bodegaId =>
      text().references(Bodegas, #id, onDelete: KeyAction.cascade)();
  @ReferenceName('bodegasUsuariosRegistradosPor')
  TextColumn get usuarioRegistroId => text().nullable().references(
    Usuarios,
    #id,
    onDelete: KeyAction.cascade,
  )();
  BoolColumn get estado => boolean().withDefault(const Constant(true))();
  DateTimeColumn get fechaEliminacion => dateTime().nullable()();
}

class Roles extends Table with SyncTable {
  TextColumn get empresaId =>
      text().references(Empresas, #id, onDelete: KeyAction.cascade)();
  TextColumn get nombre => text().withLength(min: 1, max: 100)();
  BoolColumn get userAdmin => boolean().withDefault(const Constant(false))();
  @ReferenceName('rolesRegistrados')
  TextColumn get usuarioRegistroId => text().nullable()();
  BoolColumn get estado => boolean().withDefault(const Constant(true))();
  DateTimeColumn get fechaEliminacion => dateTime().nullable()();
}

class AccesosRol extends Table with SyncTable {
  TextColumn get rolId =>
      text().references(Roles, #id, onDelete: KeyAction.cascade)();
  TextColumn get codigoAcceso => text()();
  @ReferenceName('accesosRolRegistrados')
  TextColumn get usuarioRegistroId => text().nullable().references(
    Usuarios,
    #id,
    onDelete: KeyAction.cascade,
  )();
  BoolColumn get estado => boolean().withDefault(const Constant(true))();
  DateTimeColumn get fechaEliminacion => dateTime().nullable()();
}
