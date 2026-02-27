import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repository/movimiento_repository.dart';

final movementDetailProvider =
    FutureProvider.family<Map<String, dynamic>?, String>((ref, movId) async {
      final repo = await ref.watch(movimientoRepositoryProvider.future);
      return repo.obtenerDetalleMovimiento(movId);
    });
