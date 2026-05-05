import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:inventario_v2/core/db/models/product_catalog_models.dart';
import 'package:inventario_v2/features/inventory/data/providers/codigo_producto_provider.dart';

class BarcodeScannerScreen extends ConsumerStatefulWidget {
  final String? bodegaId;
  const BarcodeScannerScreen({super.key, this.bodegaId});

  @override
  ConsumerState<BarcodeScannerScreen> createState() =>
      _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends ConsumerState<BarcodeScannerScreen> {
  String? _lastScannedCode;
  bool _isScanning = true;
  bool _torchOn = false;

  void _onDetect(BarcodeCapture capture) {
    if (!_isScanning) return;
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null) return;
    final code = raw.trim().replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '');
    if (code.isNotEmpty && code != _lastScannedCode) {
      setState(() {
        _lastScannedCode = code;
        _isScanning = false;
      });
    }
  }

  void _resetScanner() {
    setState(() {
      _lastScannedCode = null;
      _isScanning = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final panelHeight = MediaQuery.of(context).size.height * 0.68;
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.black.withValues(alpha: 0.55),
        elevation: 0,
        title: const Text(
          'Escaner de Producto',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _torchOn ? Icons.flashlight_on : Icons.flashlight_off,
              color: _torchOn ? Colors.yellow : Colors.white70,
            ),
            onPressed: () => setState(() => _torchOn = !_torchOn),
          ),
          if (_lastScannedCode != null)
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.orange),
              tooltip: 'Volver a escanear',
              onPressed: _resetScanner,
            ),
        ],
      ),
      body: Stack(
        children: [
          if (_isScanning)
            MobileScanner(onDetect: _onDetect)
          else
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black, Color(0xFF111111)],
                ),
              ),
            ),
          if (_isScanning)
            const Center(child: _ScannerFrame()),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 450),
            curve: Curves.easeOutCubic,
            bottom: 0,
            left: 0,
            right: 0,
            height: _lastScannedCode != null ? panelHeight : 0,
            child: _lastScannedCode != null
                ? _ResultsPanel(
                    scannedCode: _lastScannedCode!,
                    bodegaId: widget.bodegaId,
                    onReset: _resetScanner,
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _ScannerFrame extends StatelessWidget {
  const _ScannerFrame();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 40),
        Container(
          width: 270,
          height: 150,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.orange, width: 2.5),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Apunta al codigo de barras del producto',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ),
      ],
    );
  }
}

class _ResultsPanel extends ConsumerWidget {
  final String scannedCode;
  final String? bodegaId;
  final VoidCallback onReset;

  const _ResultsPanel({
    required this.scannedCode,
    this.bodegaId,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncResults = ref.watch(barcodeLookupProvider(scannedCode));
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 12, 4),
            child: Row(
              children: [
                Icon(Icons.inventory_2_outlined, color: Colors.cyan.shade800),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Productos encontrados',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
                TextButton.icon(
                  onPressed: onReset,
                  icon: const Icon(Icons.qr_code_scanner, size: 14),
                  label: const Text('Escanear otro'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: asyncResults.when(
              loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
              error: (err, _) => Center(child: Text('Error: $err')),
              data: (results) {
                if (results.isEmpty) {
                  return _EmptyState(code: scannedCode, onReset: onReset);
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  itemCount: results.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _ProductResultCard(
                    result: results[i],
                    bodegaId: bodegaId,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductResultCard extends StatelessWidget {
  final BarcodeLookupResultDrift result;
  final String? bodegaId;

  const _ProductResultCard({required this.result, this.bodegaId});

  @override
  Widget build(BuildContext context) {
    final precio = result.variante.precioEspecifico ?? result.producto.precioBase ?? 0.0;
    final costo = result.variante.costoEspecifico ?? result.producto.ultimoCosto;
    final margen = (precio > 0 && costo > 0) ? ((precio - costo) / costo * 100) : null;

    return GestureDetector(
      onTap: () {
        if (bodegaId != null) {
          context.push('/product-detail/${result.producto.id}?bodegaId=$bodegaId');
        } else {
          context.push('/product-detail/${result.producto.id}');
        }
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: _buildImage(),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.producto.nombre,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Wrap(
                    spacing: 5,
                    runSpacing: 4,
                    children: [
                      _InfoChip(
                        label: result.variante.sku,
                        icon: Icons.qr_code_2,
                        color: Colors.cyan.shade700,
                      ),
                      _InfoChip(
                        label: 'T: ${result.variante.talla ?? 'General'}',
                        icon: Icons.straighten,
                        color: Colors.blue.shade700,
                      ),
                      if ((result.variante.color ?? '').isNotEmpty)
                        _InfoChip(
                          label: result.variante.color!,
                          icon: Icons.circle,
                          color: Colors.purple.shade600,
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Text(
                          precio > 0 ? '\$${precio.toStringAsFixed(2)}' : 'Sin precio',
                          style: TextStyle(
                            color: Colors.green.shade800,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      if (margen != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          '${margen.toStringAsFixed(1)}%',
                          style: TextStyle(
                            color: Colors.orange.shade800,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (result.producto.imagenLocal != null &&
        File(result.producto.imagenLocal!).existsSync()) {
      return Image.file(
        File(result.producto.imagenLocal!),
        width: 68,
        height: 68,
        fit: BoxFit.cover,
      );
    }
    if ((result.producto.imagenUrl ?? '').isNotEmpty) {
      return Image.network(
        result.producto.imagenUrl!,
        width: 68,
        height: 68,
        fit: BoxFit.cover,
        errorBuilder: (_, error, stackTrace) => const _ImagePlaceholder(),
      );
    }
    return const _ImagePlaceholder();
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(Icons.inventory_2_outlined, color: Colors.grey.shade400, size: 28),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _InfoChip({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String code;
  final VoidCallback onReset;

  const _EmptyState({required this.code, required this.onReset});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 72, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text(
              'Sin resultados',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'No hay productos con el codigo:\n$code',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onReset,
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Escanear de nuevo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade800,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
