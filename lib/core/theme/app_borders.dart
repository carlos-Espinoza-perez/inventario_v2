import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppBorders {
  AppBorders._();

  // --- Radios Base (Double) ---
  static const double s8 = 8.0;
  static const double s12 = 12.0;
  static const double s16 = 16.0;
  static const double s20 = 20.0;
  static const double s32 = 32.0;
  static const double s55 = 55.0;

  // --- BorderRadius Completo ---
  static const BorderRadius r8 = BorderRadius.all(Radius.circular(s8));
  static const BorderRadius r12 = BorderRadius.all(Radius.circular(s12));
  static const BorderRadius r16 = BorderRadius.all(Radius.circular(s16));
  static const BorderRadius r20 = BorderRadius.all(Radius.circular(s20));
  static const BorderRadius r32 = BorderRadius.all(Radius.circular(s32));
  static const BorderRadius pill = BorderRadius.all(Radius.circular(s55));

  // --- BorderRadius Parciales ---
  static const BorderRadius top20 = BorderRadius.vertical(top: Radius.circular(s20));
  static const BorderRadius bottom20 = BorderRadius.vertical(bottom: Radius.circular(s20));

  // --- BorderSide (Líneas) ---
  static const BorderSide defaultSide = BorderSide(color: AppColors.border, width: 1.0);
  static const BorderSide lightSide = BorderSide(color: AppColors.borderLight, width: 1.0);
  static const BorderSide none = BorderSide.none;

  // --- Shapes ---
  static const RoundedRectangleBorder cardShape = RoundedRectangleBorder(borderRadius: r16);
  static const RoundedRectangleBorder modalShape = RoundedRectangleBorder(borderRadius: top20);
  static const RoundedRectangleBorder buttonShape = RoundedRectangleBorder(borderRadius: pill);
}
