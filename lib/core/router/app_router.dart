import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventario_v2/core/presentation/widgets/main_layout.dart';
import 'package:inventario_v2/features/inventory/presentation/screens/barcode_scanner_screen.dart';
import 'package:inventario_v2/features/inventory/presentation/screens/magic_camera_screen.dart';
import 'package:inventario_v2/features/inventory/presentation/screens/movement_detail_screen.dart';
import 'package:inventario_v2/features/inventory/presentation/screens/product_create_screen.dart';
import 'package:inventario_v2/features/inventory/presentation/screens/product_detail_screen.dart';
import 'package:inventario_v2/features/inventory/presentation/screens/warehouse_create_screen.dart';
import 'package:inventario_v2/features/inventory/presentation/screens/warehouse_history_screen.dart';
import 'package:inventario_v2/features/inventory/presentation/screens/warehouse_inventory_screen.dart';
import 'package:inventario_v2/features/inventory/presentation/screens/warehouse_screen.dart';

import '../utils/transitions.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/create_user_screen.dart';
import '../../features/auth/presentation/screens/create_company_sreen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);
  final notifier = ref.read(authControllerProvider.notifier);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    refreshListenable: AuthNotifierListenable(ref),
    redirect: (context, state) {
      // 1. Si está cargando, esperamos
      if (authState.isLoading) return null;

      // 2. Definimos las rutas públicas
      final isGoingToSplash = state.matchedLocation == '/splash';
      final isGoingToLogin = state.matchedLocation == '/login';
      final isGoingToRegister =
          state.matchedLocation == '/create-company' ||
          state.matchedLocation == '/create-user';

      final usuario = notifier.usuarioActual;
      final estaLogueado = usuario != null;

      if (!estaLogueado) {
        if (isGoingToLogin || isGoingToRegister || isGoingToSplash) return null;
        return '/login';
      }

      if (estaLogueado) {
        if (isGoingToLogin || isGoingToRegister || isGoingToSplash) {
          return '/dashboard';
        }

        return null;
      }

      return null;
    },

    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(
        path: '/create-company',
        builder: (_, __) => const CreateCompanyScreen(),
      ),
      GoRoute(
        path: '/create-user',
        builder: (_, __) => const CreateUserScreen(),
      ),

      ShellRoute(
        builder: (context, state, child) {
          final String location = state.uri.toString();
          return MainLayout(
            location: location,
            key: ValueKey(location),
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),

          GoRoute(
            path: '/warehouse',
            builder: (context, state) => const WarehouseScreen(),
          ),
          GoRoute(
            path: '/warehouse-create',
            builder: (context, state) => const WarehouseCreateScreen(),
          ),
          GoRoute(
            path: '/warehouse-inventory',
            builder: (context, state) =>
                const WarehouseInventoryScreen(warehouseId: '1'),
          ),
          GoRoute(
            path: '/warehouse-history',
            builder: (context, state) =>
                const WarehouseHistoryScreen(warehouseId: '1'),
          ),
          GoRoute(
            path: '/movement-detail',
            builder: (context, state) =>
                const MovementDetailScreen(movementId: '1'),
          ),
          GoRoute(
            path: '/barcode-scanner',
            builder: (context, state) => const BarcodeScannerScreen(),
          ),
          GoRoute(
            path: '/product-detail',
            builder: (context, state) =>
                const ProductDetailScreen(productId: '1', warehouseId: '1'),
          ),
          GoRoute(
            path: '/product-create',
            builder: (context, state) => const ProductCreateScreen(),
          ),
          GoRoute(
            path: '/magic-camera',
            builder: (context, state) => const MagicCameraScreen(),
          ),
        ],
      ),
    ],
  );
});

class AuthNotifierListenable extends ChangeNotifier {
  final Ref ref;
  AuthNotifierListenable(this.ref) {
    ref.listen(authControllerProvider, (_, __) {
      notifyListeners();
    });
  }
}
