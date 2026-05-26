import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/widgets/update_dialog.dart';
import '../../../../core/providers/app_update_provider.dart';
import '../../../../core/services/app_update_service.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _dialogShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authControllerProvider);
      // Verificación de actualización en background — no bloquea el inicio
      ref.read(appUpdateProvider.notifier).checkForUpdate();
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AppUpdateState>(appUpdateProvider, (_, next) {
      if (!mounted || _dialogShown) return;
      if (next.status != UpdateStatus.updateAvailable) return;

      _dialogShown = true;
      final isRequired = next.updateType == UpdateType.requiredUpdate;

      showDialog<void>(
        context: context,
        barrierDismissible: !isRequired,
        builder: (_) => const UpdateDialog(),
      ).then((_) {
        // Si el usuario cerró un diálogo opcional sin instalar, reiniciamos
        // el flag para que no vuelva a aparecer automáticamente en este ciclo.
        if (mounted && next.updateType == UpdateType.optionalUpdate) {
          _dialogShown = false;
        }
      });
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
