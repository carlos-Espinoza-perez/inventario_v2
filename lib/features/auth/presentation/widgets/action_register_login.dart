import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ActionRegisterLogin extends StatelessWidget {
  const ActionRegisterLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "¿No tienes una cuenta?",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            TextButton(
              onPressed: () {
                context.push('/create-company');
              },
              child: Text(
                "Registrate",
                style: TextStyle(
                  color: Colors.teal,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
