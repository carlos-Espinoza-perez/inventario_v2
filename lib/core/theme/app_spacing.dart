import 'package:flutter/material.dart';

class AppSpacing {
  AppSpacing._();

  // --- Valores Base (Tokens) ---
  static const double s2 = 2.0;
  static const double s4 = 4.0;
  static const double s8 = 8.0;
  static const double s12 = 12.0;
  static const double s16 = 16.0;
  static const double s20 = 20.0;
  static const double s24 = 24.0;
  static const double s32 = 32.0;
  static const double s40 = 40.0;
  static const double s48 = 48.0;
  static const double s64 = 64.0;

  // --- Espaciadores Verticales (Gaps) ---
  static const SizedBox gap4 = SizedBox(height: s4);
  static const SizedBox gap8 = SizedBox(height: s8);
  static const SizedBox gap12 = SizedBox(height: s12);
  static const SizedBox gap16 = SizedBox(height: s16);
  static const SizedBox gap20 = SizedBox(height: s20);
  static const SizedBox gap24 = SizedBox(height: s24);
  static const SizedBox gap32 = SizedBox(height: s32);
  static const SizedBox gap48 = SizedBox(height: s48);

  // --- Espaciadores Horizontales (Gaps Width) ---
  static const SizedBox gapW4 = SizedBox(width: s4);
  static const SizedBox gapW8 = SizedBox(width: s8);
  static const SizedBox gapW12 = SizedBox(width: s12);
  static const SizedBox gapW16 = SizedBox(width: s16);
  static const SizedBox gapW20 = SizedBox(width: s20);
  static const SizedBox gapW24 = SizedBox(width: s24);
  static const SizedBox gapW32 = SizedBox(width: s32);

  // --- Paddings Estandarizados (EdgeInsets) ---
  static const EdgeInsets paddingZero = EdgeInsets.zero;

  // All
  static const EdgeInsets paddingAll4 = EdgeInsets.all(s4);
  static const EdgeInsets paddingAll8 = EdgeInsets.all(s8);
  static const EdgeInsets paddingAll12 = EdgeInsets.all(s12);
  static const EdgeInsets paddingAll16 = EdgeInsets.all(s16);
  static const EdgeInsets paddingAll20 = EdgeInsets.all(s20);
  static const EdgeInsets paddingAll24 = EdgeInsets.all(s24);

  // Horizontal / Vertical
  static const EdgeInsets paddingH8 = EdgeInsets.symmetric(horizontal: s8);
  static const EdgeInsets paddingH12 = EdgeInsets.symmetric(horizontal: s12);
  static const EdgeInsets paddingH16 = EdgeInsets.symmetric(horizontal: s16);
  static const EdgeInsets paddingH20 = EdgeInsets.symmetric(horizontal: s20);
  static const EdgeInsets paddingH24 = EdgeInsets.symmetric(horizontal: s24);

  static const EdgeInsets paddingV8 = EdgeInsets.symmetric(vertical: s8);
  static const EdgeInsets paddingV12 = EdgeInsets.symmetric(vertical: s12);
  static const EdgeInsets paddingV16 = EdgeInsets.symmetric(vertical: s16);
  static const EdgeInsets paddingV20 = EdgeInsets.symmetric(vertical: s20);
  static const EdgeInsets paddingV24 = EdgeInsets.symmetric(vertical: s24);

  // Combinados comunes
  static const EdgeInsets paddingH16V8 = EdgeInsets.symmetric(horizontal: s16, vertical: s8);
  static const EdgeInsets paddingH16V12 = EdgeInsets.symmetric(horizontal: s16, vertical: s12);
  static const EdgeInsets paddingH20V12 = EdgeInsets.symmetric(horizontal: s20, vertical: s12);
}
