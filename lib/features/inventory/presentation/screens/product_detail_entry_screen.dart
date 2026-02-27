import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:uuid/uuid.dart';
import 'package:inventario_v2/core/presentation/widgets/custom_text_field.dart';

import 'package:inventario_v2/features/inventory/data/collections/producto_collection.dart';
import 'package:inventario_v2/features/inventory/data/providers/producto_provider.dart';
import 'package:inventario_v2/features/inventory/data/providers/categoria_provider.dart';
import 'package:inventario_v2/features/inventory/data/providers/inventario_provider.dart';
import 'package:inventario_v2/features/inventory/presentation/widgets/product_label_widget.dart';

class ProductEntryArgs {
  final String productId;
  final String categoriaId;
  ProductEntryArgs({required this.productId, required this.categoriaId});
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductEntryArgs &&
          productId == other.productId &&
          categoriaId == other.categoriaId;
  @override
  int get hashCode => productId.hashCode ^ categoriaId.hashCode;
}

class ProductEntryData {
  final ProductoCollection producto;
  final List<String> tallasDisponibles;
  final double margenSugerido;
  final double ultimoCosto;
  final double ultimoPrecioVenta;
  final int stockActual;
  ProductEntryData({
    required this.producto,
    required this.tallasDisponibles,
    required this.margenSugerido,
    required this.ultimoCosto,
    required this.ultimoPrecioVenta,
    required this.stockActual,
  });
}

final productEntryDataProvider =
    FutureProvider.family<ProductEntryData, ProductEntryArgs>((
      ref,
      args,
    ) async {
      final repoProducto = await ref.read(productoRepositoryProvider.future);
      final repoCategoria = await ref.read(categoriaRepositoryProvider.future);
      final repoInventario = await ref.read(
        inventarioRepositoryProvider.future,
      );

      final producto = await repoProducto.getProductoPorServerId(
        args.productId,
      );
      final categoria = await repoCategoria.getCategoriaPorServerId(
        args.categoriaId,
      );
      final inventarios = await repoInventario.getInventariosByProductId(
        args.productId,
      );

      List<String> tallas = ["S", "M", "L"];
      double margen = 30.0;

      if (categoria.especificacionJson != null) {
        try {
          final specs = jsonDecode(categoria.especificacionJson!);
          if (specs['tallas'] != null) {
            tallas = List<String>.from(specs['tallas']);
          }
          if (specs['porcentaje_ganancia'] != null) {
            double val = (specs['porcentaje_ganancia'] is int)
                ? (specs['porcentaje_ganancia'] as int).toDouble()
                : specs['porcentaje_ganancia'];
            if (val <= 1.0) val = val * 100;
            margen = val;
          }
        } catch (e) {
          debugPrint("Error specs: $e");
        }
      }

      final stockTotal = inventarios
          .fold(0.0, (sum, inv) => sum + inv.cantidadActual)
          .toInt();
      final lastCost = producto.ultimoCosto;
      final lastPrice = producto.precioBase ?? 0.0;

      return ProductEntryData(
        producto: producto,
        tallasDisponibles: tallas,
        margenSugerido: margen,
        ultimoCosto: lastCost,
        ultimoPrecioVenta: lastPrice,
        stockActual: stockTotal,
      );
    });

class ProductDetailEntryScreen extends ConsumerStatefulWidget {
  final String productId;
  final String categoriaId;
  final double? initialCost;
  final double? initialPrice;
  final List<Map<String, String>>? initialItems;

  const ProductDetailEntryScreen({
    super.key,
    required this.productId,
    required this.categoriaId,
    this.initialCost,
    this.initialPrice,
    this.initialItems,
  });

  @override
  ConsumerState<ProductDetailEntryScreen> createState() =>
      _ProductDetailEntryScreenState();
}

class _ProductDetailEntryScreenState
    extends ConsumerState<ProductDetailEntryScreen> {
  final TextEditingController _costCtrl = TextEditingController();
  final TextEditingController _marginCtrl = TextEditingController();
  final TextEditingController _priceCtrl = TextEditingController();

  // Lista plana interna (para DB)
  final List<Map<String, dynamic>> _generatedItems = [];
  bool _isInitialized = false;

  // Preferencias
  bool _defaultPrint = true;
  bool _defaultShowPrice = true;
  bool _defaultOnePerLot = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialItems != null) {
      _generatedItems.addAll(
        widget.initialItems!.map((item) {
          return {
            'qr': item['qr'],
            'size': item['size'],
            'printed': item['printed'] == 'true',
            'price': double.tryParse(item['price'] ?? '0') ?? 0.0,
          };
        }),
      );
    }
  }

  @override
  void dispose() {
    _costCtrl.dispose();
    _marginCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  void _initializeWithData(ProductEntryData data) {
    if (_isInitialized) return;
    double startCost = widget.initialCost ?? 0.0;
    double startPrice = widget.initialPrice ?? 0.0;
    String startMarginStr = "";

    if (startCost > 0 && startPrice > 0) {
      double margin = ((startPrice - startCost) / startCost) * 100;
      startMarginStr = margin.toStringAsFixed(2);
    } else {
      startMarginStr = data.margenSugerido.toStringAsFixed(0);
    }

    String priceText = "";
    if (startPrice > 0) {
      priceText = (startPrice % 1 == 0)
          ? startPrice.toInt().toString()
          : startPrice.toStringAsFixed(2);
    }

    if (startCost == 0 && data.ultimoCosto > 0) startCost = data.ultimoCosto;

    _costCtrl.text = startCost > 0 ? startCost.toStringAsFixed(2) : "";
    _priceCtrl.text = priceText;
    _marginCtrl.text = startMarginStr;
    setState(() => _isInitialized = true);
  }

  // --- LÓGICA MATEMÁTICA ---
  void _onCostChanged(String val) {
    if (_marginCtrl.text.isNotEmpty) {
      _calculatePriceFromMargin();
    } else if (_priceCtrl.text.isNotEmpty) {
      _calculateMarginFromPrice();
    }
  }

  void _onPriceChanged(String val) {
    if (_costCtrl.text.isNotEmpty) _calculateMarginFromPrice();
  }

  void _calculatePriceFromMargin() {
    double cost = double.tryParse(_costCtrl.text) ?? 0;
    double margin = double.tryParse(_marginCtrl.text) ?? 0;
    if (cost > 0) {
      double rawPrice = cost * (1 + (margin / 100));
      int priceInt = rawPrice.round();
      _priceCtrl.text = priceInt.toString();
    }
  }

  void _calculateMarginFromPrice() {
    double cost = double.tryParse(_costCtrl.text) ?? 0;
    double price = double.tryParse(_priceCtrl.text) ?? 0;
    if (cost > 0 && price > 0) {
      double margin = ((price - cost) / cost) * 100;
      _marginCtrl.text = margin.toStringAsFixed(1);
    }
  }

  // --- AGRUPACIÓN PARA VISUALIZACIÓN ---
  List<Map<String, dynamic>> _getGroupedItems() {
    final Map<String, Map<String, dynamic>> grouped = {};

    for (var item in _generatedItems) {
      final String sku = item['qr'];

      if (!grouped.containsKey(sku)) {
        grouped[sku] = {
          'qr': sku,
          'size': item['size'],
          'printed': item['printed'],
          'price': item['price'],
          'count': 0,
        };
      }

      grouped[sku]!['count'] = (grouped[sku]!['count'] as int) + 1;
    }

    return grouped.values.toList().reversed.toList();
  }

  @override
  Widget build(BuildContext context) {
    final args = ProductEntryArgs(
      productId: widget.productId,
      categoriaId: widget.categoriaId,
    );
    final asyncData = ref.watch(productEntryDataProvider(args));

    final groupedItems = _getGroupedItems();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.cyan.shade800,
        elevation: 0,
        title: asyncData.when(
          loading: () =>
              const Text("Cargando...", style: TextStyle(color: Colors.white)),
          error: (_, _) =>
              const Text("Error", style: TextStyle(color: Colors.white)),
          data: (data) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Generar Etiquetas",
                style: TextStyle(fontSize: 12, color: Colors.white70),
              ),
              Text(
                data.producto.nombre,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),

      floatingActionButton: _generatedItems.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () => asyncData.hasValue
                  ? _finishProductEntry(asyncData.value!)
                  : null,
              backgroundColor: Colors.cyan.shade900,
              icon: const Icon(Icons.save, color: Colors.white),
              label: Text(
                "GUARDAR (${_generatedItems.length})",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,

      body: asyncData.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
        data: (data) {
          if (!_isInitialized) {
            WidgetsBinding.instance.addPostFrameCallback(
              (_) => _initializeWithData(data),
            );
          }

          return Column(
            children: [
              // HEADER INFO
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  color: Colors.cyan.shade800,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    _buildHeaderInfoItem(
                      icon: Icons.history,
                      label: "Último Costo",
                      value: "\$${data.ultimoCosto.toStringAsFixed(2)}",
                    ),
                    const Spacer(),
                    _buildHeaderInfoItem(
                      icon: Icons.sell_outlined,
                      label: "Última Venta",
                      value: "\$${data.ultimoPrecioVenta.toStringAsFixed(2)}",
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. COSTOS
                      _buildSectionTitle("1. Costo y Precio (para Etiquetas)"),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 10),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                label: "Costo",
                                controller: _costCtrl,
                                hint: "0.00",
                                keyboardType: TextInputType.number,
                                onChanged: _onCostChanged,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: CustomTextField(
                                label: "Venta",
                                controller: _priceCtrl,
                                hint: "0",
                                keyboardType: TextInputType.number,
                                isReadOnly: false,
                                onChanged: _onPriceChanged,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // 2. BOTÓN AGREGAR
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _openAddSizesModal(data),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.shade800,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                          ),
                          icon: const Icon(Icons.add_circle_outline, size: 28),
                          label: const Text(
                            "AGREGAR TALLAS AL LOTE",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // 3. LISTA GENERADA (AGRUPADA)
                      if (groupedItems.isNotEmpty) ...[
                        _buildSectionTitle(
                          "2. Lotes Generados (${groupedItems.length})",
                        ),
                        const SizedBox(height: 10),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: groupedItems.length,
                          itemBuilder: (context, index) {
                            final group = groupedItems[index];
                            return _buildGroupedItemTile(
                              group,
                              data.producto.nombre,
                            );
                          },
                        ),
                        const SizedBox(height: 80),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- LÓGICA DE MODALES Y GENERACIÓN ---

  void _openAddSizesModal(ProductEntryData data) {
    if (_costCtrl.text.isEmpty || _priceCtrl.text.isEmpty) {
      _showErrorSnack("⚠️ Define costos primero");
      return;
    }

    final double basePrice = double.tryParse(_priceCtrl.text) ?? 0.0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _SizeSelectorModal(
        tallasDisponibles: data.tallasDisponibles,
        basePrice: basePrice,
        initialPrint: _defaultPrint,
        initialShowPrice: _defaultShowPrice,
        initialOnePerLot: _defaultOnePerLot,
        onAdd:
            (
              String size,
              int qty,
              double price,
              bool shouldPrint,
              bool showPrice,
              bool onePerLot,
              String? qrCode, // null = generar nuevo UUID
            ) {
              setState(() {
                _defaultPrint = shouldPrint;
                _defaultShowPrice = showPrice;
                _defaultOnePerLot = onePerLot;
              });
              _generateAndPrintLabels(
                size,
                qty,
                data.producto.nombre,
                price,
                shouldPrint,
                showPrice,
                onePerLot,
                qrCode, // null = generar automático
              );
              Navigator.pop(context);
            },
      ),
    );
  }

  void _generateAndPrintLabels(
    String size,
    int qty,
    String productName,
    double price,
    bool printNow,
    bool showPrice,
    bool onePerLot,
    String? existingQrCode,
  ) async {
    // Si viene un código existente lo usamos; si no, generamos uno nuevo
    final String skuFinal;
    if (existingQrCode != null && existingQrCode.isNotEmpty) {
      skuFinal = existingQrCode;
    } else {
      final variantUuid = const Uuid().v4().substring(0, 8).toUpperCase();
      skuFinal = "${widget.productId.substring(0, 4)}-$size-$variantUuid"
          .toUpperCase();
    }

    for (int i = 0; i < qty; i++) {
      setState(() {
        _generatedItems.add({
          'qr': skuFinal,
          'size': size,
          'printed': printNow,
          'price': price,
        });
      });
    }

    if (printNow) {
      if (!onePerLot) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("🖨️ Enviando $qty etiquetas..."),
            duration: const Duration(seconds: 1),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("🖨️ Enviando 1 etiqueta de lote..."),
            duration: Duration(seconds: 1),
          ),
        );
      }
      _showLabelPreviewDialog(productName, skuFinal, size, price, showPrice);
    }
  }

  void _showLabelPreviewDialog(
    String name,
    String sku,
    String size,
    double price,
    bool showPrice,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        Future.delayed(const Duration(seconds: 2), () {
          // ignore: use_build_context_synchronously
          if (mounted && Navigator.canPop(context)) Navigator.pop(context);
        });
        return AlertDialog(
          contentPadding: const EdgeInsets.all(10),
          title: const Text(
            "Imprimiendo...",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ProductLabelWidget(
                productName: name,
                sku: sku,
                size: size,
                price: price,
                showPrice: showPrice,
              ),
              const SizedBox(height: 10),
              const LinearProgressIndicator(),
            ],
          ),
        );
      },
    );
  }

  // --- UI TILES (AGRUPADOS) ---

  Widget _buildGroupedItemTile(Map<String, dynamic> group, String prodName) {
    final bool isPrinted = group['printed'] == true;
    final int count = group['count'];
    final String sku = group['qr'];
    final double itemPrice = group['price'] ?? 0.0;
    final double basePrice = double.tryParse(_priceCtrl.text) ?? 0.0;

    final bool hasCustomPrice = (itemPrice != basePrice);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Colors.cyan.shade50,
          child: Text(
            group['size'],
            style: TextStyle(
              color: Colors.cyan.shade900,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                "SKU: $sku",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Text(
                "x$count",
                style: TextStyle(
                  color: Colors.green.shade800,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                isPrinted ? "Etiquetas Generadas" : "No impreso",
                style: TextStyle(
                  fontSize: 11,
                  color: isPrinted ? Colors.green : Colors.orange,
                ),
              ),
            ),
            if (hasCustomPrice)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  "Precio Talla: \$${itemPrice.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          onPressed: () {
            setState(() {
              _generatedItems.removeWhere((item) => item['qr'] == sku);
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("🗑️ Se eliminaron $count items del lote"),
              ),
            );
          },
        ),
        onTap: () {
          _showLabelPreviewDialog(
            prodName,
            sku,
            group['size'],
            itemPrice,
            _defaultShowPrice,
          );
        },
      ),
    );
  }

  void _finishProductEntry(ProductEntryData data) {
    if (_costCtrl.text.isEmpty) {
      _showErrorSnack("Falta el costo");
      return;
    }

    final List<Map<String, String>> finalItems = _generatedItems
        .map(
          (e) => {
            'qr': e['qr'].toString(),
            'size': e['size'].toString(),
            'printed': (e['printed'] ?? false).toString(),
            'price': (e['price'] ?? 0.0).toString(),
          },
        )
        .toList();

    final result = {
      'productId': widget.productId,
      'categoriaId': widget.categoriaId,
      'productName': data.producto.nombre,
      'image': data.producto.imagenLocal ?? data.producto.imagenUrl ?? '',
      'cost': double.parse(_costCtrl.text),
      'price': double.parse(_priceCtrl.text),
      'items': finalItems,
    };
    Navigator.pop(context, result);
  }

  void _showErrorSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red.shade700),
    );
  }

  Widget _buildSectionTitle(String title) => Text(
    title,
    style: TextStyle(
      color: Colors.grey.shade800,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    ),
  );

  Widget _buildHeaderInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white70, size: 14),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 10),
            ),
          ],
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════
// ENUM: Modo de asignación del código QR/barras
// ═══════════════════════════════════════════════════════════
enum QrMode { generate, scan }

// ═══════════════════════════════════════════════════════════
// MODAL: Selector de talla + modo QR
// ═══════════════════════════════════════════════════════════
class _SizeSelectorModal extends StatefulWidget {
  final List<String> tallasDisponibles;
  final double basePrice;
  final bool initialPrint;
  final bool initialShowPrice;
  final bool initialOnePerLot;

  final void Function(
    String size,
    int qty,
    double price,
    bool shouldPrint,
    bool showPrice,
    bool onePerLot,
    String? qrCode, // null = generar nuevo; valor = código escaneado
  )
  onAdd;

  const _SizeSelectorModal({
    required this.tallasDisponibles,
    required this.basePrice,
    required this.onAdd,
    this.initialPrint = true,
    this.initialShowPrice = true,
    this.initialOnePerLot = false,
  });

  @override
  State<_SizeSelectorModal> createState() => _SizeSelectorModalState();
}

class _SizeSelectorModalState extends State<_SizeSelectorModal> {
  String? _selectedSize;
  final TextEditingController _qtyCtrl = TextEditingController();
  final TextEditingController _priceCtrl = TextEditingController();
  late bool _shouldPrint;
  late bool _showPrice;
  late bool _onePerLot;

  // --- QR MODE ---
  QrMode _qrMode = QrMode.generate;
  String? _scannedCode;

  @override
  void initState() {
    super.initState();
    _shouldPrint = widget.initialPrint;
    _showPrice = widget.initialShowPrice;
    _onePerLot = widget.initialOnePerLot;

    _priceCtrl.text = widget.basePrice % 1 == 0
        ? widget.basePrice.toInt().toString()
        : widget.basePrice.toStringAsFixed(2);

    _qtyCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _qtyCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  Future<void> _openScanner() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const _BarcodeScannerPage()),
    );
    if (result != null && result.isNotEmpty) {
      setState(() => _scannedCode = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final int qty = int.tryParse(_qtyCtrl.text) ?? 0;
    String confirmationText = "";
    Color confirmationColor = Colors.grey.shade100;
    IconData confirmationIcon = Icons.print_disabled;
    Color confirmationTextColor = Colors.grey;

    if (_shouldPrint && qty > 0) {
      confirmationColor = Colors.green.shade50;
      confirmationTextColor = Colors.green.shade800;
      confirmationIcon = Icons.print;
      confirmationText = _onePerLot
          ? "Se imprimirá 1 etiqueta para todo el lote."
          : "Se imprimirán $qty etiquetas individuales.";
      if (_showPrice) confirmationText += " (Con Precio)";
    } else if (!_shouldPrint) {
      confirmationText = "No se imprimirán etiquetas. Solo carga stock.";
    } else {
      confirmationText = "Ingresa cantidad para ver detalles.";
    }

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                "Agregar al Lote",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),

            // 1. Selector de Talla
            const Text(
              "1. Selecciona Talla",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 50,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: widget.tallasDisponibles.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final talla = widget.tallasDisponibles[index];
                  return ChoiceChip(
                    label: Text(talla),
                    selected: _selectedSize == talla,
                    selectedColor: Colors.orange.shade100,
                    onSelected: (_) => setState(() => _selectedSize = talla),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // 2. Fila: Cantidad y Precio
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "2. Cantidad",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _qtyCtrl,
                        keyboardType: TextInputType.number,
                        autofocus: true,
                        decoration: const InputDecoration(
                          hintText: "Ej: 12",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.numbers),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Precio (Talla)",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _priceCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: "0.00",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.attach_money),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 3. MODO QR
            const Text(
              "3. Código de barras / QR",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _QrModeButton(
                          label: "Generar nuevo",
                          icon: Icons.auto_awesome,
                          isSelected: _qrMode == QrMode.generate,
                          color: Colors.cyan.shade800,
                          onTap: () => setState(() {
                            _qrMode = QrMode.generate;
                            _scannedCode = null;
                          }),
                        ),
                      ),
                      Expanded(
                        child: _QrModeButton(
                          label: "Escanear producto",
                          icon: Icons.qr_code_scanner,
                          isSelected: _qrMode == QrMode.scan,
                          color: Colors.deepPurple,
                          onTap: () async {
                            setState(() => _qrMode = QrMode.scan);
                            await _openScanner();
                          },
                        ),
                      ),
                    ],
                  ),
                  if (_qrMode == QrMode.scan) ...[
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: _scannedCode != null
                          ? Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.green.shade700,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _scannedCode!,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.qr_code_scanner,
                                    color: Colors.deepPurple,
                                    size: 20,
                                  ),
                                  tooltip: "Volver a escanear",
                                  onPressed: _openScanner,
                                ),
                              ],
                            )
                          : InkWell(
                              onTap: _openScanner,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.camera_alt_outlined,
                                    color: Colors.deepPurple.shade300,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Toca para escanear el código",
                                    style: TextStyle(
                                      color: Colors.deepPurple.shade400,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 4. Opciones de etiqueta
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text(
                      "Imprimir Etiquetas",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    value: _shouldPrint,
                    activeThumbColor: Colors.orange.shade800,
                    onChanged: (val) => setState(() => _shouldPrint = val),
                  ),
                  if (_shouldPrint) ...[
                    const Divider(height: 1),
                    Row(
                      children: [
                        Expanded(
                          child: CheckboxListTile(
                            title: const Text(
                              "Con Precio",
                              style: TextStyle(fontSize: 13),
                            ),
                            value: _showPrice,
                            activeColor: Colors.cyan.shade800,
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                            onChanged: (val) =>
                                setState(() => _showPrice = val ?? true),
                          ),
                        ),
                        Expanded(
                          child: CheckboxListTile(
                            title: const Text(
                              "1 x Lote",
                              style: TextStyle(fontSize: 13),
                            ),
                            subtitle: const Text(
                              "Solo una",
                              style: TextStyle(fontSize: 10),
                            ),
                            value: _onePerLot,
                            activeColor: Colors.purple.shade700,
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                            onChanged: (val) =>
                                setState(() => _onePerLot = val ?? false),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Banner confirmación
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: confirmationColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: confirmationColor == Colors.grey.shade100
                      ? Colors.grey.shade300
                      : Colors.green.shade200,
                ),
              ),
              child: Row(
                children: [
                  Icon(confirmationIcon, color: confirmationTextColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      confirmationText,
                      style: TextStyle(
                        color: confirmationTextColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Botón Confirmar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_selectedSize == null) return;
                  // Si modo escanear pero sin código → abrir escáner primero
                  if (_qrMode == QrMode.scan && _scannedCode == null) {
                    _openScanner();
                    return;
                  }
                  final int qtyLocal = int.tryParse(_qtyCtrl.text) ?? 0;
                  final double priceLocal =
                      double.tryParse(_priceCtrl.text) ?? 0.0;
                  if (qtyLocal > 0) {
                    widget.onAdd(
                      _selectedSize!,
                      qtyLocal,
                      priceLocal,
                      _shouldPrint,
                      _showPrice,
                      _onePerLot,
                      _qrMode == QrMode.scan ? _scannedCode : null,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade800,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  "CONFIRMAR Y AGREGAR",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// WIDGET: Botón de selección de modo QR
// ═══════════════════════════════════════════════════════════
class _QrModeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _QrModeButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: color, width: 1.5) : null,
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? color : Colors.grey, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// PANTALLA: Escáner de código de barras con MobileScanner
// ═══════════════════════════════════════════════════════════
class _BarcodeScannerPage extends StatefulWidget {
  const _BarcodeScannerPage();

  @override
  State<_BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<_BarcodeScannerPage> {
  bool _hasScanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text(
          "Escanear código",
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (capture) {
              if (_hasScanned) return;
              final barcode = capture.barcodes.firstOrNull;
              final code = barcode?.rawValue;
              if (code != null && code.isNotEmpty) {
                _hasScanned = true;
                Navigator.pop(context, code);
              }
            },
          ),

          // Visor de alineación
          Center(
            child: Container(
              width: 260,
              height: 130,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.orange, width: 2.5),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          // Instrucción inferior
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "Apunta al código de barras del producto",
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
