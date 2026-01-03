import 'package:flutter/material.dart';

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

  // Atributo opcional por si quieres forzar un color de texto específico
  final Color? forceTextColor;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color = Colors.cyan,
    this.isOutlined = false,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.height = 44.0,
    this.borderRadius = 32.0,
    this.forceTextColor,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Lógica de Contraste Inteligente
    Color textColor;
    if (isOutlined) {
      textColor = color;
    } else {
      if (forceTextColor != null) {
        textColor = forceTextColor!;
      } else {
        textColor = color.computeLuminance() > 0.5
            ? Colors.black87
            : Colors.white;
      }
    }

    // 2. Colores finales
    final Color borderColor = color;

    // 3. Definir la forma
    final OutlinedBorder shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadius),
      side: isOutlined
          ? BorderSide(color: borderColor, width: 1.5)
          : BorderSide.none,
    );

    // 4. Contenido
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
                  style: TextStyle(
                    color: textColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );

    // 5. Construcción del botón
    Widget buttonWidget;

    if (isOutlined) {
      buttonWidget = OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style:
            OutlinedButton.styleFrom(
              // En .styleFrom se pasa directo (Correcto)
              splashFactory: InkRipple.splashFactory,
              foregroundColor: color,
              side: BorderSide(color: borderColor, width: 1.5),
              shape: shape,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            ).copyWith(
              overlayColor: MaterialStateProperty.resolveWith((states) {
                if (states.contains(MaterialState.pressed)) {
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
          // --- CORRECCIÓN AQUÍ ---
          // splashFactory NO lleva MaterialStateProperty.all()
          splashFactory: InkRipple.splashFactory,
          // -----------------------

          // Fondo forzado
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.disabled)) {
              return Colors.grey.shade300;
            }
            return color;
          }),

          foregroundColor: MaterialStateProperty.all(textColor),
          elevation: MaterialStateProperty.all(2),
          shape: MaterialStateProperty.all(shape),
          shadowColor: MaterialStateProperty.all(color.withValues(alpha: 0.4)),
          padding: MaterialStateProperty.all(
            const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          ),

          // Configuración de la ola
          overlayColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.pressed)) {
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
