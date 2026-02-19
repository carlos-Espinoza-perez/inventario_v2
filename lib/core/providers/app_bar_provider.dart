import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 1. La clase de configuración (El estado)
class AppBarState {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback?
  onBackMetric; // Para interceptar el botón atrás si quieres

  const AppBarState({
    this.title = 'Sistema de inventario', // Título por defecto
    this.subtitle,
    this.actions,
    this.showBackButton = false,
    this.onBackMetric,
  });

  AppBarState copyWith({
    String? title,
    String? subtitle,
    List<Widget>? actions,
    bool? showBackButton,
    VoidCallback? onBackMetric,
  }) {
    return AppBarState(
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      actions: actions ?? this.actions,
      showBackButton: showBackButton ?? this.showBackButton,
      onBackMetric: onBackMetric ?? this.onBackMetric,
    );
  }
}

// 2. El Notifier (La lógica)
class AppBarNotifier extends StateNotifier<AppBarState> {
  AppBarNotifier() : super(const AppBarState());

  // Método para que las pantallas configuren el Header
  void setOptions({
    required String title,
    String? subtitle,
    List<Widget>? actions,
    bool showBackButton = true,
  }) {
    state = state.copyWith(
      title: title,
      subtitle: subtitle,
      actions: actions,
      showBackButton: showBackButton,
    );
  }

  // Método para resetear al estado original (Dashboard)
  void reset() {
    state = const AppBarState(
      title: 'Sistema de inventario',
      showBackButton: false,
      actions: [], // O tus acciones por defecto del dashboard (perfil, etc)
    );
  }
}

// 3. El Provider Global
final appBarProvider = StateNotifierProvider<AppBarNotifier, AppBarState>((
  ref,
) {
  return AppBarNotifier();
});
