import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inventario_v2/features/auth/presentation/providers/auth_provider.dart';

class InvalidLinkScreen extends ConsumerWidget {
  const InvalidLinkScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final linkError = ref.read(authControllerProvider.notifier).linkError;
    final isExpired = linkError == 'otp_expired';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Enlace no disponible'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 48),
              Icon(Icons.link_off, size: 80, color: Colors.red.shade400),
              const SizedBox(height: 24),
              Text(
                isExpired
                    ? 'Enlace caducado o utilizado'
                    : 'No pudimos abrir este enlace',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                isExpired
                    ? 'Este enlace ya expiro o fue utilizado. Por seguridad, solicita uno nuevo desde la app o con tu administrador.'
                    : 'El enlace no se pudo validar. Intenta solicitar uno nuevo. Si el problema continua, contacta al administrador.',
                style: const TextStyle(fontSize: 16, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(authControllerProvider.notifier).clearLinkError();
                    context.go('/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyan.shade800,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Volver al inicio',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
