import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Esta línea "despierta" al AuthController.
    // Al leerlo, se ejecuta su método build(), el cual llama a checkAuthStatus().
    // Cuando el estado cambie, el GoRouter (que escucha al provider) hará la redirección automática.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authControllerProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 1. Logo o Icono Principal
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.inventory_2_rounded,
                size: 80,
                color: Colors.blue.shade800,
              ),
            ),

            const SizedBox(height: 24),

            // 2. Nombre de la App
            const Text(
              "Inventario App",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                letterSpacing: 0.5,
              ),
            ),

            const SizedBox(height: 48),

            // 3. Spinner de Carga
            const CircularProgressIndicator(strokeWidth: 3),

            const SizedBox(height: 20),

            Text(
              "Cargando datos...",
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
