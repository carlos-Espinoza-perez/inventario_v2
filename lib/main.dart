import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventario_v2/core/constants/app_constants.dart';
import 'package:inventario_v2/core/providers/isar_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

  final isarService = IsarService();
  await isarService.openDB();

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

      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
    );
  }
}
