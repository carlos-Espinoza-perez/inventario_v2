import 'package:flutter/material.dart';

class AppShadows {
  AppShadows._();

  // --- Sombra Sutil (Tarjetas, botones, elementos en reposo) ---
  static final List<BoxShadow> subtle = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  // --- Sombra Media (Tarjetas destacadas o modales pequeños) ---
  static final List<BoxShadow> medium = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];

  // --- Sombra Fuerte (Modales, menús flotantes, bottom sheets) ---
  static final List<BoxShadow> elevated = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.12),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  // --- Sombra Invertida (Bottom navigation o barras inferiores) ---
  static final List<BoxShadow> bottomBar = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 10,
      offset: const Offset(0, -4),
    ),
  ];

  // --- Sombra de Color Primario (Para botones o elementos de acento) ---
  static List<BoxShadow> primaryAccent(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: 0.3),
      blurRadius: 10,
      offset: const Offset(0, 6),
    ),
  ];
}
