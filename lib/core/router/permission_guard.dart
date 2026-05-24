import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventario_v2/features/auth/presentation/providers/authorization_provider.dart';
import 'package:inventario_v2/features/auth/presentation/screens/access_denied_screen.dart';

/// Widget que protege una pantalla verificando que el usuario tenga
/// el permiso requerido. Si no lo tiene, muestra AccessDeniedScreen.
class PermissionGuard extends ConsumerWidget {
  /// El código de permiso requerido para acceder a esta pantalla.
  /// Debe ser uno de los valores de `PermissionCode`.
  final String requiredPermission;

  /// La pantalla que se mostrará si el usuario tiene el permiso.
  final Widget child;

  const PermissionGuard({
    super.key,
    required this.requiredPermission,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authStateAsync = ref.watch(authorizationStateProvider);

    return authStateAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => AccessDeniedScreen(
        message: 'Error al verificar permisos: $error',
      ),
      data: (authState) {
        if (authState.can(requiredPermission)) {
          return child;
        }
        return const AccessDeniedScreen();
      },
    );
  }
}
