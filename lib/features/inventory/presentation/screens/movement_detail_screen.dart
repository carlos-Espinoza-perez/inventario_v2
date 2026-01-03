import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:inventario_v2/core/database/app_bar_provider.dart';

class MovementDetailScreen extends ConsumerStatefulWidget {
  final String movementId;
  // En la vida real, con el ID buscas en la DB.
  // Aquí pasamos el tipo simulado para ver el ejemplo visual.
  final String type; // 'COMPRA', 'VENTA', 'TRASLADO'

  const MovementDetailScreen({
    super.key,
    required this.movementId,
    this.type = 'TRASLADO', // Cambia esto para probar las vistas
  });

  @override
  ConsumerState<MovementDetailScreen> createState() =>
      _MovementDetailScreenState();
}

class _MovementDetailScreenState extends ConsumerState<MovementDetailScreen> {
  // --- DATOS SIMULADOS (MOCK) ---
  // Dependiendo del tipo, el backend te devolvería datos distintos
  final Map<String, dynamic> _movementData = {
    "fecha": DateTime.now(),
    "estado": "APROBADO",
    "usuario": "Admin",

    // Solo para VENTAS
    "cliente": "Maria Gonzalez",
    "metodo_pago": "Efectivo",

    // Solo para COMPRAS
    "proveedor": "Importaciones S.A.",
    "referencia_externa": "Factura F-9921",

    // Solo para TRASLADOS
    "origen": "Bodega Central",
    "destino": "Sucursal Norte",
    "costo_flete": 500.00, // Costo de envío
    "costo_productos": 4500.00, // Valor de la mercadería
    // PRODUCTOS (Lista larga simulada)
    "items": List.generate(
      15,
      (index) => {
        "nombre": index % 2 == 0 ? "Camisa Manga Larga" : "Pantalón Jingo",
        "sku": "SKU-10${index}2",
        "cantidad": (index + 1) * 2,
        "precio_unitario": 250.00,
        "subtotal": ((index + 1) * 2) * 250.00,
      },
    ),
  };

  @override
  void initState() {
    super.initState();
    // Configurar Header
    Future.microtask(() {
      String title = "Detalle de Movimiento";
      if (widget.type == 'COMPRA') title = "Entrada de Mercadería";
      if (widget.type == 'VENTA') title = "Detalle de Venta";
      if (widget.type == 'TRASLADO') title = "Traslado entre Bodegas";

      ref
          .read(appBarProvider.notifier)
          .setOptions(
            title: title,
            subtitle: "#${widget.movementId}",
            showBackButton: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.share_outlined, color: Colors.black),
                onPressed: () {}, // Compartir PDF/Comprobante
              ),
              IconButton(
                icon: const Icon(Icons.print_outlined, color: Colors.black),
                onPressed: () {}, // Imprimir
              ),
            ],
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: "C\$ ", decimalDigits: 2);
    final themeColor = _getColorByType(widget.type);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. HEADER DE ESTADO Y MONTO
            _buildStatusHeader(currency, themeColor),

            const SizedBox(height: 16),

            // 2. CONTEXTO (Varía según si es Venta, Compra o Traslado)
            if (widget.type == 'TRASLADO')
              _buildTransferRouteCard(themeColor)
            else if (widget.type == 'VENTA')
              _buildClientInfoCard(themeColor)
            else
              _buildSupplierInfoCard(themeColor),

            const SizedBox(height: 16),

            // 3. LOGÍSTICA DE COSTOS (Solo para Traslados)
            if (widget.type == 'TRASLADO') ...[
              _buildLogisticsCostCard(currency),
              const SizedBox(height: 16),
            ],

            // 4. LISTA DE PRODUCTOS
            const Text(
              "Productos",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            _buildProductList(currency),

            // Espacio final para que no pegue abajo
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // --- SECCION 1: HEADER DE ESTADO ---
  Widget _buildStatusHeader(NumberFormat currency, Color color) {
    double total = 0;
    if (widget.type == 'TRASLADO') {
      total = _movementData['costo_productos'] + _movementData['costo_flete'];
    } else {
      // Suma simple de items
      total = (_movementData['items'] as List).fold(
        0,
        (sum, item) => sum + item['subtotal'],
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _movementData['estado'],
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              Text(
                DateFormat(
                  'dd MMM yyyy, hh:mm a',
                ).format(_movementData['fecha']),
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            widget.type == 'TRASLADO'
                ? "Valor Total Transferido"
                : "Monto Total",
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
          Text(
            currency.format(total),
            style: TextStyle(
              color: Colors.black87,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  // --- SECCION 2: TARJETAS DE CONTEXTO ---

  // A. Para Traslados: Ruta Origen -> Destino
  Widget _buildTransferRouteCard(Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "ORIGEN",
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.warehouse_rounded,
                      size: 18,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _movementData['origen'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_rounded, color: color),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "DESTINO",
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      _movementData['destino'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 6),
                    Icon(Icons.store_rounded, size: 18, color: color),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // B. Para Ventas: Cliente
  Widget _buildClientInfoCard(Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.orange.shade50,
            child: const Icon(Icons.person, color: Colors.orange),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Cliente",
                style: TextStyle(fontSize: 10, color: Colors.grey[500]),
              ),
              Text(
                _movementData['cliente'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.payments_outlined,
                  size: 16,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  _movementData['metodo_pago'],
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // C. Para Compras: Proveedor
  Widget _buildSupplierInfoCard(Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.local_shipping_outlined,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Proveedor",
                    style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                  ),
                  Text(
                    _movementData['proveedor'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              const Icon(Icons.receipt_long, size: 16, color: Colors.grey),
              const SizedBox(width: 6),
              const Text("Referencia:", style: TextStyle(color: Colors.grey)),
              const SizedBox(width: 6),
              Text(
                _movementData['referencia_externa'],
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- SECCION 3: LOGÍSTICA (Costo de envío) ---
  Widget _buildLogisticsCostCard(NumberFormat currency) {
    final costoProd = _movementData['costo_productos'];
    final costoFlete = _movementData['costo_flete'];
    final total = costoProd + costoFlete;

    // Calculamos cuánto aumentó el costo porcentualmente
    final incremento = (costoFlete / costoProd) * 100;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.local_shipping, size: 18, color: Colors.blue),
              SizedBox(width: 8),
              Text(
                "Costos Logísticos & Flete",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildCostRow("Valor Mercadería", currency.format(costoProd)),
          const SizedBox(height: 4),
          _buildCostRow(
            "Costo de Envío (+)",
            currency.format(costoFlete),
            isBold: true,
          ),
          const Divider(),
          _buildCostRow(
            "Costo Puesto en Bodega",
            currency.format(total),
            isTotal: true,
          ),

          const SizedBox(height: 8),
          Text(
            "* El costo de envío representa un incremento del ${incremento.toStringAsFixed(1)}% distribuido entre los productos.",
            style: TextStyle(
              fontSize: 10,
              color: Colors.blue.shade800,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCostRow(
    String label,
    String value, {
    bool isBold = false,
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isTotal ? Colors.black : Colors.grey[700],
            fontWeight: (isTotal || isBold)
                ? FontWeight.bold
                : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isTotal ? Colors.black : Colors.grey[800],
            fontWeight: (isTotal || isBold)
                ? FontWeight.bold
                : FontWeight.normal,
            fontSize: isTotal ? 16 : 14,
          ),
        ),
      ],
    );
  }

  // --- SECCION 4: LISTA DE PRODUCTOS ---
  Widget _buildProductList(NumberFormat currency) {
    final items = _movementData['items'] as List;

    return ListView.builder(
      shrinkWrap:
          true, // Importante porque está dentro de SingleChildScrollView
      physics: const NeverScrollableScrollPhysics(), // No scrollea internamente
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              // Cuadro de Cantidad
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "${item['cantidad']}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Descripción
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['nombre'],
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      item['sku'],
                      style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                    ),
                  ],
                ),
              ),

              // Totales
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    currency.format(item['subtotal']),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    "Unit: ${currency.format(item['precio_unitario'])}",
                    style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Auxiliar de Colores
  Color _getColorByType(String type) {
    switch (type) {
      case 'COMPRA':
        return Colors.green;
      case 'VENTA':
        return Colors.red;
      case 'TRASLADO':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
