import 'package:flutter/material.dart';
import '../../theme/app_borders.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

class CustomStatusBadge extends StatelessWidget {
  final String status;
  final Color? fontColor;
  final Color? backgroundColor;

  const CustomStatusBadge({
    super.key,
    required this.status,
    this.fontColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    Color statusBg;

    if (fontColor != null && backgroundColor != null) {
      statusColor = fontColor!;
      statusBg = backgroundColor!;
    } else {
      final s = status.trim().toLowerCase();
      if (s == 'pagado' || s == 'activo' || s == 'completado' || s == 'éxito') {
        statusColor = AppColors.successDark;
        statusBg = AppColors.successLight;
      } else if (s == 'pendiente' || s == 'en proceso' || s == 'espera') {
        statusColor = AppColors.warningDark;
        statusBg = AppColors.warningLight;
      } else if (s == 'anulado' || s == 'cancelado' || s == 'inactivo' || s == 'error') {
        statusColor = AppColors.errorDark;
        statusBg = AppColors.errorLight;
      } else {
        statusColor = AppColors.infoDark;
        statusBg = AppColors.infoLight;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s12,
        vertical: AppSpacing.s4,
      ),
      decoration: BoxDecoration(
        color: statusBg,
        borderRadius: AppBorders.r8,
      ),
      child: Text(
        status,
        style: AppTypography.labelSmall.copyWith(color: statusColor),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
