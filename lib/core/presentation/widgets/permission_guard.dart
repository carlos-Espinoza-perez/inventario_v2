import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventario_v2/core/presentation/widgets/permission_denied_view.dart';
import 'package:inventario_v2/features/auth/presentation/providers/authorization_provider.dart';

class PermissionGuard extends ConsumerWidget {
  final String permission;
  final Widget child;

  const PermissionGuard({
    super.key,
    required this.permission,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authorizationAsync = ref.watch(authorizationStateProvider);

    return authorizationAsync.when(
      loading: () => const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Scaffold(
        backgroundColor: Colors.white,
        body: PermissionDeniedView(
          title: 'No fue posible validar tus permisos',
          message: error.toString(),
          redirectRoute: '/profile',
        ),
      ),
      data: (authorization) {
        if (!authorization.can(permission)) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: PermissionDeniedView(
              redirectRoute: authorization.preferredRoute,
            ),
          );
        }

        return child;
      },
    );
  }
}
