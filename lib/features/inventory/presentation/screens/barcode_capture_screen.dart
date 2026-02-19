import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeCaptureScreen extends StatefulWidget {
  const BarcodeCaptureScreen({super.key});

  @override
  State<BarcodeCaptureScreen> createState() => _BarcodeCaptureScreenState();
}

class _BarcodeCaptureScreenState extends State<BarcodeCaptureScreen> {
  // Configuración del controlador
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    returnImage: false,
  );

  bool _isScanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "Escanear Código",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          // BOTÓN FLASH
          ValueListenableBuilder(
            valueListenable: _controller,
            builder: (context, state, child) {
              switch (state.torchState) {
                case TorchState.off:
                  return IconButton(
                    icon: const Icon(Icons.flash_off, color: Colors.grey),
                    onPressed: () => _controller.toggleTorch(),
                  );
                case TorchState.on:
                  return IconButton(
                    icon: const Icon(Icons.flash_on, color: Colors.yellow),
                    onPressed: () => _controller.toggleTorch(),
                  );
                default:
                  return const Icon(Icons.flash_off, color: Colors.grey);
              }
            },
          ),

          // BOTÓN CAMBIAR CÁMARA
          ValueListenableBuilder(
            valueListenable: _controller,
            builder: (context, state, child) {
              switch (state.cameraDirection) {
                case CameraFacing.front:
                  return IconButton(
                    icon: const Icon(Icons.camera_front),
                    onPressed: () => _controller.switchCamera(),
                  );
                case CameraFacing.back:
                  return IconButton(
                    icon: const Icon(Icons.camera_rear),
                    onPressed: () => _controller.switchCamera(),
                  );
                default:
                  return IconButton(
                    icon: const Icon(Icons.camera_rear),
                    onPressed: () => _controller.switchCamera(),
                  );
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              if (_isScanned) return;
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  setState(() => _isScanned = true);
                  Navigator.pop(context, barcode.rawValue);
                  break;
                }
              }
            },
          ),
          // AQUÍ ESTÁ EL CAMBIO DEL RECUADRO
          _buildScanOverlay(),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  "Apunta el código dentro del cuadro",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET DEL RECUADRO MODIFICADO ---
  Widget _buildScanOverlay() {
    // Definimos las nuevas dimensiones aquí para usarlas en ambos contenedores
    const double scanWidth = 320.0; // Más ancho
    const double scanHeight = 150.0; // Menos alto

    return Stack(
      children: [
        // 1. La máscara oscura con el recorte
        ColorFiltered(
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.6),
            BlendMode.srcOut,
          ),
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.black,
                  backgroundBlendMode: BlendMode.dstOut,
                ),
              ),
              Center(
                // El recorte transparente
                child: Container(
                  height: scanHeight,
                  width: scanWidth,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        ),
        // 2. El borde visual (Cyan)
        Center(
          child: Container(
            height: scanHeight,
            width: scanWidth,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.cyan, width: 2),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
