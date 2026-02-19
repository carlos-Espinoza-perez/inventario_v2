import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inventario_v2/features/auth/data/collections/bodega_collection.dart';
import 'package:inventario_v2/features/inventory/data/providers/bodega_provider.dart';
import 'package:inventario_v2/features/inventory/presentation/widgets/warehouse_item.dart';

class WarehouseScreen extends ConsumerWidget {
  const WarehouseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Escuchamos la lista de bodegas
    final bodegasAsync = ref.watch(bodegaListProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          // HEADER (Igual a tu diseño)
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
                    // Navegar a crear (Implementaremos esto luego)
                    context.push('/warehouse-create');
                  },
                  customBorder: const CircleBorder(),
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(Icons.add, color: Colors.white, size: 24),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // BUSCADOR CONECTADO
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
              onChanged: (value) {
                // ACTUALIZAMOS EL PROVIDER DE BÚSQUEDA
                ref.read(bodegaSearchQueryProvider.notifier).state = value;
              },
              decoration: InputDecoration(
                hintText: "Buscar por nombre...",
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // LISTA REACTIVA (AsyncValue)
          Expanded(
            child: bodegasAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (bodegas) {
                if (bodegas.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.warehouse_outlined,
                          size: 60,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "No hay bodegas encontradas",
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: bodegas.length,
                  itemBuilder: (context, index) {
                    final bodega = bodegas[index];
                    return WarehouseItem(
                      name: bodega.nombre,
                      onTap: () => _navegarABodega(context, bodega),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _navegarABodega(BuildContext context, BodegaCollection bodega) {
    // Pasamos el ID real de la bodega o el objeto entero
    // Asegúrate de que tu ruta '/warehouse-inventory' acepte un parámetro 'id'
    context.push('/warehouse-inventory', extra: bodega);
    // O: context.push('/warehouse-inventory/${bodega.id}');
  }
}
