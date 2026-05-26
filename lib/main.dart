import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:inventario_v2/core/constants/app_constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/services/app_logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppLogger().init();
  AppLogger.info('=== Aplicación Iniciada en main() ===');

  // Cargar variables de entorno
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.implicit,
    ),
  );

  final packageInfo = await PackageInfo.fromPlatform();
  AppLogger.info(
    '=== App iniciada | v${packageInfo.version}+${packageInfo.buildNumber} ===',
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appRouter = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Inventario V2',
      debugShowCheckedModeBanner: false,

      routerConfig: appRouter,

      theme: AppTheme.lightTheme,
    );
  }
}
