import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import 'package:inventario_v2/core/providers/database_provider.dart';
import 'package:inventario_v2/features/sales/data/collections/venta_collection.dart';
import 'package:inventario_v2/features/sales/data/collections/detalle_venta_collection.dart';
import 'package:inventario_v2/features/sales/data/collections/historial_pago_collection.dart';
import 'package:inventario_v2/features/sales/data/collections/cliente_collection.dart';
import 'package:inventario_v2/core/constants/app_enums.dart';
import 'package:inventario_v2/core/providers/app_bar_provider.dart';
import 'package:inventario_v2/features/auth/presentation/providers/auth_provider.dart';
import 'package:inventario_v2/features/inventory/data/providers/bodega_provider.dart';
import 'package:inventario_v2/features/inventory/data/collections/inventario_collection.dart';
import 'package:inventario_v2/features/inventory/data/collections/codigo_producto_collection.dart';
import 'package:inventario_v2/features/inventory/data/collections/inventario_codigo_producto_collection.dart';
import 'package:inventario_v2/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:inventario_v2/features/inventory/data/collections/producto_collection.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final double subtotal;
  final double tax;
  final double total;

  const CheckoutScreen({
    super.key,
    required this.cartItems,
    required this.subtotal,
    required this.tax,
    required this.total,
  });

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  // Estado
  String _saleType = "Contado"; // Opciones: "Contado", "Fiado"
  final TextEditingController _clientCtrl = TextEditingController();
  final TextEditingController _depositCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(appBarProvider.notifier)
          .setOptions(title: "Confirmar Venta", showBackButton: true);
    });
  }

  // Cálculos dinámicos
  double get _depositAmount => double.tryParse(_depositCtrl.text) ?? 0.0;

  double get _pendingBalance {
    if (_saleType == "Contado") return 0.0;
    // Si es fiado: Total - Abono. Si el abono es mayor al total, es 0.
    double balance = widget.total - _depositAmount;
    return balance < 0 ? 0 : balance;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. CLIENTE
            const Text(
              "Cliente",
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _clientCtrl,
              decoration: InputDecoration(
                hintText: "Nombre del cliente...",
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 16,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // 2. TIPO DE VENTA (SELECTOR)
            const Text(
              "Tipo de Venta",
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _SaleTypeCard(
                  label: "CONTADO",
                  icon: Icons.monetization_on_outlined,
                  isSelected: _saleType == "Contado",
                  color: Colors.green,
                  onTap: () {
                    setState(() {
                      _saleType = "Contado";
                      _depositCtrl
                          .clear(); // Limpiamos abono si cambia a contado
                    });
                  },
                ),
                const SizedBox(width: 15),
                _SaleTypeCard(
                  label: "FIADO / CRÉDITO",
                  icon: Icons.history_edu_outlined,
                  isSelected: _saleType == "Fiado",
                  color: Colors.orange,
                  onTap: () => setState(() => _saleType = "Fiado"),
                ),
              ],
            ),

            // 3. SECCIÓN ABONO (SOLO SI ES FIADO)
            if (_saleType == "Fiado") ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Abono Inicial (Opcional)",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.brown,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _depositCtrl,
                      keyboardType: TextInputType.number,
                      // Actualizamos la UI cada vez que escribe para recalcular el saldo
                      onChanged: (val) => setState(() {}),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.attach_money,
                          color: Colors.orange,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        hintText: "0.00",
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 30),

            // 4. RESUMEN FINANCIERO
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _SummaryRow(label: "Subtotal", value: widget.subtotal),
                  const Divider(height: 24),

                  // TOTAL DE LA VENTA
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "TOTAL VENTA",
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        NumberFormat.simpleCurrency().format(widget.total),
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),

                  // INFORMACIÓN DE CRÉDITO (SI ES FIADO)
                  if (_saleType == "Fiado") ...[
                    const SizedBox(height: 12),
                    const Divider(color: Colors.orange, thickness: 1),
                    const SizedBox(height: 8),
                    _SummaryRow(
                      label: "(-) Abono Inicial",
                      value: _depositAmount,
                      isNegative: true,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "SALDO PENDIENTE",
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            color: Colors.red,
                          ),
                        ),
                        Text(
                          NumberFormat.simpleCurrency().format(_pendingBalance),
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 40),

            // 5. BOTÓN FINALIZAR
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: _processSale,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _saleType == "Fiado"
                      ? Colors.orange[800]
                      : Colors.green[700],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 4,
                ),
                icon: Icon(
                  _saleType == "Fiado"
                      ? Icons.save_as
                      : Icons.check_circle_outline,
                  color: Colors.white,
                ),
                label: Text(
                  _saleType == "Fiado" ? "REGISTRAR FIADO" : "COBRAR CONTADO",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _processSale() async {
    // Validaciones
    if (_saleType == "Fiado" && _clientCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "⚠️ Para ventas al fiado, el nombre del cliente es obligatorio",
          ),
        ),
      );
      return;
    }

    if (_depositAmount > widget.total) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("⚠️ El abono no puede ser mayor al total"),
        ),
      );
      return;
    }

    try {
      final isar = await ref.read(isarDbProvider.future);

      final authCtrl = ref.read(authControllerProvider.notifier);
      final usuario = authCtrl.usuarioActual;
      final empresaId = usuario?.empresaId ?? 'empresa_id_placeholder';
      final usuarioRegistroId = usuario?.serverId ?? 'user_current';
      final dashboardState = ref.read(dashboardProvider).value;
      final cajaSesionId = dashboardState?.cajaAbierta?.serverId;

      if (cajaSesionId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "⚠️ No hay una sesión de caja abierta. Abre caja primero.",
              ),
            ),
          );
        }
        return;
      }

      final selectedBodega = ref.read(selectedBodegaProvider);
      final bodegaId = selectedBodega?.serverId ?? '';

      if (bodegaId.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "⚠️ Requieres tener una bodega seleccionada para vender.",
              ),
            ),
          );
        }
        return;
      }

      // PROCESAR CLIENTE (Buscar o Crear)

      // PROCESAR CLIENTE (Buscar o Crear)
      ClienteCollection? cliente;
      if (_clientCtrl.text.isNotEmpty) {
        cliente = await isar.clienteCollections
            .filter()
            .nombreEqualTo(_clientCtrl.text)
            .findFirst();
        if (cliente == null) {
          cliente = ClienteCollection()
            ..serverId = DateTime.now().millisecondsSinceEpoch
                .toString() // ID temporal
            ..empresaId =
                empresaId // ID de la empresa real
            ..nombre = _clientCtrl.text
            ..celular =
                '' // Opcional
            ..fechaRegistro = DateTime.now()
            ..ultimaActualizacion = DateTime.now();

          await isar.writeTxn(() async {
            await isar.clienteCollections.put(cliente!);
          });
        }
      }

      await isar.writeTxn(() async {
        // 1. CREAR VENTA
        final nuevaVenta = VentaCollection()
          ..serverId = DateTime.now().millisecondsSinceEpoch.toString()
          ..empresaId = empresaId
          ..clienteId = cliente?.serverId ?? 'final_consumer'
          ..fechaVenta = DateTime.now()
          ..totalVenta = widget.total
          ..totalPagado = _saleType == "Contado" ? widget.total : _depositAmount
          ..saldoPendiente = _saleType == "Contado"
              ? 0
              : (widget.total - _depositAmount)
          ..tipoVenta = _saleType == "Contado"
              ? TipoVenta.contado
              : TipoVenta.credito
          ..estadoPago =
              (_saleType == "Contado" || _depositAmount >= widget.total)
              ? EstadoPago.pagado
              : EstadoPago.pendiente
          ..cajaSesionId = cajaSesionId
          ..estado = true
          ..ultimaActualizacion = DateTime.now()
          ..usuarioRegistroId = usuarioRegistroId;

        await isar.ventaCollections.put(nuevaVenta);

        // 2. CREAR DETALLES Y ACTUALIZAR STOCK
        for (var item in widget.cartItems) {
          final productoId = item['id'] as String;
          final cantidad = (item['qty'] as num).toDouble();
          final precio = (item['price'] as num).toDouble();
          final talla = item['size']; // Puede ser nulo o vacío

          double costoDelProducto = 0.0;

          if (talla != null && talla.toString().isNotEmpty) {
            final codigoProd = await isar.codigoProductoCollections
                .filter()
                .productoIdEqualTo(productoId)
                .tallaEqualTo(talla.toString())
                .findFirst();
            if (codigoProd != null && codigoProd.costoEspecifico != null) {
              costoDelProducto = codigoProd.costoEspecifico!;
            }
          }

          if (costoDelProducto == 0.0) {
            final producto = await isar.productoCollections
                .filter()
                .serverIdEqualTo(productoId)
                .findFirst();
            if (producto != null) costoDelProducto = producto.ultimoCosto;
          }

          final detalle = DetalleVentaCollection()
            ..serverId =
                "${nuevaVenta.serverId}-$productoId-${DateTime.now().millisecondsSinceEpoch}"
            ..ventaId = nuevaVenta.serverId
            ..productoId = productoId
            ..cantidad = cantidad
            ..precioUnitario = precio
            ..subTotal = (precio * cantidad)
            ..descuento = 0.0
            ..costoHistoricoCompra = costoDelProducto
            ..ultimaActualizacion = DateTime.now();

          await isar.detalleVentaCollections.put(detalle);

          // ACTUALIZAR STOCK EN INVENTARIO (Bodega actual)
          final inventario = await isar.inventarioCollections
              .filter()
              .bodegaIdEqualTo(bodegaId)
              .productoIdEqualTo(productoId)
              .findFirst();

          if (inventario != null) {
            inventario.cantidadActual -= cantidad;
            inventario.ultimaActualizacion = DateTime.now();
            inventario.pendienteSincronizacion = true;
            await isar.inventarioCollections.put(inventario);

            // ACTUALIZAR STOCK DE LA TALLA (Si aplica)
            if (talla != null && talla.toString().isNotEmpty) {
              final codigoProd = await isar.codigoProductoCollections
                  .filter()
                  .productoIdEqualTo(productoId)
                  .tallaEqualTo(talla.toString())
                  .findFirst();

              if (codigoProd != null) {
                final invCodProd = await isar
                    .inventarioCodigoProductoCollections
                    .filter()
                    .inventarioIdEqualTo(inventario.serverId)
                    .codigoProductoIdEqualTo(codigoProd.serverId)
                    .findFirst();

                if (invCodProd != null) {
                  invCodProd.cantidad -= cantidad;
                  invCodProd.ultimaActualizacion = DateTime.now();
                  invCodProd.pendienteSincronizacion = true;
                  await isar.inventarioCodigoProductoCollections.put(
                    invCodProd,
                  );
                }
              }
            }
          }
        }

        // 3. REGISTRAR PAGO INICIAL (Si aplica)
        double montoInicial = _saleType == "Contado"
            ? widget.total
            : _depositAmount;
        if (montoInicial > 0) {
          final pago = HistorialPagoCollection()
            ..serverId = "pay-${DateTime.now().millisecondsSinceEpoch}"
            ..ventaId = nuevaVenta.serverId
            ..cajaSesionId = cajaSesionId
            ..montoPagado = montoInicial
            ..metodoDePago = MetodoPago
                .efectivo // Por defecto Efectivo, mejorar UI para selección
            ..fechaRegistro = DateTime.now()
            ..usuarioRegistroId = usuarioRegistroId
            ..ultimaActualizacion = DateTime.now();

          await isar.historialPagoCollections.put(pago);
        }
      });

      // Refrescar indicadores financieros de la caja abierta
      ref.invalidate(dashboardProvider);

      if (!mounted) return;

      // EXITO
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _saleType == "Fiado"
                    ? Icons.pending_actions
                    : Icons.check_circle,
                color: _saleType == "Fiado" ? Colors.orange : Colors.green,
                size: 60,
              ),
              const SizedBox(height: 20),
              Text(
                _saleType == "Fiado" ? "Crédito Registrado" : "Venta Exitosa",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _saleType == "Fiado"
                    ? "Saldo pendiente: ${NumberFormat.simpleCurrency().format(_pendingBalance)}"
                    : "Cobro total realizado correctamente.",
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx); // Close dialog
                Navigator.pop(
                  context,
                  true,
                ); // Close checkout and return true to clear cart
              },
              child: const Text("CERRAR"),
            ),
          ],
        ),
      );
    } catch (e) {
      debugPrint("Error procesando venta: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error al guardar venta: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

// --- WIDGETS AUXILIARES ---

class _SaleTypeCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _SaleTypeCard({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.1) : Colors.white,
            border: Border.all(
              color: isSelected ? color : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? color : Colors.grey, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: isSelected ? color : Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final double value;
  final bool isNegative;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isNegative = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[700])),
        Text(
          NumberFormat.simpleCurrency().format(value),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isNegative ? Colors.red : Colors.black,
          ),
        ),
      ],
    );
  }
}
