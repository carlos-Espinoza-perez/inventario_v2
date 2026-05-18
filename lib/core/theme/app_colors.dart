import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // --- Colores de Marca (Brand) ---
  static const Color primary = Colors.teal;
  static const Color primaryDark = Color(0xFF00695C); // teal.shade800
  static const Color primaryLight = Color(0xFFB2DFDB); // teal.shade100
  static const Color accent = Colors.cyan;
  static const Color accentDark = Color(0xFF00838F); // cyan.shade800

  // --- Colores Neutros (Superficies y Fondos) ---
  static const Color background = Color(0xFFF9FAFB); // grey[50] aprox
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF3F4F6); // grey[100] aprox
  static const Color border = Color(0xFFE5E7EB); // grey[300] aprox
  static const Color borderLight = Color(0xFFF3F4F6); // grey[100]

  // --- Colores de Texto ---
  static const Color textPrimary = Color(0xFF111827); // black87
  static const Color textSecondary = Color(0xFF4B5563); // grey[600]
  static const Color textMuted = Color(0xFF9CA3AF); // grey[400]
  static const Color textInverse = Colors.white;

  // --- Colores Semánticos / Estados ---
  // Éxito / Pagado
  static const Color success = Color(0xFF10B981);
  static const Color successDark = Color(0xFF047857); // green.shade700
  static const Color successLight = Color(0xFFECFDF5); // green.shade50

  // Advertencia / Pendiente
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningDark = Color(0xFFC2410C); // orange.shade800
  static const Color warningLight = Color(0xFFFFF7ED); // orange.shade50

  // Peligro / Error / Anulado
  static const Color error = Color(0xFFEF4444);
  static const Color errorDark = Color(0xFFB91C1C); // red.shade700
  static const Color errorLight = Color(0xFFFEF2F2); // red.shade50

  // Información / Destacado
  static const Color info = Color(0xFF3B82F6);
  static const Color infoDark = Color(0xFF1D4ED8); // blue.shade700
  static const Color infoLight = Color(0xFFEFF6FF); // blue.shade50
}
