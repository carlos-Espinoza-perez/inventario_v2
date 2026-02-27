import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:inventario_v2/features/inventory/data/providers/codigo_producto_provider.dart';
import 'package:inventario_v2/features/inventory/data/providers/producto_provider.dart';
import 'package:inventario_v2/features/inventory/data/collections/codigo_producto_collection.dart';
import 'package:inventario_v2/features/inventory/data/collections/producto_collection.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Modelo de resultado combinado
// ─────────────────────────────────────────────────────────────────────────────
class _SkuResult {
  final CodigoProductoCollection codigo;
  final ProductoCollection? producto;

  const _SkuResult({required this.codigo, this.producto});

  String get nombre => producto?.nombre ?? '—';

  String get marca {
    if (producto?.especificacionJson == null) return '—';
    try {
      final m = jsonDecode(producto!.especificacionJson!);
      return m['marca']?.toString() ??
          m['brand']?.toString() ??
          m['Marca']?.toString() ??
          '—';
    } catch (_) {
      return '—';
    }
  }

  double get precio => codigo.precioEspecifico ?? producto?.precioBase ?? 0.0;
  double get costo => codigo.costoEspecifico ?? producto?.ultimoCosto ?? 0.0;
  String get imagenUrl => producto?.imagenUrl ?? producto?.imagenLocal ?? '';
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider: busca todos los códigos que coincidan con el SKU escaneado
// ─────────────────────────────────────────────────────────────────────────────
final _skuResultsProvider = FutureProvider.family<List<_SkuResult>, String>((
  ref,
  sku,
) async {
  if (sku.isEmpty) return [];

  final repoCodigo = await ref.read(codigoProductoRepositoryProvider.future);
  final repoProducto = await ref.read(productoRepositoryProvider.future);

  final codigos = await repoCodigo.getCodigosBySkuOBarcode(sku);
  if (codigos.isEmpty) return [];

  final results = <_SkuResult>[];
  for (final c in codigos) {
    try {
      final prod = await repoProducto.getProductoPorServerId(c.productoId);
      results.add(_SkuResult(codigo: c, producto: prod));
    } catch (_) {
      results.add(_SkuResult(codigo: c));
    }
  }
  return results;
});

// ─────────────────────────────────────────────────────────────────────────────
// Pantalla principal
// ─────────────────────────────────────────────────────────────────────────────
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

    // Normalizar: trim + eliminar caracteres de control (\n, \r, \t, etc.)
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
          "Escáner de Producto",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        actions: [
          // Linterna
          IconButton(
            icon: Icon(
              _torchOn ? Icons.flashlight_on : Icons.flashlight_off,
              color: _torchOn ? Colors.yellow : Colors.white70,
            ),
            onPressed: () => setState(() => _torchOn = !_torchOn),
          ),
          // Re-escanear
          if (_lastScannedCode != null)
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.orange),
              tooltip: "Volver a escanear",
              onPressed: _resetScanner,
            ),
        ],
      ),

      body: Stack(
        children: [
          // ── Cámara ──────────────────────────────────────────────────
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

          // ── Marco de escaneo ─────────────────────────────────────────
          if (_isScanning)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 40), // Espacio para el AppBar
                  _ScannerFrame(),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "Apunta al código de barras del producto",
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),

          // ── Panel deslizable de resultados ───────────────────────────
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

          // ── Pill del código escaneado ────────────────────────────────
          if (_lastScannedCode != null)
            Positioned(
              bottom: panelHeight - 18,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade800,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black45,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.qr_code, color: Colors.white, size: 15),
                      const SizedBox(width: 6),
                      Text(
                        _lastScannedCode!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Marco animado del escáner
// ─────────────────────────────────────────────────────────────────────────────
class _ScannerFrame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const double size = 270.0;
    const double corner = 22.0;
    const double thickness = 4.0;

    // [left, top, flipH, flipV]
    final positions = [
      (left: 0.0, top: 0.0, flipH: false, flipV: false),
      (left: size - corner, top: 0.0, flipH: true, flipV: false),
      (left: 0.0, top: 150.0 - corner, flipH: false, flipV: true),
      (left: size - corner, top: 150.0 - corner, flipH: true, flipV: true),
    ];

    return SizedBox(
      width: size,
      height: 150,
      child: Stack(
        children: [
          for (final pos in positions)
            Positioned(
              left: pos.left,
              top: pos.top,
              child: _Corner(
                flipH: pos.flipH,
                flipV: pos.flipV,
                size: corner,
                thickness: thickness,
              ),
            ),

          // Línea de escaneo animada
          const Positioned.fill(child: _ScanLine()),
        ],
      ),
    );
  }
}

class _Corner extends StatelessWidget {
  final bool flipH;
  final bool flipV;
  final double size;
  final double thickness;
  const _Corner({
    required this.flipH,
    required this.flipV,
    required this.size,
    required this.thickness,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scaleX: flipH ? -1 : 1,
      scaleY: flipV ? -1 : 1,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                width: size,
                height: thickness,
                color: Colors.orange,
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                width: thickness,
                height: size,
                color: Colors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScanLine extends StatefulWidget {
  const _ScanLine();
  @override
  State<_ScanLine> createState() => _ScanLineState();
}

class _ScanLineState extends State<_ScanLine>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _anim = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Align(
        alignment: Alignment(_anim.value * 2 - 1, 0),
        child: Container(
          width: double.infinity,
          height: 2,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.orange.withValues(alpha: 0),
                Colors.orange.withValues(alpha: 0.9),
                Colors.orange.withValues(alpha: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Panel de resultados
// ─────────────────────────────────────────────────────────────────────────────
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
    final asyncResults = ref.watch(_skuResultsProvider(scannedCode));

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Cabecera
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 12, 4),
            child: Row(
              children: [
                Icon(Icons.inventory_2_outlined, color: Colors.cyan.shade800),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    "Productos encontrados",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
                TextButton.icon(
                  onPressed: onReset,
                  icon: const Icon(Icons.qr_code_scanner, size: 14),
                  label: const Text("Escanear otro"),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.orange.shade800,
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Contenido
          Expanded(
            child: asyncResults.when(
              loading: () => const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              error: (err, _) => Center(
                child: Text(
                  "Error: $err",
                  style: const TextStyle(color: Colors.red),
                ),
              ),
              data: (results) {
                if (results.isEmpty) {
                  return _EmptyState(code: scannedCode, onReset: onReset);
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  itemCount: results.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
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

// ─────────────────────────────────────────────────────────────────────────────
// Card de cada resultado
// ─────────────────────────────────────────────────────────────────────────────
class _ProductResultCard extends StatelessWidget {
  final _SkuResult result;
  final String? bodegaId;
  const _ProductResultCard({required this.result, this.bodegaId});

  @override
  Widget build(BuildContext context) {
    final precio = result.precio;
    final costo = result.costo;
    final margen = (precio > 0 && costo > 0)
        ? ((precio - costo) / costo * 100)
        : null;

    return GestureDetector(
      onTap: result.producto != null
          ? () {
              if (bodegaId != null) {
                context.push(
                  '/product-detail/${result.producto!.serverId}?bodegaId=$bodegaId',
                );
              } else {
                context.push('/product-detail/${result.producto!.serverId}');
              }
            }
          : null,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Imagen ──────────────────────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: result.imagenUrl.isNotEmpty
                  ? Image.network(
                      result.imagenUrl,
                      width: 68,
                      height: 68,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _ImagePlaceholder(),
                    )
                  : _ImagePlaceholder(),
            ),
            const SizedBox(width: 14),

            // ── Info ────────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre
                  Text(
                    result.nombre,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),

                  // Chips: Marca / Talla / Color
                  Wrap(
                    spacing: 5,
                    runSpacing: 4,
                    children: [
                      if (result.marca != '—')
                        _InfoChip(
                          label: result.marca,
                          icon: Icons.local_offer_outlined,
                          color: Colors.blue.shade700,
                        ),
                      _InfoChip(
                        label: "T: ${result.codigo.talla}",
                        icon: Icons.straighten,
                        color: Colors.cyan.shade700,
                      ),
                      if (result.codigo.color != null &&
                          result.codigo.color!.isNotEmpty)
                        _InfoChip(
                          label: result.codigo.color!,
                          icon: Icons.circle,
                          color: Colors.purple.shade600,
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Precio y margen
                  Row(
                    children: [
                      // Precio venta
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Text(
                          precio > 0
                              ? "\$${precio.toStringAsFixed(2)}"
                              : "Sin precio",
                          style: TextStyle(
                            color: Colors.green.shade800,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),

                      if (costo > 0) ...[
                        const SizedBox(width: 8),
                        Text(
                          "Costo: \$${costo.toStringAsFixed(2)}",
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 11,
                          ),
                        ),
                      ],

                      if (margen != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            "${margen.toStringAsFixed(1)}%",
                            style: TextStyle(
                              color: Colors.orange.shade800,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // ── Flecha detalle ───────────────────────────────────────
            if (result.producto != null)
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: Colors.grey.shade400,
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────
class _ImagePlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        Icons.inventory_2_outlined,
        color: Colors.grey.shade400,
        size: 28,
      ),
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
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
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
              "Sin resultados",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              "No hay productos con el código:\n$code",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onReset,
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text("Escanear de nuevo"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade800,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
