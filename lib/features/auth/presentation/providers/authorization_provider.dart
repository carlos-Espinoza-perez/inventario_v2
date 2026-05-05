import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventario_v2/core/db/models/sesion_activa_drift.dart';
import 'package:inventario_v2/core/providers/drift_provider.dart';
import 'package:inventario_v2/features/auth/presentation/providers/auth_provider.dart';

class AuthorizationState {
  final SessionUserDrift? user;
  final String? role;
  final Set<String> permissions;

  const AuthorizationState({
    required this.user,
    required this.role,
    required this.permissions,
  });

  bool get isAuthenticated => user != null;

  bool get isAdmin {
    final normalizedRole = role?.toLowerCase().trim();
    return normalizedRole == 'admin' ||
        normalizedRole == 'administrador' ||
        permissions.contains('*');
  }

  bool can(String permission) {
    if (!isAuthenticated) return false;
    if (isAdmin) return true;
    return permissions.contains(permission);
  }

  bool canAny(Iterable<String> candidates) {
    for (final candidate in candidates) {
      if (can(candidate)) return true;
    }
    return false;
  }

  String get preferredRoute => '/dashboard';
}

final authorizationStateProvider =
    FutureProvider.autoDispose<AuthorizationState>((ref) async {
      final auth = ref.watch(authControllerProvider.notifier);
      final db = ref.watch(driftDatabaseProvider);
      final sesion = auth.sesionActiva ?? await db.authDao.getSesionActiva();
      final user = sesion?.userView ?? auth.usuarioActual ?? await auth.getUser();

      if (user == null) {
        return const AuthorizationState(
          user: null,
          role: null,
          permissions: {},
        );
      }

      return AuthorizationState(
        user: user,
        role: sesion?.rol.nombre,
        permissions: (sesion?.permisos ?? const <String>[]).toSet(),
      );
    });

final hasPermissionProvider = FutureProvider.autoDispose.family<bool, String>((
  ref,
  permission,
) async {
  final auth = await ref.watch(authorizationStateProvider.future);
  return auth.can(permission);
});
