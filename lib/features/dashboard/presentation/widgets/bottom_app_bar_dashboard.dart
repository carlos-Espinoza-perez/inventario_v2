import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inventario_v2/features/auth/presentation/providers/authorization_provider.dart';
import 'package:inventario_v2/core/constants/permission_codes.dart';

class _MenuButton extends StatelessWidget {
  const _MenuButton({
    required this.icon,
    required this.text,
    required this.onTap,
  });

  final IconData icon;
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = Colors.black;
    return Material(
      borderRadius: const BorderRadius.all(Radius.circular(12)),
      color: Colors.transparent,
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 2.5,
            children: [
              Icon(icon, size: 24, color: color),
              Text(
                text,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BottomAppBarDashboard extends ConsumerWidget {
  const BottomAppBarDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authorizationStateProvider).value;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: BottomAppBar(
        height: 80,
        padding: EdgeInsets.zero,
        shape: const CircularNotchedRectangle(),
        child: Row(
          children: [
            const Spacer(),
            if (authState?.can(PermissionCode.warehouseRead) ?? false) ...[
              _MenuButton(
                icon: Icons.inventory_2_outlined,
                text: 'Inventario',
                onTap: () {
                  debugPrint("Inventario");
                  context.push('/warehouse');
                },
              ),
              const Spacer(),
            ],
            if (authState?.can(PermissionCode.saleRead) ?? false) ...[
              _MenuButton(
                icon: Icons.point_of_sale_outlined,
                text: 'Ventas',
                onTap: () {
                  context.push('/sales');
                },
              ),
              const Spacer(),
            ],
            const Spacer(),
            if (authState?.can(PermissionCode.reportRead) ?? false) ...[
              _MenuButton(
                icon: Icons.bar_chart_rounded,
                text: 'Reportes',
                onTap: () {
                  context.push('/reports');
                },
              ),
              const Spacer(),
            ],
            _MenuButton(
              icon: Icons.auto_awesome_rounded,
              text: 'IA',
              onTap: () => context.push('/assistant'),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
