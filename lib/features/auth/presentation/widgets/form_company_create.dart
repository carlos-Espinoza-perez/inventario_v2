import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inventario_v2/features/auth/presentation/providers/auth_provider.dart';
import 'package:inventario_v2/features/auth/presentation/widgets/headline_custom.dart';

class FormCompanyCreate extends ConsumerStatefulWidget {
  const FormCompanyCreate({super.key});

  @override
  ConsumerState<FormCompanyCreate> createState() => _FormCompanyCreateState();
}

class _FormCompanyCreateState extends ConsumerState<FormCompanyCreate> {
  final _formKey = GlobalKey<FormState>();

  final _nombreEmpresaCtr = TextEditingController();
  final _nombreComercialCtr = TextEditingController();
  final _rucCtr = TextEditingController();

  @override
  void dispose() {
    _nombreEmpresaCtr.dispose();
    _nombreComercialCtr.dispose();
    _rucCtr.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (_formKey.currentState!.validate()) {
      ref
          .read(authControllerProvider.notifier)
          .setEmpresaDraft(
            EmpresaDraft(
              nombre: _nombreEmpresaCtr.text.trim(),
              nombreComercial: _nombreComercialCtr.text.trim(),
              ruc: _rucCtr.text.trim(),
            ),
          );

      context.push('/create-user');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        HeadlineCustom(
          title: "Datos de empresa",
          subtitle: "Ingresa los datos de tu empresa",
          icon: Icons.business_outlined,
        ),
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Nombre de la empresa",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nombreEmpresaCtr,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  labelText: 'Ingrese el nombre de la empresa',
                  prefixIcon: const Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el nombre de la empresa';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 22),

              Text(
                "Nombre comercial",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nombreComercialCtr,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  labelText: 'Ingrese el nombre comercial',
                  prefixIcon: const Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el nombre comercial';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 22),

              Text(
                "RUC / Identificación fiscal",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _rucCtr,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  labelText: 'Ingrese el RUC',
                  prefixIcon: const Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el RUC';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 22),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _onSubmit();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(55),
                    ),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  icon: const Icon(Icons.business),
                  label: const Text('Crear empresa'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
