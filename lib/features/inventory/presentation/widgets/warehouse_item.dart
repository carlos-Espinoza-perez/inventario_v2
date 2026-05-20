import 'package:flutter/material.dart';

class WarehouseItem extends StatelessWidget {
  final String name;
  final VoidCallback onTap;
  final VoidCallback? onManageUsers;

  const WarehouseItem({
    super.key,
    required this.name,
    required this.onTap,
    this.onManageUsers,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        // Mismo estilo de sombra que el Dashboard
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias, // Para que el ripple no se salga
        child: InkWell(
          onTap: onTap,
          // Usamos el efecto de ola suave que configuramos antes
          splashColor: Colors.blue.withValues(alpha: 0.1),
          highlightColor: Colors.blue.withValues(alpha: 0.05),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                // Icono con fondo azul suave (Consistente con el Dashboard)
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warehouse_rounded, // Icono de bodega
                    color: Colors.blue,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),

                // Nombre de la bodega
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),

                // Acción de la derecha
                if (onManageUsers == null)
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: Colors.grey[400],
                  )
                else
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert_rounded,
                      color: Colors.grey[600],
                    ),
                    onSelected: (value) {
                      if (value == 'inventory') {
                        onTap();
                      } else if (value == 'users') {
                        onManageUsers!();
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'inventory',
                        child: Row(
                          children: [
                            Icon(Icons.inventory_2_outlined, size: 18),
                            SizedBox(width: 8),
                            Text('Ver inventario'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'users',
                        child: Row(
                          children: [
                            Icon(Icons.groups_2_outlined, size: 18),
                            SizedBox(width: 8),
                            Text('Gestionar usuarios'),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
