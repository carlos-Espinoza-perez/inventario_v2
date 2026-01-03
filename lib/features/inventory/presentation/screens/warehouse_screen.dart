import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inventario_v2/features/dashboard/presentation/widgets/top_app_bar_dashboard.dart';
import 'package:inventario_v2/features/inventory/presentation/widgets/warehouse_item.dart'; // Asumo que usas go_router

class WarehouseScreen extends StatelessWidget {
  const WarehouseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Lista de bodegas",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              Material(
                color: Colors.blue,
                shape: const CircleBorder(),
                elevation: 4,
                shadowColor: Colors.blue.withValues(alpha: 0.4),
                child: InkWell(
                  onTap: () {
                    context.push('/warehouse-create');
                  },
                  customBorder: const CircleBorder(),
                  child: const Padding(
                    padding: EdgeInsets.all(10), // Tamaño del botón
                    child: Icon(Icons.add, color: Colors.white, size: 24),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Buscar por nombre...",
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor:
                    Colors.white, // O Colors.grey[100] si prefieres contraste
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // 3. LISTA DE BODEGAS
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(), // Efecto rebote iOS
              children: [
                WarehouseItem(
                  name: "Pueblo Nuevo",
                  onTap: () => _navegarABodega(context, "Pueblo Nuevo"),
                ),
                WarehouseItem(
                  name: "San Juan de Limay",
                  onTap: () => _navegarABodega(context, "San Juan de Limay"),
                ),
                WarehouseItem(
                  name: "Bodega Central Estelí",
                  onTap: () => _navegarABodega(context, "Estelí"),
                ),
                WarehouseItem(
                  name: "Sucursal Norte",
                  onTap: () => _navegarABodega(context, "Norte"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navegarABodega(BuildContext context, String nombre) {
    context.push('/warehouse-inventory');
  }
}
