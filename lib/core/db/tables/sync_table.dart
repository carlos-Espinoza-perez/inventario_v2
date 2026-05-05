import 'package:drift/drift.dart';

mixin SyncTable on Table {
  // Usamos UUID como ID principal para evitar colisiones offline
  TextColumn get id => text()();
  
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  
  // Estados: 'synced', 'pending_insert', 'pending_update'
  TextColumn get syncStatus => text().withDefault(const Constant('pending_insert'))();

  @override
  Set<Column> get primaryKey => {id};
}
