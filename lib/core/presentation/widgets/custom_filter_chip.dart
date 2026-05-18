import 'package:flutter/material.dart';
import '../../theme/app_borders.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

class CustomFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? activeColor;

  const CustomFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = activeColor ?? AppColors.primary;
    final bgColor = isSelected ? color.withValues(alpha: 0.1) : AppColors.surface;
    final borderColor = isSelected ? color : AppColors.border;
    final textColor = isSelected ? color : AppColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.s8),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppBorders.r20,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s16,
            vertical: AppSpacing.s8,
          ),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: AppBorders.r20,
            border: Border.all(color: borderColor),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: textColor,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
