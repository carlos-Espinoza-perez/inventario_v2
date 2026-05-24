import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inventario_v2/core/presentation/widgets/custom_card.dart';
import 'package:inventario_v2/core/providers/app_bar_provider.dart';
import 'package:inventario_v2/core/constants/permission_codes.dart';
import 'package:inventario_v2/core/providers/supabase_provider.dart';
import 'package:inventario_v2/features/auth/presentation/providers/auth_provider.dart';
import 'package:inventario_v2/features/auth/presentation/providers/authorization_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserProfileScreen extends ConsumerStatefulWidget {
  const UserProfileScreen({super.key});

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(appBarProvider.notifier)
          .setOptions(title: "Mi Perfil", showBackButton: true, actions: []);
    });
  }

  @override
  Widget build(BuildContext context) {
    final usuario = ref.watch(authControllerProvider.notifier).usuarioActual;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue.shade100,
              child: const Icon(Icons.person, size: 60, color: Colors.blue),
            ),
            const SizedBox(height: 20),
            Text(
              usuario?.nombreCompleto ?? 'Usuario Desconocido',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              usuario?.correo ?? 'Sin correo',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            CustomCard(
              padding: const EdgeInsets.all(16),
              onTap: () => context.push('/sync-status'),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.cloud_sync, color: Colors.teal.shade700, size: 28),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Estado de Sincronización",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Monitorear contadores locales y ver logs del sistema en vivo",
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
                ],
              ),
            ),
            const SizedBox(height: 16),
            CustomCard(
              padding: const EdgeInsets.all(16),
              onTap: () => _showChangePasswordDialog(context, ref),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.lock_reset, color: Colors.orange.shade700, size: 28),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Cambiar Contraseña",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Actualizar tu contraseña de acceso al sistema",
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
                ],
              ),
            ),
            Builder(
              builder: (context) {
                final authState = ref.watch(authorizationStateProvider).value;
                final canSeeAdmin = authState != null &&
                    (authState.can(PermissionCode.staffRead) ||
                     authState.can(PermissionCode.roleRead) ||
                     authState.can(PermissionCode.warehouseRead) ||
                     authState.isAdmin);

                if (!canSeeAdmin) return const SizedBox.shrink();

                return Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: CustomCard(
                    padding: const EdgeInsets.all(16),
                    onTap: () => context.push('/admin'),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.cyan.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.settings_outlined, color: Colors.cyan.shade700, size: 28),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Administración",
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Personal, roles, permisos, bodegas y herramientas del sistema",
                                style: TextStyle(fontSize: 12, color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await ref.read(authControllerProvider.notifier).logout();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade50,
                  foregroundColor: Colors.red.shade700,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.red.shade200),
                  ),
                ),
                icon: const Icon(Icons.logout),
                label: const Text(
                  "CERRAR SESIÓN",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _showChangePasswordDialog(BuildContext context, WidgetRef ref) {
  final passwordCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool obscurePass = true;
  bool obscureConfirm = true;

  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => StatefulBuilder(
      builder: (context, setLocalState) => AlertDialog(
        title: const Text('Cambiar Contraseña'),
        content: SizedBox(
          width: 400,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Ingresa tu nueva contraseña. Debe tener al menos 6 caracteres.',
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: passwordCtrl,
                  obscureText: obscurePass,
                  enabled: !isLoading,
                  decoration: InputDecoration(
                    labelText: 'Nueva contraseña',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(obscurePass ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setLocalState(() => obscurePass = !obscurePass),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return 'La contraseña debe tener al menos 6 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: confirmCtrl,
                  obscureText: obscureConfirm,
                  enabled: !isLoading,
                  decoration: InputDecoration(
                    labelText: 'Confirmar contraseña',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(obscureConfirm ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setLocalState(() => obscureConfirm = !obscureConfirm),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (value) {
                    if (value != passwordCtrl.text) {
                      return 'Las contraseñas no coinciden';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          if (!isLoading)
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
          ElevatedButton(
            onPressed: isLoading
                ? null
                : () async {
                    if (!formKey.currentState!.validate()) return;
                    setLocalState(() => isLoading = true);

                    try {
                      final supabase = ref.read(supabaseClientProvider);
                      await supabase.auth.updateUser(
                        UserAttributes(password: passwordCtrl.text),
                      );

                      if (ctx.mounted) Navigator.pop(ctx);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Contraseña actualizada correctamente'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } on AuthException catch (e) {
                      setLocalState(() => isLoading = false);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: ${e.message}'),
                            backgroundColor: Colors.red.shade700,
                          ),
                        );
                      }
                    } catch (e) {
                      setLocalState(() => isLoading = false);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Error inesperado al cambiar contraseña'),
                            backgroundColor: Colors.red.shade700,
                          ),
                        );
                      }
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade800,
              foregroundColor: Colors.white,
            ),
            child: isLoading
                ? const SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Actualizar'),
          ),
        ],
      ),
    ),
  );
}
