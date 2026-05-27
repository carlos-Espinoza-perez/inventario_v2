import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:inventario_v2/core/presentation/mixins/app_bar_config_mixin.dart';
import 'package:inventario_v2/core/providers/app_bar_provider.dart';
import 'package:inventario_v2/features/inventory/presentation/providers/movement_detail_provider.dart';
import '../../utils/pdf_generator.dart';

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

class _MovementDetailScreenState extends ConsumerState<MovementDetailScreen>
    with AppBarConfigMixin {
  Map<String, dynamic>? _currentData;

  @override
  void configureAppBar() {
    if (_currentData != null) {
      _setupHeader(_currentData!);
    }
  }

  void _setupHeader(Map<String, dynamic> data) {
    Future.microtask(() {
      if (!mounted || ModalRoute.of(context)?.isCurrent != true) return;
      String title = "Detalle de Movimiento";
      if (data['tipo'] == 'COMPRA') title = "Entrada de Mercadería";
      if (data['tipo'] == 'VENTA') title = "Detalle de Venta";
      if (data['tipo'] == 'TRASLADO') title = "Traslado entre Bodegas";

      ref
          .read(appBarProvider.notifier)
          .setOptions(
            title: title,
            subtitle: "#${widget.movementId}", // Podria ser referencia externa
            showBackButton: true,
            actions: [
              if (data['tipo'] != 'TRASLADO')
                IconButton(
                  icon: const Icon(Icons.share_outlined, color: Colors.black),
                  onPressed: () {}, // Compartir
                ),
              IconButton(
                icon: const Icon(Icons.print_outlined, color: Colors.black),
                onPressed: () {
                  if (_currentData != null) {
                    PdfGenerator.generateMovementPdf(_currentData!);
                  }
                }, // Imprimir PDF
              ),
            ],
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final movementAsync = ref.watch(movementDetailProvider(widget.movementId));
    final currency = NumberFormat.currency(symbol: "C\$ ", decimalDigits: 2);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: movementAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
        data: (data) {
          if (data == null) {
            return const Center(child: Text("No se encontró la información"));
          }

          if (_currentData == null) {
            _currentData = data;
            _setupHeader(data);
          }

          final themeColor = _getColorByType(data['tipo']);
          final String type = data['tipo'];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. HEADER DE ESTADO Y MONTO
                _buildStatusHeader(data, currency, themeColor),

                const SizedBox(height: 16),

                // 2. CONTEXTO (Varía según si es Venta, Compra o Traslado)
                if (type == 'TRASLADO')
                  _buildTransferRouteCard(data, themeColor)
                else if (type == 'VENTA')
                  _buildClientInfoCard(data, themeColor)
                else
                  _buildSupplierInfoCard(data, themeColor),

                const SizedBox(height: 16),

                // 3. LOGÍSTICA DE COSTOS (Solo para Traslados)
                if (type == 'TRASLADO' && data['costo_flete'] > 0) ...[
                  _buildLogisticsCostCard(data, currency),
                  const SizedBox(height: 16),
                ],

                // 4. LISTA DE PRODUCTOS
                const Text(
                  "Productos",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                _buildProductList(data, currency),

                // Espacio final para que no pegue abajo
                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- SECCION 1: HEADER DE ESTADO ---
  Widget _buildStatusHeader(
    Map<String, dynamic> data,
    NumberFormat currency,
    Color color,
  ) {
    double total = 0;
    if (data['tipo'] == 'TRASLADO') {
      total = data['costo_productos'] + (data['costo_flete'] ?? 0);
    } else {
      // Suma simple de items
      total = (data['items'] as List).fold(
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
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.05),
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
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  data['estado'],
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              Text(
                DateFormat('dd MMM yyyy, hh:mm a').format(data['fecha']),
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            data['tipo'] == 'TRASLADO'
                ? "Valor Total Transferido"
                : "Monto Total",
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
          Text(
            currency.format(total),
            style: const TextStyle(
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
  Widget _buildTransferRouteCard(Map<String, dynamic> data, Color color) {
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
                      data['origen'],
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
                      data['destino'],
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
  Widget _buildClientInfoCard(Map<String, dynamic> data, Color color) {
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
                data['cliente'] ?? "N/A",
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
                  data['metodo_pago'] ?? "N/A",
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
  Widget _buildSupplierInfoCard(Map<String, dynamic> data, Color color) {
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
                    data['proveedor'] ?? "N/A",
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
                data['referencia_externa'] ?? "N/A",
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- SECCION 3: LOGÍSTICA (Costo de envío) ---
  Widget _buildLogisticsCostCard(
    Map<String, dynamic> data,
    NumberFormat currency,
  ) {
    final costoProd = data['costo_productos'];
    final costoFlete = data['costo_flete'];
    final total = costoProd + costoFlete;

    // Calculamos cuánto aumentó el costo porcentualmente
    final incremento = (costoFlete / costoProd) * 100;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50.withValues(alpha: 0.5),
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
  Widget _buildProductList(Map<String, dynamic> data, NumberFormat currency) {
    final items = data['items'] as List;

    return Column(
      children: items.map((item) {
        final List variaciones = item['variantes'] ?? [];
        final groupedVariations = _groupVariantRows(variaciones);
        final firstVariant = variaciones.isNotEmpty
            ? Map<String, dynamic>.from(variaciones.first as Map)
            : null;
        final displaySku = _displayCode(
          firstVariant?['sku'] ?? firstVariant?['qr'] ?? item['sku'],
        );
        final sizeLabel = _productSizeLabel(groupedVariations);

        return _SoftCard(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.blue.shade50,
                    child: Icon(
                      Icons.inventory_2_outlined,
                      color: Colors.blue.shade700,
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
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            _InfoChip(
                              icon: Icons.straighten_outlined,
                              text: sizeLabel,
                            ),
                            _InfoChip(
                              icon: Icons.qr_code_2_rounded,
                              text: displaySku,
                            ),
                          ],
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
                        "${_formatQuantity(_readNum(item['cantidad']) ?? 0)} unds",
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      Text(
                        "Unit: ${currency.format(item['precio_compra'] ?? item['precio_unitario'])}",
                        style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ],
              ),
              if (groupedVariations.isNotEmpty) ...[
                const SizedBox(height: 12),
                ...groupedVariations.map((variant) {
                  final String tallaStr = _displaySize(
                    variant['talla'] ?? variant['size'],
                  );
                  final String colorStr =
                      variant['color']?.toString().trim() ?? '';
                  final String codeStr = _displayCode(
                    variant['sku'] ?? variant['qr'],
                  );
                  final num qty = _readNum(variant['cantidad']) ?? 0;
                  final num? precioEsp = _readNum(
                    variant['precio'] ?? variant['price'],
                  );
                  final String precioStr = precioEsp != null
                      ? currency.format(precioEsp)
                      : (item['precio_compra'] != null
                            ? "${currency.format(item['precio_compra'])} (Est)"
                            : "-");

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.sell_outlined,
                            size: 15,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                [
                                  tallaStr,
                                  if (colorStr.isNotEmpty) colorStr,
                                ].join(' - '),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[800],
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                codeStr,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "${_formatQuantity(qty)}x",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          precioStr,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  String _displaySize(Object? value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty || text.toLowerCase() == 'general') {
      return 'Sin talla especifica';
    }
    return text;
  }

  String _formatQuantity(num value) {
    return value.truncateToDouble() == value
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(1);
  }

  String _displayCode(Object? value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty) return 'Sin código';
    if (text.length <= 22) return text;
    return '${text.substring(0, 18)}...';
  }

  num? _readNum(Object? value) {
    if (value is num) return value;
    if (value is String) return num.tryParse(value);
    return null;
  }

  List<Map<String, dynamic>> _groupVariantRows(List rows) {
    final grouped = <String, Map<String, dynamic>>{};

    for (final raw in rows) {
      if (raw is! Map) continue;

      final row = Map<String, dynamic>.from(raw);
      final talla = _displaySize(row['talla'] ?? row['size']);
      final color = row['color']?.toString().trim() ?? '';
      final price = _readNum(row['precio'] ?? row['price']);
      final qty = _readNum(row['cantidad'] ?? row['quantity']) ?? 1;
      final sku = (row['sku'] ?? row['qr'])?.toString().trim();
      final key = '$talla|$color|${price ?? ''}';

      final current = grouped.putIfAbsent(
        key,
        () => {
          'talla': talla,
          'color': color.isEmpty ? null : color,
          'sku': sku,
          'precio': price,
          'cantidad': 0.0,
          'skus': <String>{},
        },
      );

      current['cantidad'] = (current['cantidad'] as double) + qty.toDouble();
      if (sku != null && sku.isNotEmpty) {
        (current['skus'] as Set<String>).add(sku);
      }
    }

    return grouped.values.map((item) {
      final skus = item['skus'] as Set<String>;
      final singleSku = skus.isEmpty ? item['sku'] : skus.first;
      return {...item, 'sku': skus.length <= 1 ? singleSku : 'Varios codigos'};
    }).toList();
  }

  String _productSizeLabel(List<Map<String, dynamic>> variants) {
    final sizes =
        variants
            .map((variant) => _displaySize(variant['talla'] ?? variant['size']))
            .where((size) => size != 'Sin talla especifica')
            .toSet()
            .toList()
          ..sort();

    if (sizes.isEmpty) return 'Sin talla especifica';
    if (sizes.length == 1) return 'Talla ${sizes.first}';
    if (sizes.length <= 3) return 'Tallas ${sizes.join(', ')}';
    return '${sizes.length} tallas';
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

class _SoftCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  const _SoftCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.grey[700]),
          const SizedBox(width: 4),
          Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[800],
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
