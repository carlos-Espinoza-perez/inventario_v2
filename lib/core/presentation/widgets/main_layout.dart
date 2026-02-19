import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // 1. Importar Riverpod
import 'package:go_router/go_router.dart';
import 'package:inventario_v2/core/providers/auto_sync_provider.dart';
import 'package:inventario_v2/features/dashboard/presentation/widgets/bottom_app_bar_dashboard.dart';
import 'package:inventario_v2/features/dashboard/presentation/widgets/top_app_bar_dashboard.dart';

class MainLayout extends ConsumerWidget {
  final Widget child;
  final String location;

  const MainLayout({super.key, required this.child, required this.location});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(autoSyncProvider);
    final bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: TopAppBarDashboard(location: location),

      body: SafeArea(
        child: Stack(
          children: [
            child,
            Positioned(
              top: 16,
              right: 16,
              child: _SyncStatusIndicator(isSyncing: syncState.isLoading),
            ),
          ],
        ),
      ),

      bottomNavigationBar: isKeyboardOpen
          ? null
          : const BottomAppBarDashboard(),

      floatingActionButton: isKeyboardOpen
          ? null
          : FloatingActionButton(
              onPressed: () {
                context.push('/dashboard');
              },
              tooltip: 'Home',
              elevation: 0,
              shape: const CircleBorder(),
              backgroundColor: Colors.cyan,
              child: const Icon(Icons.home_rounded, color: Colors.black87),
            ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

// 6. Widget privado para el diseño del indicador
class _SyncStatusIndicator extends StatelessWidget {
  final bool isSyncing;

  const _SyncStatusIndicator({required this.isSyncing});

  @override
  Widget build(BuildContext context) {
    // Usamos AnimatedSwitcher para que aparezca y desaparezca suavemente
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        // Efecto de entrada: Escala + Desvanecimiento
        return ScaleTransition(
          scale: animation,
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      child: isSyncing
          ? Container(
              key: const ValueKey('loading'), // Key necesaria para la animación
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9), // Fondo semitransparente
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.cyan, // Color de tu tema
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Sincronizando...",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(), // Si no está cargando, no muestra nada
    );
  }
}
