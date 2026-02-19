import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inventario_v2/core/providers/app_bar_provider.dart';

class TopAppBarDashboard extends ConsumerWidget implements PreferredSizeWidget {
  final String location;

  const TopAppBarDashboard({super.key, required this.location});

  // 1. RECUPERADO: Altura original de 80
  final double toolbarHeight = 80;

  @override
  Size get preferredSize => Size.fromHeight(toolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appBarState = ref.watch(appBarProvider);
    final bool isDashboardRoot = location == '/dashboard';

    // Lógica para saber si mostramos flecha
    // (Solo si el provider dice TRUE y NO estamos en el dashboard)
    final bool showBackButton = appBarState.showBackButton || !isDashboardRoot;

    return AppBar(
      toolbarHeight: toolbarHeight,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,

      // 2. RECUPERADO: Sombra y Elevación
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.2), // o .withValues(alpha: .2)
      // 3. RECUPERADO: Bordes Redondeados abajo
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),

      // 4. RECUPERADO: Título a la izquierda
      centerTitle: false,

      // 5. Lógica del Leading (Espacio de la flecha)
      // Si no hay flecha, width es 0 para que el título se pegue a la izquierda
      leadingWidth: showBackButton ? 56 : 0,

      leading: showBackButton
          ? IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.black87,
              ),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/dashboard');
                }
                // Reseteamos el título al volver
                ref.read(appBarProvider.notifier).reset();
              },
            )
          : null, // Si es null y leadingWidth es 0, no ocupa espacio

      title: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start, // Alineado a la izquierda
        children: [
          Text(
            isDashboardRoot ? "Sistema de inventario" : appBarState.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20, // Tu tamaño original
              color: Colors.black87,
            ),
          ),
          // Subtítulo dinámico (Solo si no es dashboard)
          if (!isDashboardRoot && appBarState.subtitle != null)
            Text(
              appBarState.subtitle!,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w400,
              ),
            ),
        ],
      ),

      actions: [
        // Acciones dinámicas (ej. Historial)
        if (!isDashboardRoot && appBarState.actions != null)
          ...appBarState.actions!,

        // Avatar de usuario (siempre visible o condicional)
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: CircleAvatar(
            backgroundColor: Colors.grey.shade200,
            child: IconButton(
              icon: const Icon(Icons.person_outline, color: Colors.black),
              onPressed: () {
                // Lógica de perfil
              },
            ),
          ),
        ),
      ],
    );
  }
}
