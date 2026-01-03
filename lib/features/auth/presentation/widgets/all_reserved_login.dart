import 'package:flutter/material.dart';

class AllReservedLogin extends StatelessWidget {
  AllReservedLogin({super.key});

  final year = DateTime.now().year;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: Center(
        child: Text(
          "© $year App de inventario. Todos los derechos reservados.",
        ),
      ),
    );
  }
}
