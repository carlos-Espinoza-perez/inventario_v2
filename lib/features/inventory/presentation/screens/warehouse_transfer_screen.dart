import 'package:flutter/material.dart';
import 'package:inventario_v2/core/presentation/widgets/custom_text_field.dart';

// Importamos tus widgets y pantallas existentes
import 'product_selection_screen.dart';
import 'barcode_capture_screen.dart';

class WarehouseTransferScreen extends StatefulWidget {
  const WarehouseTransferScreen({super.key});

  @override
  State<WarehouseTransferScreen> createState() =>
      _WarehouseTransferScreenState();
}

class _WarehouseTransferScreenState extends State<WarehouseTransferScreen> {
  // Controladores
  String? _selectedDestinationWarehouse;
  final TextEditingController _transferCostCtrl = TextEditingController(
    text: "0",
  );

  // Lista de items a trasladar
  // Estructura: { 'id': '...', 'name': '...', 'qr': '...', 'size': '...', 'cost': 50.0 }
  final List<Map<String, dynamic>> _transferItems = [];

  // Bodegas simuladas (Esto vendría de tu DB Isar)
  final List<String> _warehouses = [
    "Bodega Central",
    "Sucursal Norte",
    "Sucursal Sur",
    "Tienda Centro",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Nuevo Traslado",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),

      // BOTÓN FINALIZAR TRASLADO
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
            onPressed:
                _transferItems.isEmpty || _selectedDestinationWarehouse == null
                ? null
                : _finalizeTransfer,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  Colors.orange.shade800, // Color distintivo para traslados
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            icon: const Icon(Icons.local_shipping),
            label: Text(
              "CONFIRMAR TRASLADO (${_transferItems.length})",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. CONFIGURACIÓN DE DESTINO Y COSTO
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .04),
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
                        Icons.storefront,
                        color: Colors.orange.shade800,
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Datos de Destino",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Selector de Bodega
                  DropdownButtonFormField<String>(
                    initialValue: _selectedDestinationWarehouse,
                    decoration: InputDecoration(
                      labelText: "Bodega de Destino",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    items: _warehouses
                        .map((w) => DropdownMenuItem(value: w, child: Text(w)))
                        .toList(),
                    onChanged: (val) =>
                        setState(() => _selectedDestinationWarehouse = val),
                  ),

                  const SizedBox(height: 16),

                  // Input de Costo %
                  CustomTextField(
                    label: "% Costo Operativo (Flete/Manejo)",
                    controller: _transferCostCtrl,
                    hint: "0",
                    keyboardType: TextInputType.number,
                    icon: Icons.price_change,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 2. TÍTULO Y BOTONES DE ACCIÓN (SCAN / BUSCAR)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Productos a Enviar",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Row(
                  children: [
                    // Botón Scan Rápido
                    IconButton.filled(
                      onPressed: _scanSingleProduct,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black87,
                      ),
                      icon: const Icon(
                        Icons.qr_code_scanner,
                        color: Colors.white,
                      ),
                      tooltip: "Escanear QR Individual",
                    ),
                    const SizedBox(width: 8),
                    // Botón Buscar Manual
                    IconButton.filled(
                      onPressed: _selectProductFromList,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.orange.shade800,
                      ),
                      icon: const Icon(Icons.search, color: Colors.white),
                      tooltip: "Buscar por Nombre",
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // 3. LISTA DE ITEMS SELECCIONADOS
            if (_transferItems.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 50,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey.shade300,
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 40,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "No hay items para trasladar",
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Usa los botones de arriba para agregar",
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _transferItems.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  // Mostrar el último arriba
                  final reverseIndex = (_transferItems.length - 1) - index;
                  final item = _transferItems[reverseIndex];

                  return _buildTransferItemCard(item, reverseIndex);
                },
              ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  // --- WIDGET TARJETA DE ITEM ---
  Widget _buildTransferItemCard(Map<String, dynamic> item, int index) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: Colors.orange.shade50,
          child: Text(
            item['size'],
            style: TextStyle(
              color: Colors.orange.shade900,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          item['name'],
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text("QR: ${item['qr']}", style: const TextStyle(fontSize: 12)),
            Text(
              "Costo Base: \$${item['cost']}",
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.close, color: Colors.redAccent, size: 20),
          onPressed: () => setState(() => _transferItems.removeAt(index)),
        ),
      ),
    );
  }

  // --- LÓGICA DE NEGOCIO ---

  // 1. Escaneo Rápido (Uno por uno)
  void _scanSingleProduct() async {
    // Abrimos tu escáner existente
    final scannedCode = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BarcodeCaptureScreen()),
    );

    if (scannedCode != null && scannedCode is String) {
      // AQUÍ DEBERÍAS BUSCAR EN TU BASE DE DATOS EL PRODUCTO REAL
      // Simulamos que encontramos el producto en Bodega
      _addProductToTransferList(
        name: "Producto Escaneado $scannedCode",
        qr: scannedCode,
        size: "M", // Esto vendría de la DB
        cost: 45.00, // Esto vendría de la DB
      );
    }
  }

  // 2. Selección Manual (Desde tu lista visual)
  void _selectProductFromList() async {
    // Reutilizamos tu pantalla de selección
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProductSelectionScreen(bodegaId: ''),
      ),
    );

    // NOTA: Tu ProductSelectionScreen devuelve un objeto complejo para entrada masiva.
    // Para traslado, quizás solo quieras seleccionar "Qué producto es" y luego elegir cuales mover.
    // Por simplicidad, aquí asumimos que seleccionas 1 y simulas mover 1 unidad.

    if (result != null && result is Map) {
      // Simulación: Agregamos 1 unidad del producto seleccionado
      _addProductToTransferList(
        name:
            result['name'] ??
            "Producto Seleccionado", // Ajusta según lo que devuelva tu pantalla
        qr: "MANUAL-SELECT",
        size: "U",
        cost: 0.0,
      );
    }
  }

  void _addProductToTransferList({
    required String name,
    required String qr,
    required String size,
    required double cost,
  }) {
    setState(() {
      _transferItems.add({'name': name, 'qr': qr, 'size': size, 'cost': cost});
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Item agregado al traslado"),
        duration: Duration(milliseconds: 600),
      ),
    );
  }

  void _finalizeTransfer() {
    // Validaciones finales
    if (_selectedDestinationWarehouse == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecciona una bodega destino")),
      );
      return;
    }

    // Aquí iría la lógica de guardar en Isar:
    // 1. Crear registro de Movimiento (Salida de Bodega Actual -> Entrada a Destino)
    // 2. Actualizar stock en ambas bodegas
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Traslado realizado con éxito")),
    );
  }
}
