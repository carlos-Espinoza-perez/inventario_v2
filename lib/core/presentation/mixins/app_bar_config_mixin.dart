import 'package:flutter/material.dart';
import 'package:inventario_v2/core/router/route_observer.dart';

/// Mixin para pantallas ConsumerStatefulWidget.
/// Garantiza que configureAppBar() se llame al entrar Y al volver con back.
mixin AppBarConfigMixin<T extends StatefulWidget> on State<T>
    implements RouteAware {
  /// Cada pantalla implementa este método con su llamada a setOptions().
  void configureAppBar();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null) {
      appRouteObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    super.dispose();
  }

  // Se llama cuando esta pantalla vuelve a ser visible tras un pop
  @override
  void didPopNext() {
    Future.microtask(configureAppBar);
  }

  // Se llama cuando esta pantalla es cargada en el navegador
  @override
  void didPush() {
    Future.microtask(configureAppBar);
  }

  @override
  void didPop() {}

  @override
  void didPushNext() {}
}
