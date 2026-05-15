import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repository/movimiento_repository.dart';

final warehouseHistoryProvider =
    FutureProvider.autoDispose.family<List<Map<String, dynamic>>, String>((
      ref,
      bodegaId,
    ) async {
      final repository = ref.watch(movimientoRepositoryProvider);
      return repository.obtenerHistorialBodega(bodegaId);
    });
