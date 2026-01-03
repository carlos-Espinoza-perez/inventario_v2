import 'package:flutter/material.dart';
import 'package:inventario_v2/features/auth/presentation/widgets/all_reserved_login.dart';
import 'package:inventario_v2/features/auth/presentation/widgets/form_user_create.dart';

class CreateUserScreen extends StatelessWidget {
  const CreateUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                child: Column(children: [FormUserCreate()]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
