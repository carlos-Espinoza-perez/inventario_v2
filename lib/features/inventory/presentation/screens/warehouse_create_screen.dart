import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:inventario_v2/core/presentation/widgets/custom_button.dart';
import 'package:inventario_v2/features/auth/presentation/providers/auth_provider.dart';
import 'package:inventario_v2/features/inventory/data/providers/bodega_provider.dart';

class WarehouseCreateScreen extends ConsumerStatefulWidget {
  const WarehouseCreateScreen({super.key});

  @override
  ConsumerState<WarehouseCreateScreen> createState() =>
      _WarehouseCreateScreenState();
}

class _WarehouseCreateScreenState extends ConsumerState<WarehouseCreateScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Estado
  bool _esPuntoVenta = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _guardarBodega() async {
    // 1. Validar formulario visualmente
    if (!_formKey.currentState!.validate()) return;

    // 2. Ocultar teclado y mostrar carga
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      // 3. Obtener el servicio de Bodega (esperando a la DB)
      final bodegaService = await ref.read(bodegaServiceProvider.future);

      // 4. Obtener el AuthController para sacar los datos del usuario
      final authController = ref.read(authControllerProvider.notifier);

      // Intentamos obtener el usuario de la memoria, si no está, lo pedimos a la DB
      final usuario =
          authController.usuarioActual ?? await authController.getUser();

      // Validación de seguridad
      if (usuario == null) {
        throw Exception(
          "No se encontró la sesión del usuario. Por favor, inicia sesión nuevamente.",
        );
      }

      // 5. Llamar al servicio para crear la bodega y la relación
      await bodegaService.crearBodega(
        nombre: _nameController.text.trim(),
        direccion: _locationController.text.trim(),
        descripcion: _descriptionController.text.trim(),
        esPuntoVenta: _esPuntoVenta,
        usuarioIdActual: usuario.serverId.toString(),
        empresaId: usuario.empresaId,
      );

      if (mounted) {
        setState(() => _isLoading = false);
        context.pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 10),
                Text('Bodega creada exitosamente'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      // 7. Manejo de errores
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // TARJETA DE FORMULARIO
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _CustomTextField(
                      label: "Nombre de la bodega",
                      hint: "Ej: Bodega Central",
                      controller: _nameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'El nombre es obligatorio';
                        }
                        if (value.length < 3) {
                          return 'El nombre debe tener al menos 3 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    _CustomTextField(
                      label: "Ubicación (Opcional)",
                      hint: "Ej: Calle Principal, Local 2",
                      controller: _locationController,
                      icon: Icons.location_on_outlined,
                    ),
                    const SizedBox(height: 20),
                    _CustomTextField(
                      label: "Descripción / Notas (Opcional)",
                      hint: "Información adicional relevante...",
                      controller: _descriptionController,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20),
                    const Divider(height: 1, color: Color(0xFFEEEEEE)),

                    // SWITCH PUNTO DE VENTA
                    Padding(
                      padding: const EdgeInsets.only(top: 15.0, bottom: 5.0),
                      child: SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          "¿Es Punto de Venta?",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        subtitle: Text(
                          "Habilita funciones de caja y facturación para esta ubicación",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                        value: _esPuntoVenta,
                        activeColor: Colors.blue,
                        onChanged: (bool value) {
                          setState(() => _esPuntoVenta = value);
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // BOTÓN GUARDAR
              CustomButton(
                text: "Guardar bodega",
                icon: Icons.save_outlined,
                isLoading: _isLoading,
                isFullWidth: true,
                height: 55,
                color: Colors.blue,
                onPressed: _guardarBodega,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- WIDGET LOCAL DE TEXTFIELD (Reutilizable en este archivo) ---
class _CustomTextField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final int maxLines;
  final IconData? icon;
  final String? Function(String?)? validator;

  const _CustomTextField({
    required this.label,
    required this.hint,
    required this.controller,
    this.maxLines = 1,
    this.icon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          style: const TextStyle(fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            prefixIcon: icon != null
                ? Icon(icon, color: Colors.grey[400], size: 20)
                : null,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            filled: true,
            fillColor: Colors.grey[50], // Fondo ligeramente gris
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.blue, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red.shade200),
            ),
          ),
        ),
      ],
    );
  }
}
