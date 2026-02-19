import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:inventario_v2/core/presentation/widgets/custom_text_field.dart';
import 'package:inventario_v2/features/auth/presentation/providers/auth_provider.dart';
import 'package:inventario_v2/features/inventory/data/repository/movimiento_repository.dart';

// Importaciones de tus pantallas
import 'product_selection_screen.dart';
import 'product_detail_entry_screen.dart';

class WarehouseEntryScreen extends ConsumerStatefulWidget {
  final String bodegaId;
  const WarehouseEntryScreen({super.key, required this.bodegaId});

  @override
  ConsumerState<WarehouseEntryScreen> createState() =>
      _WarehouseEntryScreenState();
}

class _WarehouseEntryScreenState extends ConsumerState<WarehouseEntryScreen> {
  // Controladores
  final TextEditingController _descriptionCtrl = TextEditingController();

  // Lista de productos procesados
  final List<Map<String, dynamic>> _orderLines = [];

  // Estado de carga para el guardado
  bool _isLoading = false;

  // --- CÁLCULOS ---
  double get _totalInvestment => _orderLines.fold(0, (sum, item) {
    double cost = item['cost'];
    int qty = (item['items'] as List).length;
    return sum + (cost * qty);
  });

  int get _totalItemsCount => _orderLines.fold(0, (sum, item) {
    return sum + (item['items'] as List).length;
  });

  @override
  void dispose() {
    _descriptionCtrl.dispose();
    super.dispose();
  }

  // --- LÓGICA DE GUARDADO (CONECTADA A DB) ---
  Future<void> _saveEntireOrderToDB() async {
    // 1. Validaciones
    if (_descriptionCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "⚠️ Por favor ingresa una descripción o referencia para este movimiento.",
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // 2. Activar Loading
    setState(() => _isLoading = true);

    try {
      // 3. Obtener el repositorio desde Riverpod
      final repository = await ref.read(movimientoRepositoryProvider.future);
      final authController = ref.read(authControllerProvider.notifier);
      final usuario =
          authController.usuarioActual ?? await authController.getUser();

      await repository.guardarEntradaAlmacen(
        empresaId: usuario?.empresaId ?? "",
        usuarioId: usuario?.serverId ?? "",
        bodegaId: widget.bodegaId,
        descripcion: _descriptionCtrl.text.trim(),
        lineasOrden: _orderLines,
      );

      if (!mounted) return;

      // 5. Éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Entrada de inventario registrada con éxito"),
          backgroundColor: Colors.green,
        ),
      );

      // Regresar a la pantalla anterior (Dashboard o Lista)
      Navigator.pop(context);
    } catch (e) {
      // 6. Manejo de Errores
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Error al guardar: $e"),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      // 7. Desactivar Loading
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Barra inferior con botón de guardar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton.icon(
            // Deshabilitar si está vacío o cargando
            onPressed: (_orderLines.isEmpty || _isLoading)
                ? null
                : _saveEntireOrderToDB,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyan.shade900,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.save_alt_rounded),
            label: Text(
              _isLoading
                  ? " GUARDANDO..."
                  : "FINALIZAR ENTRADA (${NumberFormat.simpleCurrency().format(_totalInvestment)})",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
      ),

      // Cuerpo principal con Stack para el Loading Overlay
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. SECCIÓN CABECERA (SOLO DESCRIPCIÓN)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.description_outlined,
                            color: Colors.cyan.shade800,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "Información General",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: "Descripción / Referencia",
                        controller: _descriptionCtrl,
                        hint: "Ej. Compra semanal proveedor Nike - Factura 001",
                        icon: Icons.notes,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 2. TÍTULO Y BOTÓN AGREGAR
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text(
                          "Productos",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (_orderLines.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.cyan.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "$_totalItemsCount unds",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.cyan.shade900,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: _isLoading
                          ? null
                          : _selectProductAndStartScanning,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyan.shade800,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      icon: const Icon(Icons.add_circle_outline, size: 18),
                      label: const Text("Procesar Producto"),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // 3. LISTA DE RESUMEN O EMPTY STATE
                if (_orderLines.isEmpty)
                  _buildEmptyState()
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _orderLines.length,
                    itemBuilder: (context, index) => _buildOrderLineCard(index),
                  ),

                // Espacio extra para no tapar el último elemento con el botón flotante
                const SizedBox(height: 80),
              ],
            ),
          ),

          // LOADING OVERLAY (Bloquea la pantalla si está guardando)
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  // --- WIDGETS AUXILIARES ---

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade300,
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              size: 40,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Tu orden de entrada está vacía",
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Presiona 'Procesar Producto' para comenzar.",
            style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderLineCard(int index) {
    final line = _orderLines[index];
    final itemsList = line['items'] as List;
    final int qty = itemsList.length;
    final double cost = line['cost'];
    final double totalLine = cost * qty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                // Icono
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.cyan.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.checkroom,
                    color: Colors.cyan.shade800,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                // Datos
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        line['productName'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          "$qty Unidades Escaneadas",
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Total
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      NumberFormat.simpleCurrency().format(totalLine),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      "Costo: \$$cost",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1),
            ),

            // ACCIONES (EDITAR / BORRAR)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text("Editar Lote"),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.cyan.shade800,
                  ),
                  onPressed: _isLoading
                      ? null
                      : () => _editExistingProduct(index),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                    size: 22,
                  ),
                  onPressed: _isLoading
                      ? null
                      : () {
                          setState(() => _orderLines.removeAt(index));
                        },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- NAVEGACIÓN ---

  void _selectProductAndStartScanning() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductSelectionScreen(bodegaId: widget.bodegaId),
      ),
    );

    if (result != null && result is Map) {
      setState(() {
        _orderLines.add(result as Map<String, dynamic>);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "✅ Se agregaron ${(result['items'] as List).length} unidades",
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _editExistingProduct(int index) async {
    final line = _orderLines[index];

    // Convertimos la lista dinámica a List<Map<String, String>>
    final List<Map<String, String>> existingItems = (line['items'] as List)
        .map((item) => Map<String, String>.from(item))
        .toList();

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailEntryScreen(
          productId: line['productId'],
          categoriaId: line['categoriaId'],
          initialCost: line['cost'],
          initialPrice: line['price'],
          initialItems: existingItems,
        ),
      ),
    );

    // Si regresa con datos actualizados, reemplazamos en la lista
    if (result != null && result is Map) {
      setState(() {
        _orderLines[index] = result as Map<String, dynamic>;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("✅ Lote actualizado")));
    }
  }
}
