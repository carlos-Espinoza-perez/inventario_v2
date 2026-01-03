import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Asegúrate de importar tu CustomButton que arreglamos antes
import 'package:inventario_v2/core/presentation/widgets/custom_button.dart';

class WarehouseCreateScreen extends ConsumerStatefulWidget {
  const WarehouseCreateScreen({super.key});

  @override
  ConsumerState<WarehouseCreateScreen> createState() =>
      _WarehouseCreateScreenState();
}

class _WarehouseCreateScreenState extends ConsumerState<WarehouseCreateScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para capturar el texto
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Variable de estado para el Switch
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
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    await Future.delayed(const Duration(seconds: 1));

    // Aquí iría tu lógica real:
    // final nuevaBodega = Bodega(
    //    nombre: _nameController.text,
    //    esPuntoVenta: _esPuntoVenta,
    //    ...
    // );
    // await ref.read(inventoryRepositoryProvider).crearBodega(nuevaBodega);

    if (mounted) {
      setState(() => _isLoading = false);
      context.pop(); // Regresamos a la lista

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bodega creada exitosamente')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Usamos el mismo gris de fondo que tu Dashboard
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Tarjeta contenedora del formulario (Estilo limpio)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
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
                  // Separador sutil
                  const Divider(height: 1, color: Color(0xFFEEEEEE)),

                  // Switch para Punto de Venta
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
                        "Habilita funciones de caja y facturación",
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                      value: _esPuntoVenta,
                      onChanged: (bool value) {
                        setState(() {
                          _esPuntoVenta = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // Botón reutilizando tu componente CustomButton
            CustomButton(
              text: "Guardar bodega",
              icon: Icons.add_home_work_rounded,
              isLoading: _isLoading,
              isFullWidth: true,
              height: 50,
              color: Colors.blue,
              onPressed: _guardarBodega,
            ),
          ],
        ),
      ),
    );
  }
}

// El _CustomTextField se mantiene igual
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
            fillColor: Colors.grey[50],
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
