import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repository/movimiento_repository.dart';

final movementDetailProvider =
    FutureProvider.autoDispose.family<Map<String, dynamic>?, String>((
      ref,
      movId,
    ) async {
      final repo = ref.watch(movimientoRepositoryProvider);
      return repo.obtenerDetalleMovimiento(movId);
    });
