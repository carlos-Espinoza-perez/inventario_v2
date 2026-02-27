import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repository/movimiento_repository.dart';

final warehouseHistoryProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((
      ref,
      bodegaId,
    ) async {
      final repository = await ref.watch(movimientoRepositoryProvider.future);
      return repository.obtenerHistorialBodega(bodegaId);
    });
