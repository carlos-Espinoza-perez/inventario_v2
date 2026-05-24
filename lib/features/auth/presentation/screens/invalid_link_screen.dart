import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inventario_v2/features/auth/presentation/providers/auth_provider.dart';

class InvalidLinkScreen extends ConsumerWidget {
  const InvalidLinkScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enlace invalido'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 48),
              Icon(Icons.link_off, size: 80, color: Colors.red.shade400),
              const SizedBox(height: 24),
              Consumer(
                builder: (context, ref, child) {
                  final linkError = ref
                      .read(authControllerProvider.notifier)
                      .linkError;
                  final esExpirado = linkError == 'otp_expired';

                  return Column(
                    children: [
                      Text(
                        esExpirado
                            ? 'Enlace caducado o utilizado'
                            : 'Error al procesar la invitacion',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        esExpirado
                            ? 'El enlace de invitacion o recuperacion que utilizaste ya no es valido. '
                                  'Por seguridad, estos enlaces son de un solo uso y expiran despues de un tiempo.\n\n'
                                  'Por favor, solicita a tu administrador que te envie una nueva invitacion.'
                            : 'Detalle del error:\n$linkError',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  );
                },
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
