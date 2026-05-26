import 'package:drift/drift.dart';

class AppLogs extends Table {
  TextColumn get id => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get level => text()(); // info | warning | error | critical
  TextColumn get module => text().nullable()();
  TextColumn get screen => text().nullable()();
  TextColumn get action => text().nullable()();
  TextColumn get message => text()();
  TextColumn get errorCode => text().nullable()();
  TextColumn get userId => text().nullable()();
  TextColumn get empresaId => text().nullable()();
  TextColumn get bodegaId => text().nullable()();
  TextColumn get appVersionName => text().nullable()();
  IntColumn get appVersionCode => integer().nullable()();
  TextColumn get buildNumber => text().nullable()();
  TextColumn get deviceModel => text().nullable()();
  TextColumn get androidVersion => text().nullable()();
  BoolColumn get isOnline => boolean().nullable()();
  TextColumn get metadataJson => text().nullable()();
  BoolColumn get sentToRemote =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get remoteSentAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
