import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventario_v2/core/db/app_database.dart';
import 'package:inventario_v2/core/providers/drift_provider.dart';

import 'secretary_chat_provider.dart';

/// Sesiones de chat del usuario activo, ordenadas por actividad reciente.
final chatSessionsProvider = StreamProvider<List<ChatSession>>((ref) async* {
  final db = ref.watch(driftDatabaseProvider);
  final usuario = await db.authDao.getUsuarioActual();
  if (usuario == null) {
    yield const [];
    return;
  }
  yield* ref.watch(chatRepositoryProvider).watchSessions(usuario.id);
});
