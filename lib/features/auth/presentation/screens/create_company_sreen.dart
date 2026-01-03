import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventario_v2/features/auth/presentation/widgets/all_reserved_login.dart';
import 'package:inventario_v2/features/auth/presentation/widgets/form_company_create.dart';

class CreateCompanyScreen extends ConsumerWidget {
  const CreateCompanyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      bottomNavigationBar: AllReservedLogin(),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    offset: const Offset(0, 20),
                    blurRadius: 25,
                    spreadRadius: -5,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    offset: const Offset(0, 8),
                    blurRadius: 10,
                    spreadRadius: -6,
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(children: [FormCompanyCreate()]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
