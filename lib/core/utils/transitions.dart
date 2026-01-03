import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Función Helper para animación de Slide (Derecha a Izquierda)
CustomTransitionPage buildPageWithSlideTransition<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey, // IMPORTANTE: Mantiene el estado de la página
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // Definimos desde dónde viene la página
      // Offset(1.0, 0.0) = Viene de la DERECHA
      // Offset(0.0, 1.0) = Viene de ABAJO
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.easeInOut; // Curva de velocidad suave

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(position: animation.drive(tween), child: child);
    },
  );
}

CustomTransitionPage buildPageWithFadeTransition<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurveTween(curve: Curves.easeInOutCirc).animate(animation),
        child: child,
      );
    },
  );
}
