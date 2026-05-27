import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventario_v2/core/router/route_observer.dart';
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
import '../../features/auth/presentation/screens/invalid_link_screen.dart';
import '../../core/providers/supabase_provider.dart';

import '../../features/auth/presentation/screens/staff_management_screen.dart';
import '../../features/auth/presentation/screens/role_management_screen.dart';
import '../../features/auth/presentation/screens/admin_hub_screen.dart';
import '../../core/router/permission_guard.dart';
import '../../core/constants/permission_codes.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    observers: const [],
    refreshListenable: AuthNotifierListenable(ref),
    redirect: (context, state) {
      final authState = ref.read(authControllerProvider);
      final notifier = ref.read(authControllerProvider.notifier);

      // 1. Definir estados y rutas
      final isLoading = authState.isLoading;
      final usuario = notifier.usuarioActual;
      final estaLogueado = usuario != null;

      final isSplash = state.matchedLocation == '/splash';
      final isLoginCallback =
          state.uri.host == 'login-callback' ||
          state.matchedLocation == '/login-callback';
      final isForcePasswordRoute =
          state.matchedLocation == '/force-password-change';

      // Agrupamos login y registro como "rutas de autenticacion"
      final isAuthRoute =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/create-company' ||
          state.matchedLocation == '/create-user' ||
          isForcePasswordRoute ||
          isLoginCallback;

      // 2. LOGICA DE ENLACES DE ERROR (Deep Link Expired)
      if (notifier.linkError != null) {
        if (state.matchedLocation != '/invalid-link') {
          return '/invalid-link';
        }
        return null; // Quedarse en la pantalla de error
      }

      // Supabase Flutter procesa el deep link internamente mediante app_links.
      // El router solo mantiene al usuario en splash mientras llega el evento signedIn.
      if (isLoginCallback) {
        return isSplash ? null : '/splash';
      }

      // El evento passwordRecovery de Supabase crea una sesion temporal valida
      // para cambiar password, aunque la sesion local aun no exista en Drift.
      if (notifier.passwordRecoveryPending) {
        return isForcePasswordRoute ? null : '/force-password-change';
      }

      // 3. LOGICA DE CARGA (Prioridad Alta)
      // Mantener las pantallas de auth estables durante acciones locales
      // como login o recuperacion; si las mandamos al splash se reconstruyen
      // y el usuario pierde lo que habia escrito.
      if (isLoading) {
        if (isAuthRoute) return null;
        if (!isSplash) return '/splash';
        return null; // Si ya esta en splash, quedarse ahi.
      }

      // 3. LOGICA NO LOGUEADO (Carga termino, no hay usuario)
      if (!estaLogueado) {
        // Si viene del Splash (termino de cargar) O intenta entrar a una ruta protegida
        // lo mandamos al Login.
        if (isSplash || !isAuthRoute) {
          return '/login';
        }
        // Si ya esta en login o registro, lo dejamos ahi.
        return null;
      }

      // 4. LOGICA LOGUEADO (Carga termino, hay usuario)
      if (estaLogueado) {
        final supabase = ref.read(supabaseClientProvider);
        final mustChangePassword =
            supabase.auth.currentUser?.userMetadata?['must_change_password'] ==
            true;

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
      GoRoute(
        path: '/invalid-link',
        builder: (_, _) => const InvalidLinkScreen(),
      ),
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
      GoRoute(
        path: '/login-callback',
        builder: (_, _) =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
      ),

      ShellRoute(
        observers: [appRouteObserver],
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
            builder: (context, state) => const PermissionGuard(
              requiredPermission: PermissionCode.staffRead,
              child: StaffManagementScreen(),
            ),
          ),
          GoRoute(
            path: '/admin',
            builder: (context, state) => const PermissionGuard(
              requiredPermission: PermissionCode.staffRead,
              child: AdminHubScreen(),
            ),
          ),
          GoRoute(
            path: '/role-management',
            builder: (context, state) => const PermissionGuard(
              requiredPermission: PermissionCode.roleRead,
              child: RoleManagementScreen(),
            ),
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
            builder: (context, state) => const PermissionGuard(
              requiredPermission: PermissionCode.warehouseRead,
              child: WarehouseScreen(),
            ),
          ),
          GoRoute(
            path: '/warehouse-create',
            builder: (context, state) => const PermissionGuard(
              requiredPermission: PermissionCode.warehouseCreate,
              child: WarehouseCreateScreen(),
            ),
          ),
          GoRoute(
            path: '/warehouse-inventory/:warehouseId',
            builder: (context, state) => PermissionGuard(
              requiredPermission: PermissionCode.warehouseRead,
              child: WarehouseInventoryScreen(
                warehouseId: state.pathParameters['warehouseId']!,
              ),
            ),
          ),
          GoRoute(
            path: '/warehouse-history/:warehouseId',
            builder: (context, state) => PermissionGuard(
              requiredPermission: PermissionCode.warehouseRead,
              child: WarehouseHistoryScreen(
                warehouseId: state.pathParameters['warehouseId']!,
              ),
            ),
          ),
          GoRoute(
            path: '/movement-detail/:movementId',
            builder: (context, state) => PermissionGuard(
              requiredPermission: PermissionCode.warehouseRead,
              child: MovementDetailScreen(
                movementId: state.pathParameters['movementId']!,
              ),
            ),
          ),
          GoRoute(
            path: '/product-detail/:productId',
            builder: (context, state) => PermissionGuard(
              requiredPermission: PermissionCode.productRead,
              child: ProductDetailScreen(
                productId: state.pathParameters['productId']!,
                bodegaId: state.uri.queryParameters['bodegaId'],
              ),
            ),
          ),
          GoRoute(
            path: '/product-create',
            builder: (context, state) => const PermissionGuard(
              requiredPermission: PermissionCode.productCreate,
              child: ProductCreateScreen(),
            ),
          ),
          GoRoute(
            path: '/magic-camera',
            builder: (context, state) => const PermissionGuard(
              requiredPermission: PermissionCode.productCreate,
              child: MagicCameraScreen(),
            ),
          ),
          GoRoute(
            path: '/barcode-scanner',
            builder: (context, state) => PermissionGuard(
              requiredPermission: PermissionCode.warehouseRead,
              child: BarcodeScannerScreen(
                bodegaId: state.uri.queryParameters['bodegaId'],
              ),
            ),
          ),
          GoRoute(
            path: '/batch-entry/:bodegaId',
            builder: (context, state) => PermissionGuard(
              requiredPermission: PermissionCode.warehouseUpdate,
              child: WarehouseEntryScreen(
                bodegaId: state.pathParameters['bodegaId']!,
              ),
            ),
          ),
          GoRoute(
            path: '/warehouse-transfer/:bodegaId',
            builder: (context, state) => PermissionGuard(
              requiredPermission: PermissionCode.warehouseUpdate,
              child: WarehouseTransferScreen(
                bodegaOrigenId: state.pathParameters['bodegaId'] ?? '',
              ),
            ),
          ),
          GoRoute(
            path: '/product-list',
            builder: (context, state) => const PermissionGuard(
              requiredPermission: PermissionCode.productRead,
              child: ProductListScreen(),
            ),
          ),

          // Modulo de POS
          GoRoute(
            path: '/pos',
            builder: (context, state) => const PermissionGuard(
              requiredPermission: PermissionCode.saleCreate,
              child: PosScreen(),
            ),
          ),
          GoRoute(
            path: '/sales',
            builder: (context, state) => const PermissionGuard(
              requiredPermission: PermissionCode.saleRead,
              child: SalesDashboardScreen(),
            ),
          ),
          GoRoute(
            path: '/sales-detail/:saleId',
            builder: (context, state) => PermissionGuard(
              requiredPermission: PermissionCode.saleRead,
              child: SaleDetailScreen(saleId: state.pathParameters['saleId']!),
            ),
          ),
          GoRoute(
            path: '/cash-register',
            builder: (context, state) => const PermissionGuard(
              requiredPermission: PermissionCode.saleCreate,
              child: CashRegisterScreen(),
            ),
          ),
          GoRoute(
            path: '/cash-register-history',
            builder: (context, state) => const PermissionGuard(
              requiredPermission: PermissionCode.saleRead,
              child: CashRegisterHistoryScreen(),
            ),
          ),
          GoRoute(
            path: '/cash-register-detail/:sessionId',
            builder: (context, state) => PermissionGuard(
              requiredPermission: PermissionCode.saleRead,
              child: CashRegisterDetailScreen(
                sessionId: state.pathParameters['sessionId']!,
              ),
            ),
          ),

          // Modulo de Asistente IA
          GoRoute(
            path: '/assistant',
            builder: (context, state) => const PermissionGuard(
              requiredPermission: PermissionCode.dashboardRead,
              child: AssistantScreen(),
            ),
          ),

          // Modulo de Reportes
          GoRoute(
            path: '/reports',
            builder: (context, state) => const PermissionGuard(
              requiredPermission: PermissionCode.reportRead,
              child: ReportsDashboardScreen(),
            ),
          ),
          GoRoute(
            path: '/reports/sales',
            builder: (context, state) => const PermissionGuard(
              requiredPermission: PermissionCode.reportRead,
              child: SalesReportScreen(),
            ),
          ),
          GoRoute(
            path: '/reports/inventory',
            builder: (context, state) => const PermissionGuard(
              requiredPermission: PermissionCode.reportRead,
              child: InventoryReportScreen(),
            ),
          ),
          GoRoute(
            path: '/reports/financial',
            builder: (context, state) => const PermissionGuard(
              requiredPermission: PermissionCode.reportRead,
              child: FinancialReportScreen(),
            ),
          ),
          GoRoute(
            path: '/reports/receivables',
            builder: (context, state) => const PermissionGuard(
              requiredPermission: PermissionCode.reportRead,
              child: ReceivablesReportScreen(),
            ),
          ),
          GoRoute(
            path: '/reports/cash-history',
            builder: (context, state) => const PermissionGuard(
              requiredPermission: PermissionCode.reportRead,
              child: CashFlowReportScreen(),
            ),
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
