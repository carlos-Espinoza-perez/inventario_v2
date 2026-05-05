import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PermissionDeniedView extends StatelessWidget {
  final String title;
  final String message;
  final String redirectRoute;

  const PermissionDeniedView({
    super.key,
    this.title = 'Acceso restringido',
    this.message =
        'Tu rol no tiene permiso para entrar a esta sección. Consulta con un administrador.',
    this.redirectRoute = '/dashboard',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock_outline_rounded,
                size: 34,
                color: Colors.orange.shade800,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700, height: 1.35),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => context.go(redirectRoute),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyan.shade800,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Ir a una vista permitida'),
            ),
          ],
        ),
      ),
    );
  }
}
