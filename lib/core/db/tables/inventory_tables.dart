import 'package:drift/drift.dart';

import 'auth_tables.dart';
import 'sync_table.dart';

class Categorias extends Table with SyncTable {
  TextColumn get empresaId =>
      text().references(Empresas, #id, onDelete: KeyAction.cascade)();
  TextColumn get nombre => text()();
  TextColumn get categoriaPadreId =>
      text().nullable().references(Categorias, #id, onDelete: KeyAction.cascade)();
  TextColumn get especificacionJson => text().nullable()();
  @ReferenceName('categoriasRegistradas')
  TextColumn get usuarioRegistroId =>
      text().nullable().references(Usuarios, #id, onDelete: KeyAction.cascade)();
  BoolColumn get estado => boolean().withDefault(const Constant(true))();
  DateTimeColumn get fechaEliminacion => dateTime().nullable()();
}

class Productos extends Table with SyncTable {
  TextColumn get empresaId =>
      text().references(Empresas, #id, onDelete: KeyAction.cascade)();
  TextColumn get categoriaId =>
      text().nullable().references(Categorias, #id, onDelete: KeyAction.cascade)();
  TextColumn get nombre => text()();
  TextColumn get codigoPersonalizado => text().nullable()();
  TextColumn get descripcion => text().nullable()();
  TextColumn get especificacionJson => text().nullable()();
  RealColumn get precioBase => real().nullable()();
  RealColumn get ultimoCosto => real().withDefault(const Constant(0.0))();
  RealColumn get ultimoPrecioVenta => real().withDefault(const Constant(0.0))();
  TextColumn get imagenUrl => text().nullable()();
  TextColumn get imagenLocal => text().nullable()();
  TextColumn get embedding => text().nullable()();
  @ReferenceName('productosRegistrados')
  TextColumn get usuarioRegistroId =>
      text().nullable().references(Usuarios, #id, onDelete: KeyAction.cascade)();
  BoolColumn get estado => boolean().withDefault(const Constant(true))();
  DateTimeColumn get fechaEliminacion => dateTime().nullable()();
}

class ProductoVariantes extends Table with SyncTable {
  TextColumn get productoId =>
      text().references(Productos, #id, onDelete: KeyAction.cascade)();
  TextColumn get sku => text()();
  TextColumn get talla => text().nullable()();
  TextColumn get color => text().nullable()();
  RealColumn get precioEspecifico => real().nullable()();
  RealColumn get costoEspecifico => real().nullable()();
  @ReferenceName('variantesRegistradas')
  TextColumn get usuarioRegistroId =>
      text().nullable().references(Usuarios, #id, onDelete: KeyAction.cascade)();
  BoolColumn get estado => boolean().withDefault(const Constant(true))();
  DateTimeColumn get fechaEliminacion => dateTime().nullable()();
}

class Inventarios extends Table with SyncTable {
  TextColumn get productoVarianteId =>
      text().references(ProductoVariantes, #id, onDelete: KeyAction.cascade)();
  TextColumn get bodegaId =>
      text().references(Bodegas, #id, onDelete: KeyAction.cascade)();
  RealColumn get cantidadActual => real().withDefault(const Constant(0.0))();
  RealColumn get cantidadReservada => real().withDefault(const Constant(0.0))();
  TextColumn get ubicacionPasillo => text().nullable()();
  RealColumn get precioVenta => real().withDefault(const Constant(0.0))();
  RealColumn get costoPromedio => real().withDefault(const Constant(0.0))();
  @ReferenceName('inventariosActualizadosPor')
  TextColumn get actualizadoPor =>
      text().nullable().references(Usuarios, #id, onDelete: KeyAction.cascade)();
  BoolColumn get estado => boolean().withDefault(const Constant(true))();
  DateTimeColumn get fechaEliminacion => dateTime().nullable()();
}
