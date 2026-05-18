import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color color;
  final bool isOutlined;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final double height;
  final double borderRadius;
  final Color? forceTextColor;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color = AppColors.primary,
    this.isOutlined = false,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.height = 48.0,
    this.borderRadius = 55.0, // pill
    this.forceTextColor,
  });

  @override
  Widget build(BuildContext context) {
    Color textColor;
    if (isOutlined) {
      textColor = color;
    } else {
      if (forceTextColor != null) {
        textColor = forceTextColor!;
      } else {
        textColor = color.computeLuminance() > 0.5 ? AppColors.textPrimary : AppColors.textInverse;
      }
    }

    final Color borderColor = color;
    final OutlinedBorder shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadius),
      side: isOutlined ? BorderSide(color: borderColor, width: 1.5) : BorderSide.none,
    );

    Widget content = isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(textColor),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20, color: textColor),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  text,
                  style: AppTypography.button.copyWith(color: textColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );

    Widget buttonWidget;

    if (isOutlined) {
      buttonWidget = OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          splashFactory: InkRipple.splashFactory,
          foregroundColor: color,
          side: BorderSide(color: borderColor, width: 1.5),
          shape: shape,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return color.withValues(alpha: 0.1);
            }
            return null;
          }),
        ),
        child: content,
      );
    } else {
      buttonWidget = ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ButtonStyle(
          splashFactory: InkRipple.splashFactory,
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return AppColors.border;
            }
            return color;
          }),
          foregroundColor: WidgetStateProperty.all(textColor),
          elevation: WidgetStateProperty.all(1),
          shape: WidgetStateProperty.all(shape),
          shadowColor: WidgetStateProperty.all(color.withValues(alpha: 0.3)),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
          ),
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return textColor.withValues(alpha: 0.2);
            }
            return null;
          }),
        ),
        child: content,
      );
    }

    if (isFullWidth) {
      return SizedBox(
        width: double.infinity,
        height: height,
        child: buttonWidget,
      );
    }

    return SizedBox(height: height, child: buttonWidget);
  }
}
