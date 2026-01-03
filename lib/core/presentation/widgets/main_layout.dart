import 'package:flutter/material.dart';
import 'package:inventario_v2/features/dashboard/presentation/widgets/bottom_app_bar_dashboard.dart';
import 'package:inventario_v2/features/dashboard/presentation/widgets/top_app_bar_dashboard.dart';

class MainLayout extends StatelessWidget {
  final Widget child;
  final String location;

  const MainLayout({super.key, required this.child, required this.location});

  @override
  Widget build(BuildContext context) {
    final bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: TopAppBarDashboard(location: location),

      body: SafeArea(child: child),

      bottomNavigationBar: isKeyboardOpen
          ? null
          : const BottomAppBarDashboard(),

      floatingActionButton: isKeyboardOpen
          ? null // Oculta el botón si hay teclado
          : FloatingActionButton(
              onPressed: () {},
              tooltip: 'Inventario IA',
              elevation: 0,
              shape: const CircleBorder(),
              backgroundColor: Colors.cyan,
              child: const Icon(
                Icons.auto_awesome_outlined,
                color: Colors.black87,
              ),
            ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
