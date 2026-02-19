import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final bool isReadOnly;
  final IconData? icon;
  final Function(String)?
  onChanged; // Agregado por si necesitas detectar cambios

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
      children: [
        // 1. La Etiqueta (Afuera y en negrita)
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),

        // 2. El Input (Caja redondeada limpia)
        Container(
          decoration: BoxDecoration(
            color: isReadOnly ? Colors.grey[100] : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            readOnly: isReadOnly,
            onChanged: onChanged,
            style: const TextStyle(fontSize: 15), // Texto un poco más legible
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400),
              border: InputBorder.none, // Quitamos la línea fea por defecto
              icon: icon != null ? Icon(icon, color: Colors.grey) : null,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}
