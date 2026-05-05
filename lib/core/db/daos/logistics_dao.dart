import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/logistics_tables.dart';

part 'logistics_dao.g.dart';

@DriftAccessor(tables: [Movimientos, DetalleMovimientos])
class LogisticsDao extends DatabaseAccessor<AppDatabase> with _$LogisticsDaoMixin {
  LogisticsDao(AppDatabase db) : super(db);

  // Muted for initial generation
}
