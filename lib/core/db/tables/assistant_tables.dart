import 'package:drift/drift.dart';

import 'auth_tables.dart';
import 'inventory_tables.dart';

class AssistantEntrySessions extends Table {
  TextColumn get id => text()();
  TextColumn get empresaId =>
      text().references(Empresas, #id, onDelete: KeyAction.cascade)();
  TextColumn get usuarioId =>
      text().references(Usuarios, #id, onDelete: KeyAction.cascade)();
  TextColumn get bodegaId =>
      text().references(Bodegas, #id, onDelete: KeyAction.cascade)();
  TextColumn get status => text().withDefault(const Constant('active'))();
  TextColumn get description => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class AssistantEntrySessionItems extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId => text().references(
    AssistantEntrySessions,
    #id,
    onDelete: KeyAction.cascade,
  )();
  TextColumn get productId => text().nullable().references(
    Productos,
    #id,
    onDelete: KeyAction.setNull,
  )();
  TextColumn get proposedName => text()();
  TextColumn get resolvedName => text().nullable()();
  TextColumn get categoryId => text().nullable().references(
    Categorias,
    #id,
    onDelete: KeyAction.setNull,
  )();
  TextColumn get categoryName => text().nullable()();
  RealColumn get quantity => real()();
  RealColumn get unitCost => real().nullable()();
  RealColumn get unitPrice => real().nullable()();
  TextColumn get status => text().withDefault(const Constant('ready'))();
  TextColumn get candidatesJson => text().nullable()();
  BoolColumn get isNewProduct => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
