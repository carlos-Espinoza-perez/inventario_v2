import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  // Controlador para manejar la cámara (flash, pausa, etc)
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    returnImage: false,
  );

  bool _isProcessing = false; // Evita lecturas múltiples

  // SIMULACIÓN DE BASE DE DATOS
  final List<Map<String, dynamic>> _mockDb = [
    {
      "sku": "740123456789", // Ejemplo de código EAN-13 real
      "nombre": "Gorra Nike SB Negra",
      "stock": 15,
      "precio": 250.00,
      "costo": 120.00,
      "categoria": "Accesorio",
      "imagen": null,
    },
    // Puedes agregar más productos para probar
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Lógica cuando se detecta un código
  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return; // Si ya estamos procesando, ignorar

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    setState(() => _isProcessing = true);

    final String? code = barcodes.first.rawValue;

    if (code != null) {
      _buscarProducto(code);
    } else {
      setState(() => _isProcessing = false);
    }
  }

  void _buscarProducto(String code) async {
    // Simulamos delay de red
    // await Future.delayed(const Duration(milliseconds: 300));

    // Buscar en la lista mock (Aquí buscarías en Isar o Supabase)
    final producto = _mockDb.firstWhere(
      (p) =>
          p['sku'] == code ||
          p['sku'] == "740123456789", // Fallback para pruebas
      orElse: () => {},
    );

    if (!mounted) return;

    if (producto.isNotEmpty) {
      // PRODUCTO ENCONTRADO -> Mostrar Ficha
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => _ProductFoundSheet(product: producto),
      );
      // Al cerrar el modal, reactivamos el escáner
      setState(() => _isProcessing = false);
    } else {
      // NO ENCONTRADO -> Mostrar error rápido
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Producto no encontrado: $code"),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
      // Breve pausa antes de volver a escanear
      await Future.delayed(const Duration(seconds: 2));
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. CÁMARA
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            errorBuilder: (context, error) {
              return Center(
                child: Text(
                  "Error de cámara: $error",
                  style: const TextStyle(color: Colors.white),
                ),
              );
            },
          ),

          // 2. OVERLAY VISUAL (Caja de escaneo)
          CustomPaint(painter: _ScannerOverlayPainter(), child: Container()),

          // 3. CONTROLES SUPERIORES (Atrás y Flash)
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.black54,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => context.pop(),
                  ),
                ),
                CircleAvatar(
                  backgroundColor: Colors.black54,
                  child: IconButton(
                    // CORRECCIÓN AQUÍ:
                    // 1. Escuchamos al controlador completo (él tiene el estado)
                    icon: ValueListenableBuilder(
                      valueListenable: _controller,
                      builder: (context, state, child) {
                        // 2. Accedemos a state.torchState
                        final isTorchOn = state.torchState == TorchState.on;

                        return Icon(
                          isTorchOn ? Icons.flash_on : Icons.flash_off,
                          color: isTorchOn ? Colors.yellow : Colors.white,
                        );
                      },
                    ),
                    onPressed: () => _controller.toggleTorch(),
                  ),
                ),
              ],
            ),
          ),

          // 4. TEXTO DE AYUDA
          const Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Text(
              "Apunta el código de barras dentro del cuadro",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

// --- WIDGET DE RESULTADO (BOTTOM SHEET) ---
class _ProductFoundSheet extends StatelessWidget {
  final Map<String, dynamic> product;

  const _ProductFoundSheet({required this.product});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: "C\$ ", decimalDigits: 2);
    final stock = product['stock'] as int;
    final isLowStock = stock <= 3;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Manija superior
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Contenido Principal
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Foto del producto
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.checkroom_rounded,
                  size: 40,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(width: 16),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product['categoria'],
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product['nombre'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        "SKU: ${product['sku']}",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),

          // DATOS ECONÓMICOS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _InfoColumn(
                label: "Precio Venta",
                value: currency.format(product['precio']),
                valueColor: Colors.blue[700],
                isBig: true,
              ),
              _InfoColumn(
                label: "Stock Actual",
                value: "$stock unds",
                valueColor: isLowStock ? Colors.red : Colors.black87,
              ),
              // Costo (Discreto)
              _InfoColumn(
                label: "Costo Unit.",
                value: currency.format(product['costo']),
                valueColor: Colors.grey[600],
              ),
            ],
          ),

          const SizedBox(height: 30),

          // BOTÓN DE ACCIÓN
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                // LÓGICA DE VENTA:
                // 1. Agregar al carrito (State Management)
                // 2. Cerrar modal y quizás ir a la pantalla de ventas
                context.pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Agregado a la venta actual")),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                "Vender / Agregar al Carrito",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class _InfoColumn extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isBig;

  const _InfoColumn({
    required this.label,
    required this.value,
    this.valueColor,
    this.isBig = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[500],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: isBig ? 20 : 16,
            fontWeight: FontWeight.bold,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }
}

// --- PINTOR PARA EL RECUADRO CON ESQUINAS ---
class _ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black54;
    final width = size.width;
    final height = size.height;
    final scanWindowSize = width * 0.7; // Tamaño del cuadro

    // Dibujar fondo oscuro con recorte en el centro
    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, width, height))
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(width / 2, height / 2),
            width: scanWindowSize,
            height: scanWindowSize,
          ),
          const Radius.circular(20),
        ),
      )
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(backgroundPath, paint);

    // Dibujar esquinas blancas (Guías)
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCenter(
      center: Offset(width / 2, height / 2),
      width: scanWindowSize,
      height: scanWindowSize,
    );
    final cornerSize = 30.0;

    // Esquinas
    // Top Left
    canvas.drawPath(
      Path()
        ..moveTo(rect.left, rect.top + cornerSize)
        ..lineTo(rect.left, rect.top)
        ..lineTo(rect.left + cornerSize, rect.top),
      borderPaint,
    );
    // Top Right
    canvas.drawPath(
      Path()
        ..moveTo(rect.right - cornerSize, rect.top)
        ..lineTo(rect.right, rect.top)
        ..lineTo(rect.right, rect.top + cornerSize),
      borderPaint,
    );
    // Bottom Left
    canvas.drawPath(
      Path()
        ..moveTo(rect.left, rect.bottom - cornerSize)
        ..lineTo(rect.left, rect.bottom)
        ..lineTo(rect.left + cornerSize, rect.bottom),
      borderPaint,
    );
    // Bottom Right
    canvas.drawPath(
      Path()
        ..moveTo(rect.right - cornerSize, rect.bottom)
        ..lineTo(rect.right, rect.bottom)
        ..lineTo(rect.right, rect.bottom - cornerSize),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
