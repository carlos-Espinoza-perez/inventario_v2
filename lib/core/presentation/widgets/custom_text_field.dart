import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final bool isReadOnly;
  final IconData? icon;
  final Function(String)? onChanged;

  const CustomTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint = "",
    this.keyboardType = TextInputType.text,
    this.isReadOnly = false,
    this.icon,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AppTypography.labelLarge.copyWith(color: AppColors.textPrimary),
        ),
        AppSpacing.gap8,
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          readOnly: isReadOnly,
          onChanged: onChanged,
          style: AppTypography.bodyLarge,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon != null ? Icon(icon, color: AppColors.textMuted, size: 20) : null,
            fillColor: isReadOnly ? AppColors.borderLight : AppColors.surfaceVariant,
          ),
        ),
      ],
    );
  }
}
