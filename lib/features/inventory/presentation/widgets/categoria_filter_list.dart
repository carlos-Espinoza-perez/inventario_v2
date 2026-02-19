import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventario_v2/core/global_provider.dart';
import 'package:inventario_v2/features/inventory/data/providers/categoria_provider.dart';

class CategoriaFilterList extends ConsumerWidget {
  const CategoriaFilterList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Escuchamos la lista de categorías (Data)
    final categoriasAsync = ref.watch(listCategoriasPadreProvider);

    // 2. Escuchamos cuál está seleccionado actualmente (Estado Global)
    final filtroSeleccionado = ref.watch(filtroCategoriaSeleccionadoProvider);

    return SizedBox(
      height: 42,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        children: [
          // --- CHIP: TODOS ---
          _FilterChip(
            label: "Todos",
            isSelected: filtroSeleccionado == null,
            onTap: () {
              ref.read(filtroCategoriaSeleccionadoProvider.notifier).state =
                  null;
            },
          ),

          // --- CHIP: BAJO STOCK ---
          _FilterChip(
            label: "Bajo Stock",
            isSelected:
                filtroSeleccionado ==
                kFiltroBajoStock, // Asegúrate de importar esta constante
            isAlert: true,
            onTap: () {
              ref.read(filtroCategoriaSeleccionadoProvider.notifier).state =
                  kFiltroBajoStock;
            },
          ),

          // --- CHIPS DINÁMICOS (Desde Isar) ---
          ...categoriasAsync.when(
            data: (categorias) {
              return categorias.map((categoria) {
                return _FilterChip(
                  label: categoria.nombre,
                  isSelected: filtroSeleccionado == categoria.serverId,
                  onTap: () {
                    ref
                            .read(filtroCategoriaSeleccionadoProvider.notifier)
                            .state =
                        categoria.serverId;
                  },
                );
              });
            },
            loading: () => [
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ],
            error: (_, __) => [const SizedBox.shrink()],
          ),
        ],
      ),
    );
  }
}

// --- TU COMPONENTE ACTUALIZADO ---
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isAlert;
  final VoidCallback onTap; // Necesario para comunicar el click al padre

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap, // Requerido
    this.isAlert = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        // Conectamos el evento del Chip nativo con nuestra lógica de Riverpod
        onSelected: (bool value) {
          onTap();
        },
        backgroundColor: Colors.white,
        selectedColor: isAlert ? Colors.red[100] : Colors.blue[100],
        checkmarkColor: isAlert ? Colors.red[800] : Colors.blue[800],
        labelStyle: TextStyle(
          color: isSelected
              ? (isAlert ? Colors.red[800] : Colors.blue[800])
              : Colors.grey[700],
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          fontSize: 13,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? Colors.transparent : Colors.grey.shade300,
          ),
        ),
        showCheckmark: false, // Opcional: ponlo en true si quieres ver el check
      ),
    );
  }
}
