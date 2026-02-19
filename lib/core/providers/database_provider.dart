import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'isar_service.dart';
import 'package:isar/isar.dart';

final isarServiceProvider = Provider<IsarService>((ref) {
  return IsarService();
});

final isarDbProvider = FutureProvider<Isar>((ref) async {
  final service = ref.watch(isarServiceProvider);
  return service.db;
});
