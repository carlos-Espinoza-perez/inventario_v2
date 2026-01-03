import 'package:flutter/material.dart';

class CardInfoDashboard extends StatelessWidget {
  final String title;
  final String amount;
  final IconData icon;
  final Color color;
  final bool isOutlined;
  final bool hideIcon;

  // Opcionales
  final String? buttonText;
  final VoidCallback? onButtonTap;

  const CardInfoDashboard({
    super.key,
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
    this.isOutlined = false,
    this.hideIcon = false,
    this.buttonText,
    this.onButtonTap,
  });

  @override
  Widget build(BuildContext context) {
    // Definición de colores
    final backgroundColor = isOutlined ? Colors.white : color;
    final borderColor = isOutlined
        ? color.withValues(alpha: 0.3)
        : Colors.transparent;

    final mainTextColor = isOutlined ? Colors.black87 : Colors.white;
    final subTextColor = isOutlined ? Colors.grey[600] : Colors.white70;
    final iconColor = isOutlined ? color : Colors.white;
    final buttonTextColor = isOutlined ? color : Colors.white;

    final iconBgColor = isOutlined
        ? color.withValues(alpha: 0.1)
        : Colors.white.withValues(alpha: 0.2);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (isOutlined)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          else
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
        ],
      ),
      child: Material(
        color: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: isOutlined
              ? BorderSide(color: borderColor, width: 1.5)
              : BorderSide.none,
        ),

        clipBehavior: Clip.antiAlias,

        child: InkWell(
          onTap: onButtonTap,
          borderRadius: BorderRadius.circular(16),

          splashColor: isOutlined
              ? color.withValues(alpha: 0.1)
              : Colors.white.withValues(alpha: 0.2),
          highlightColor: isOutlined
              ? color.withValues(alpha: 0.05)
              : Colors.white.withValues(alpha: 0.1),

          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Column(
              // 🔥 ESTA LÍNEA ES LA CLAVE: Hace que la columna se encoja al contenido
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (!hideIcon)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: iconBgColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, color: iconColor, size: 18),
                      ),

                    if (!hideIcon) const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          color: subTextColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Text(
                  amount,
                  style: TextStyle(
                    color: mainTextColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),

                if (buttonText != null && onButtonTap != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        buttonText!,
                        style: TextStyle(
                          color: buttonTextColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 12,
                        color: buttonTextColor.withValues(alpha: 0.7),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
