import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventario_v2/core/database/app_bar_provider.dart';
import 'package:inventario_v2/features/dashboard/presentation/widgets/content_view_dashboard.dart';

// --- 1. PROVIDER SIMULADO (Para ver el Skeleton) ---
// En el futuro, aquí usarás tu 'dashboardInfoProvider' real.
final dashboardFakeLoaderProvider = FutureProvider.autoDispose<bool>((
  ref,
) async {
  await Future.delayed(const Duration(seconds: 3)); // Simula carga de DB
  return true;
});

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
    // Escuchamos el provider simulado
    final asyncData = ref.watch(dashboardFakeLoaderProvider);

    return SingleChildScrollView(
      child: asyncData.when(
        // A. ESTADO DE CARGA (SKELETON)
        loading: () => const _DashboardSkeletonView(),

        // B. ESTADO DE ERROR
        error: (err, stack) => Center(child: Text('Error: $err')),

        // C. ESTADO CARGADO (CONTENIDO REAL/MOCK)
        data: (_) => const ContentViewDashboard(),
      ),
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
