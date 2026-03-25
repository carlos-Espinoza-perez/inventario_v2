import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventario_v2/core/providers/app_bar_provider.dart';
import 'package:inventario_v2/features/dashboard/presentation/widgets/content_view_dashboard.dart';

import 'package:inventario_v2/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:isar/isar.dart';
import 'package:inventario_v2/features/inventory/data/collections/producto_collection.dart';
import 'package:inventario_v2/features/inventory/data/collections/codigo_producto_collection.dart';
import 'package:inventario_v2/features/inventory/data/collections/inventario_collection.dart';
import 'package:inventario_v2/features/inventory/data/collections/inventario_codigo_producto_collection.dart';
import 'package:inventario_v2/features/inventory/data/collections/movimiento_producto_collection.dart';
import 'package:inventario_v2/features/inventory/data/collections/detalle_movimiento_producto_collection.dart';
import 'package:inventario_v2/features/auth/data/collections/bodega_collection.dart';
import 'package:inventario_v2/features/auth/data/collections/bodega_usuario_colletion.dart';
import 'package:inventario_v2/features/inventory/data/providers/bodega_provider.dart';
import 'package:inventario_v2/features/sales/data/collections/venta_collection.dart';
import 'package:inventario_v2/features/sales/data/collections/detalle_venta_collection.dart';
import 'package:inventario_v2/features/sales/data/collections/historial_pago_collection.dart';
import 'package:inventario_v2/features/sales/data/collections/caja_sesion_collection.dart';
import 'package:inventario_v2/features/sales/data/collections/caja_movimiento_extra_collection.dart';
import 'package:inventario_v2/features/sales/data/collections/cliente_collection.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(appBarProvider.notifier).reset());
  }

  @override
  Widget build(BuildContext context) {
    // Escuchamos el provider REAL
    final asyncData = ref.watch(dashboardProvider);

    return Column(
      children: [
        // BOTON TEMPORAL QA
        Container(
          width: double.infinity,
          color: Colors.red.shade100,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.delete_forever),
            label: const Text("QA: Limpiar DB (Ventas, Prod, Inv, Mov)"),
            onPressed: () async {
              showModalBottomSheet(
                context: context,
                builder: (BuildContext ctx) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Limpieza Peligrosa",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text("Borrará DB Local y la Nube Supabase. ¿Continuar?"),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text("Cancelar"),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                              child: const Text("Confirmar Limpieza", style: TextStyle(color: Colors.white)),
                              onPressed: () async {
                                Navigator.pop(ctx);
                                final isar = Isar.getInstance();
                                if (isar == null) return;

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Borrando Supabase...")),
                                );

                                try {
                                  final tablesToClear = [
                                    'detalle_venta',
                                    'historial_pago',
                                    'venta_producto',
                                    'caja_movimiento_extra',
                                    'caja_sesion',
                                    'cliente',
                                    'detalle_movimiento_producto',
                                    'movimiento_producto',
                                    'inventario_codigo_producto',
                                    'inventario_producto',
                                    'codigo_producto',
                                    'producto',
                                    'bodega_usuario',
                                    'bodega',
                                  ];

                                  for (final t in tablesToClear) {
                                    await Supabase.instance.client
                                        .from(t)
                                        .delete()
                                        .neq('id', '00000000-0000-0000-0000-000000000000');
                                  }
                                } catch (e) {
                                  debugPrint("Error borrando supabase: $e");
                                }

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Borrando DB Local...")),
                                );
                                              await isar.writeTxn(() async {
                                  // Borrar específicamente las colecciones mencionadas
                                  // Inventario y Productos
                                  await isar.productoCollections.clear();
                                  await isar.codigoProductoCollections.clear();
                                  await isar.inventarioCollections.clear();
                                  await isar.inventarioCodigoProductoCollections.clear();
                                  await isar.movimientoProductoCollections.clear();
                                  await isar.detalleMovimientoProductoCollections.clear();
                                  await isar.bodegaCollections.clear();
                                  await isar.bodegaUsuarioColletions.clear();

                                  // Ventas y Caja
                                  await isar.ventaCollections.clear();
                                  await isar.detalleVentaCollections.clear();
                                  await isar.historialPagoCollections.clear();
                                  await isar.cajaSesionCollections.clear();
                                  await isar.cajaMovimientoExtraCollections.clear();
                                  await isar.clienteCollections.clear();
                                });
                
                                // Recargar
                                ref.invalidate(dashboardProvider);
                                ref.invalidate(bodegaListProvider);
                                ref.invalidate(validBodegasIdsProvider);
                                ref.invalidate(selectedBodegaProvider);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Base de datos local limpiada")),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            child: asyncData.when(
              // A. ESTADO DE CARGA (SKELETON)
              loading: () => const _DashboardSkeletonView(),

              // B. ESTADO DE ERROR
              error: (err, stack) =>
                  Center(child: Text('Error al cargar datos: $err')),

              // C. ESTADO CARGADO (CONTENIDO REAL)
              data: (state) => ContentViewDashboard(state: state),
            ),
          ),
        ),
      ],
    );
  }
}

class _DashboardSkeletonView extends StatelessWidget {
  const _DashboardSkeletonView();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Skeleton Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const _SkeletonBox(width: 60, height: 60, isCircle: true),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      _SkeletonBox(width: 150, height: 20),
                      SizedBox(height: 10),
                      _SkeletonBox(width: 100, height: 14),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          const _SkeletonBox(width: 120, height: 24), // Título sección
          const SizedBox(height: 15),

          // 2. Skeleton Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 1.1,
            ),
            itemCount: 4,
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    _SkeletonBox(width: 50, height: 50, isCircle: true),
                    SizedBox(height: 15),
                    _SkeletonBox(width: 80, height: 16),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SkeletonBox extends StatefulWidget {
  final double width;
  final double height;
  final bool isCircle;

  const _SkeletonBox({
    required this.width,
    required this.height,
    this.isCircle = false,
  });

  @override
  State<_SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<_SkeletonBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    // Animación de pulso infinito
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _colorAnimation = ColorTween(
      begin: Colors.grey[200],
      end: Colors.grey[350],
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: _colorAnimation.value,
            borderRadius: widget.isCircle ? null : BorderRadius.circular(8),
            shape: widget.isCircle ? BoxShape.circle : BoxShape.rectangle,
          ),
        );
      },
    );
  }
}
