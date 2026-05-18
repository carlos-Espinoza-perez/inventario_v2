import 'package:flutter/material.dart';
import '../../theme/app_borders.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_spacing.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final VoidCallback? onTap;
  final bool isOutlined;
  final Color? backgroundColor;

  const CustomCard({
    super.key,
    required this.child,
    this.padding = AppSpacing.paddingAll16,
    this.margin = const EdgeInsets.only(bottom: AppSpacing.s12),
    this.onTap,
    this.isOutlined = false,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? AppColors.surface;

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppBorders.r16,
        border: isOutlined ? Border.all(color: AppColors.border) : Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        boxShadow: isOutlined ? null : AppShadows.subtle,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppBorders.r16,
          onTap: onTap,
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}
