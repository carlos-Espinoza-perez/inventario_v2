import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventario_v2/core/presentation/widgets/main_layout.dart';
import 'package:inventario_v2/features/inventory/presentation/screens/barcode_scanner_screen.dart';
import 'package:inventario_v2/features/inventory/presentation/screens/magic_camera_screen.dart';
import 'package:inventario_v2/features/inventory/presentation/screens/movement_detail_screen.dart';
import 'package:inventario_v2/features/inventory/presentation/screens/product_create_screen.dart';
import 'package:inventario_v2/features/inventory/presentation/screens/product_detail_screen.dart';
import 'package:inventario_v2/features/inventory/presentation/screens/product_list_screen.dart';
import 'package:inventario_v2/features/inventory/presentation/screens/warehouse_create_screen.dart';
import 'package:inventario_v2/features/inventory/presentation/screens/warehouse_entry_screen.dart';
import 'package:inventario_v2/features/inventory/presentation/screens/warehouse_history_screen.dart';
import 'package:inventario_v2/features/inventory/presentation/screens/warehouse_inventory_screen.dart';
import 'package:inventario_v2/features/inventory/presentation/screens/warehouse_screen.dart';
import 'package:inventario_v2/features/inventory/presentation/screens/warehouse_transfer_screen.dart';
import 'package:inventario_v2/features/report/presentation/reports_dashboard_screen.dart';
import 'package:inventario_v2/features/sales/presentation/cash_register_detail_screen.dart';
import 'package:inventario_v2/features/sales/presentation/cash_register_history_screen.dart';
import 'package:inventario_v2/features/sales/presentation/cash_register_screen.dart';
import 'package:inventario_v2/features/sales/presentation/pos_screen.dart';
import 'package:inventario_v2/features/sales/presentation/sale_detail_screen.dart';
import 'package:inventario_v2/features/sales/presentation/sales_dashboard_screen.dart';

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
      // 1. Definir estados y rutas
      final isLoading = authState.isLoading;
      final usuario = notifier.usuarioActual;
      final estaLogueado = usuario != null;

      final isSplash = state.matchedLocation == '/splash';

      // Agrupamos login y registro como "rutas de autenticación"
      final isAuthRoute =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/create-company' ||
          state.matchedLocation == '/create-user';

      // 2. LÓGICA DE CARGA (Prioridad Alta)
      // Si está cargando, DEBE estar en el splash.
      if (isLoading) {
        if (!isSplash) return '/splash';
        return null; // Si ya está en splash, quedarse ahí.
      }

      // 3. LÓGICA NO LOGUEADO (Carga terminó, no hay usuario)
      if (!estaLogueado) {
        // Si viene del Splash (terminó de cargar) O intenta entrar a una ruta protegida
        // lo mandamos al Login.
        if (isSplash || !isAuthRoute) {
          return '/login';
        }
        // Si ya está en login o registro, lo dejamos ahí.
        return null;
      }

      // 4. LÓGICA LOGUEADO (Carga terminó, hay usuario)
      if (estaLogueado) {
        // Si intenta ver el splash o el login estando ya autenticado,
        // lo mandamos al Dashboard.
        if (isSplash || isAuthRoute) {
          return '/dashboard';
        }
        // Dejarlo navegar a cualquier otra ruta protegida.
        return null;
      }

      return null;
    },

    routes: [
      GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(
        path: '/create-company',
        builder: (_, _) => const CreateCompanyScreen(),
      ),
      GoRoute(
        path: '/create-user',
        builder: (_, _) => const CreateUserScreen(),
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
          GoRoute(
            path: '/batch-entry/:bodegaId',
            builder: (context, state) => WarehouseEntryScreen(
              bodegaId: state.pathParameters['bodegaId']!,
            ),
          ),
          GoRoute(
            path: '/warehouse-transfer',
            builder: (context, state) => const WarehouseTransferScreen(),
          ),
          GoRoute(
            path: '/product-list',
            builder: (context, state) => const ProductListScreen(),
          ),

          // Modulo de POS
          GoRoute(path: '/pos', builder: (context, state) => const PosScreen()),
          GoRoute(
            path: '/sales',
            builder: (context, state) => const SalesDashboardScreen(),
          ),
          GoRoute(
            path: '/sales-detail',
            builder: (context, state) => const SaleDetailScreen(saleId: ''),
          ),
          GoRoute(
            path: '/cash-register',
            builder: (context, state) => const CashRegisterScreen(),
          ),
          GoRoute(
            path: '/cash-register-history',
            builder: (context, state) => const CashRegisterHistoryScreen(),
          ),
          GoRoute(
            path: '/cash-register-detail',
            builder: (context, state) =>
                const CashRegisterDetailScreen(sessionId: ''),
          ),

          // Modulo de Reportes
          GoRoute(
            path: '/reports',
            builder: (context, state) => const ReportsDashboardScreen(),
          ),
        ],
      ),
    ],
  );
});

class AuthNotifierListenable extends ChangeNotifier {
  final Ref ref;
  AuthNotifierListenable(this.ref) {
    ref.listen(authControllerProvider, (_, _) {
      notifyListeners();
    });
  }
}
