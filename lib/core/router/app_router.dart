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
import 'package:inventario_v2/features/assistant/presentation/screens/assistant_screen.dart';
import 'package:inventario_v2/features/report/presentation/reports_dashboard_screen.dart';
import 'package:inventario_v2/features/report/presentation/sales_report_screen.dart';
import 'package:inventario_v2/features/report/presentation/inventory_report_screen.dart';
import 'package:inventario_v2/features/report/presentation/financial_report_screen.dart';
import 'package:inventario_v2/features/report/presentation/receivables_report_screen.dart';
import 'package:inventario_v2/features/report/presentation/cash_flow_report_screen.dart';

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
import '../../features/auth/presentation/screens/user_profile_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/sync/presentation/screens/sync_status_screen.dart';
import '../../features/sync/presentation/screens/log_viewer_screen.dart';
import '../../features/auth/presentation/screens/force_password_change_screen.dart';
import '../../core/providers/supabase_provider.dart';

import '../../features/auth/presentation/screens/staff_management_screen.dart';

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
        final supabase = ref.read(supabaseClientProvider);
        final mustChangePassword = supabase.auth.currentUser?.userMetadata?['must_change_password'] == true;
        final isForcePasswordRoute = state.matchedLocation == '/force-password-change';

        if (mustChangePassword && !isForcePasswordRoute) {
          return '/force-password-change';
        }

        if (!mustChangePassword && isForcePasswordRoute) {
          return '/dashboard';
        }

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
      GoRoute(
        path: '/force-password-change',
        builder: (_, _) => const ForcePasswordChangeScreen(),
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
            path: '/profile',
            builder: (context, state) => const UserProfileScreen(),
          ),
          GoRoute(
            path: '/staff-management',
            builder: (context, state) => const StaffManagementScreen(),
          ),
          GoRoute(
            path: '/sync-status',
            builder: (context, state) => const SyncStatusScreen(),
          ),
          GoRoute(
            path: '/log-viewer',
            builder: (context, state) => const LogViewerScreen(),
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
            path: '/warehouse-inventory/:warehouseId',
            builder: (context, state) => WarehouseInventoryScreen(
              warehouseId: state.pathParameters['warehouseId']!,
            ),
          ),
          GoRoute(
            path: '/warehouse-history/:warehouseId',
            builder: (context, state) => WarehouseHistoryScreen(
              warehouseId: state.pathParameters['warehouseId']!,
            ),
          ),
          GoRoute(
            path: '/movement-detail/:movementId',
            builder: (context, state) => MovementDetailScreen(
              movementId: state.pathParameters['movementId']!,
            ),
          ),
          GoRoute(
            path: '/product-detail/:productId',
            builder: (context, state) => ProductDetailScreen(
              productId: state.pathParameters['productId']!,
              bodegaId: state.uri.queryParameters['bodegaId'],
            ),
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
            path: '/barcode-scanner',
            builder: (context, state) => BarcodeScannerScreen(
              bodegaId: state.uri.queryParameters['bodegaId'],
            ),
          ),
          GoRoute(
            path: '/batch-entry/:bodegaId',
            builder: (context, state) => WarehouseEntryScreen(
              bodegaId: state.pathParameters['bodegaId']!,
            ),
          ),
          GoRoute(
            path: '/warehouse-transfer/:bodegaId',
            builder: (context, state) => WarehouseTransferScreen(
              bodegaOrigenId: state.pathParameters['bodegaId'] ?? '',
            ),
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
            path: '/sales-detail/:saleId',
            builder: (context, state) =>
                SaleDetailScreen(saleId: state.pathParameters['saleId']!),
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
            path: '/cash-register-detail/:sessionId',
            builder: (context, state) => CashRegisterDetailScreen(
              sessionId: state.pathParameters['sessionId']!,
            ),
          ),

          // Módulo de Asistente IA
          GoRoute(
            path: '/assistant',
            builder: (context, state) => const AssistantScreen(),
          ),

          // Modulo de Reportes
          GoRoute(
            path: '/reports',
            builder: (context, state) => const ReportsDashboardScreen(),
          ),
          GoRoute(
            path: '/reports/sales',
            builder: (context, state) => const SalesReportScreen(),
          ),
          GoRoute(
            path: '/reports/inventory',
            builder: (context, state) => const InventoryReportScreen(),
          ),
          GoRoute(
            path: '/reports/financial',
            builder: (context, state) => const FinancialReportScreen(),
          ),
          GoRoute(
            path: '/reports/receivables',
            builder: (context, state) => const ReceivablesReportScreen(),
          ),
          GoRoute(
            path: '/reports/cash-history',
            builder: (context, state) => const CashFlowReportScreen(),
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
