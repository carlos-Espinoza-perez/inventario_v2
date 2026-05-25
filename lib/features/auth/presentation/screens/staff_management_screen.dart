import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inventario_v2/core/constants/permission_codes.dart';
import 'package:inventario_v2/core/db/app_database.dart';
import 'package:inventario_v2/core/db/models/auth_admin_models.dart';
import 'package:inventario_v2/core/providers/app_bar_provider.dart';
import 'package:inventario_v2/core/providers/drift_provider.dart';
import 'package:inventario_v2/core/providers/supabase_provider.dart';
import 'package:inventario_v2/features/auth/data/repositories/role_access_repository.dart';
import 'package:inventario_v2/features/auth/data/repositories/staff_account_repository.dart';
import 'package:inventario_v2/features/auth/presentation/providers/auth_provider.dart';
import 'package:inventario_v2/features/auth/presentation/providers/authorization_provider.dart';

final staffAdminDataProvider = FutureProvider.autoDispose<StaffAdminDataDrift>((
  ref,
) async {
  final auth = ref.read(authControllerProvider.notifier);
  final user = auth.usuarioActual ?? await auth.getUser();
  if (user == null) {
    return const StaffAdminDataDrift(
      users: [],
      roles: [],
      warehouses: [],
      assignments: [],
    );
  }

  final db = ref.watch(driftDatabaseProvider);
  await RoleAccessRepository(db).ensureBaseRolesForUser(user);
  return db.authDao.getStaffAdminData(user.empresaId);
});

class StaffManagementScreen extends ConsumerStatefulWidget {
  const StaffManagementScreen({super.key});

  @override
  ConsumerState<StaffManagementScreen> createState() =>
      _StaffManagementScreenState();
}

class _StaffManagementScreenState extends ConsumerState<StaffManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(appBarProvider.notifier)
          .setOptions(
            title: 'Personal y accesos',
            subtitle: 'Usuarios, roles y bodegas asignadas',
            showBackButton: true,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final dataAsync = ref.watch(staffAdminDataProvider);
    final authorization = ref.watch(authorizationStateProvider).value;

    final canUpdate = authorization?.can(PermissionCode.staffUpdate) ?? false;
    final canDelete = authorization?.can(PermissionCode.staffDelete) ?? false;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => dataAsync.whenData(_showUserDialog),
        backgroundColor: Colors.cyan.shade800,
        icon: const Icon(Icons.person_add_alt_1, color: Colors.white),
        label: const Text(
          'Nuevo personal',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: dataAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (data) {
          final roleById = {for (final role in data.roles) role.id: role};
          final assignmentsByUser = <String, List<BodegasUsuario>>{};
          for (final assignment in data.assignments) {
            assignmentsByUser
                .putIfAbsent(assignment.usuarioId, () => [])
                .add(assignment);
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _SummaryCard(
                totalUsers: data.users.length,
                totalRoles: data.roles.length,
                totalWarehouses: data.warehouses.length,
                onManageRoles:
                    (authorization?.can(PermissionCode.roleRead) ?? false)
                    ? () => context.push('/role-management')
                    : null,
              ),
              const SizedBox(height: 16),
              const Text(
                'Personal registrado',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              if (data.users.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('Aun no hay personal adicional registrado.'),
                  ),
                ),
              ...data.users.map((user) {
                final role = roleById[user.rolId];
                final warehouseNames =
                    assignmentsByUser[user.id]
                        ?.map(
                          (assignment) => data.warehouses
                              .firstWhere(
                                (warehouse) =>
                                    warehouse.id == assignment.bodegaId,
                                orElse: () => Bodega(
                                  id: '',
                                  empresaId: '',
                                  nombre: 'Sin bodega',
                                  direccion: null,
                                  descripcion: null,
                                  esPuntoVenta: false,
                                  usuarioRegistroId: null,
                                  estado: true,
                                  createdAt: DateTime.now(),
                                  updatedAt: DateTime.now(),
                                  syncStatus: 'synced',
                                  fechaEliminacion: null,
                                ),
                              )
                              .nombre,
                        )
                        .where((name) => name.isNotEmpty)
                        .join(', ') ??
                    'Sin bodegas';

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: Colors.cyan.shade50,
                      child: Text(
                        user.nombreCompleto.isNotEmpty
                            ? user.nombreCompleto[0].toUpperCase()
                            : '?',
                        style: TextStyle(color: Colors.cyan.shade900),
                      ),
                    ),
                    title: Text(user.nombreCompleto),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        '${user.correo ?? 'Sin correo'}\n${role?.nombre ?? 'Sin rol'}\n$warehouseNames',
                      ),
                    ),
                    isThreeLine: true,
                    trailing: Wrap(
                      spacing: 4,
                      children: [
                        if (canUpdate && user.id != authorization?.user?.id)
                          IconButton(
                            icon: const Icon(Icons.lock_reset_outlined),
                            tooltip: 'Resetear contraseÃ±a',
                            onPressed: () => _resetPassword(user),
                          ),
                        if (canUpdate &&
                            user.passwordHash == null &&
                            user.correo != null)
                          IconButton(
                            icon: const Icon(Icons.email_outlined),
                            tooltip: 'Re-enviar invitaciÃ³n',
                            onPressed: () => _resendInvitation(user),
                          ),
                        if (canUpdate)
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            tooltip: 'Editar personal',
                            onPressed: () =>
                                _showUserDialog(data, existing: user),
                          ),
                        if (canDelete && user.id != authorization?.user?.id)
                          IconButton(
                            icon: const Icon(Icons.person_remove_outlined),
                            tooltip: 'Desactivar personal',
                            onPressed: () => _disableUser(user),
                          ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showUserDialog(
    StaffAdminDataDrift data, {
    Usuario? existing,
  }) async {
    final nameCtrl = TextEditingController(
      text: existing?.nombreCompleto ?? '',
    );
    final emailCtrl = TextEditingController(text: existing?.correo ?? '');
    String? selectedRoleId =
        existing?.rolId ?? (data.roles.isNotEmpty ? data.roles.first.id : null);
    final selectedWarehouses = data.assignments
        .where((assignment) => assignment.usuarioId == existing?.id)
        .map((assignment) => assignment.bodegaId)
        .toSet();

    final formKey = GlobalKey<FormState>();
    String? emailErrorText;
    bool isSaving = false;

    await showDialog<void>(
      context: context,
      barrierDismissible: false, // Prevent dismissing while saving
      builder: (ctx) => StatefulBuilder(
        builder: (context, setLocalState) => AlertDialog(
          title: Text(existing == null ? 'Nuevo personal' : 'Editar personal'),
          content: SizedBox(
            width: 460,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nombre completo',
                      ),
                      enabled: !isSaving,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      textCapitalization: TextCapitalization.none,
                      decoration: InputDecoration(
                        labelText: 'Correo de acceso',
                        helperText: existing == null
                            ? 'Se enviarÃ¡ una invitaciÃ³n a este correo.'
                            : null,
                        errorText: emailErrorText,
                      ),
                      enabled: existing == null && !isSaving,
                      validator: (value) {
                        final normalizedEmail = (value ?? '').trim();
                        if (existing == null && normalizedEmail.isEmpty) {
                          return 'El correo es obligatorio.';
                        }
                        if (normalizedEmail.isNotEmpty &&
                            !_isValidEmail(normalizedEmail)) {
                          return 'Ingresa un correo válido.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedRoleId,
                      decoration: const InputDecoration(labelText: 'Rol'),
                      items: data.roles
                          .map(
                            (role) => DropdownMenuItem<String>(
                              value: role.id,
                              child: Text(role.nombre),
                            ),
                          )
                          .toList(),
                      onChanged: isSaving
                          ? null
                          : (value) {
                              setLocalState(() => selectedRoleId = value);
                            },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Bodegas asignadas',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...data.warehouses.map(
                      (warehouse) => CheckboxListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        value: selectedWarehouses.contains(warehouse.id),
                        title: Text(warehouse.nombre),
                        enabled: !isSaving,
                        onChanged: isSaving
                            ? null
                            : (checked) {
                                setLocalState(() {
                                  if (checked == true) {
                                    selectedWarehouses.add(warehouse.id);
                                  } else {
                                    selectedWarehouses.remove(warehouse.id);
                                  }
                                });
                              },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            if (!isSaving)
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar'),
              ),
            ElevatedButton(
              onPressed: isSaving
                  ? null
                  : () async {
                      final normalizedEmail = emailCtrl.text.trim();
                      emailCtrl.value = emailCtrl.value.copyWith(
                        text: normalizedEmail,
                        selection: TextSelection.collapsed(
                          offset: normalizedEmail.length,
                        ),
                      );
                      final isValid = formKey.currentState?.validate() ?? false;
                      if (!isValid) return;

                      setLocalState(() {
                        isSaving = true;
                        emailErrorText = null;
                      });

                      final saveError = await _saveUser(
                        existing: existing,
                        name: nameCtrl.text.trim(),
                        email: normalizedEmail,
                        roleId: selectedRoleId,
                        warehouseIds: selectedWarehouses,
                      );

                      if (saveError != null &&
                          saveError.toLowerCase().contains('correo')) {
                        setLocalState(() {
                          emailErrorText = 'Ingresa un correo válido.';
                          isSaving = false;
                        });
                        return;
                      }

                      if (ctx.mounted) Navigator.pop(ctx);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyan.shade800,
                foregroundColor: Colors.white,
              ),
              child: isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  bool _isValidEmail(String value) {
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return emailRegex.hasMatch(value);
  }

  Future<String?> _saveUser({
    required Usuario? existing,
    required String name,
    required String email,
    required String? roleId,
    required Set<String> warehouseIds,
  }) async {
    if (name.isEmpty || roleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nombre y rol son obligatorios')),
      );
      return null;
    }

    if (existing == null && email.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('El correo es obligatorio')));
      return null;
    }

    final auth = ref.read(authControllerProvider.notifier);
    final currentUser = auth.usuarioActual ?? await auth.getUser();
    if (currentUser == null) return null;

    final db = ref.read(driftDatabaseProvider);
    try {
      if (existing == null) {
        final repository = StaffAccountRepository(
          ref.read(supabaseClientProvider),
          db,
        );
        await repository.createStaffAccount(
          currentUser: currentUser,
          nombre: name,
          correo: email,
          rolId: roleId,
          bodegaIds: warehouseIds,
        );
      } else {
        await db.authDao.updateStaffUser(
          userId: existing.id,
          empresaId: currentUser.empresaId,
          roleId: roleId,
          nombre: name,
          correo: email,
        );
        await db.authDao.replaceUserWarehouseAssignments(
          userId: existing.id,
          currentUserId: currentUser.serverId,
          warehouseIds: warehouseIds,
        );
      }

      ref.invalidate(staffAdminDataProvider);
      ref.invalidate(authorizationStateProvider);
      if (!mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            existing == null
                ? 'Personal invitado correctamente'
                : 'Personal actualizado correctamente',
          ),
        ),
      );
      return null;
    } catch (error) {
      if (!mounted) return error.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          backgroundColor: Colors.red.shade700,
        ),
      );
      return error.toString();
    }
  }

  Future<void> _resetPassword(Usuario user) async {
    // DiÃ¡logo de confirmaciÃ³n
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Resetear contraseÃ±a'),
        content: Text(
          'Â¿Resetear la contraseÃ±a de ${user.nombreCompleto}?\n\n'
          'Se generarÃ¡ una contraseÃ±a temporal que deberÃ¡s comunicarle. '
          'Al iniciar sesiÃ³n, se le pedirÃ¡ que la cambie.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade700,
              foregroundColor: Colors.white,
            ),
            child: const Text('Resetear'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final auth = ref.read(authControllerProvider.notifier);
    final currentUser = auth.usuarioActual ?? await auth.getUser();
    if (currentUser == null || !mounted) return;

    try {
      final repository = StaffAccountRepository(
        ref.read(supabaseClientProvider),
        ref.read(driftDatabaseProvider),
      );

      final tempPassword = await repository.resetStaffPassword(
        targetUserId: user.id,
        empresaId: currentUser.empresaId,
      );

      if (!mounted) return;

      // Mostrar diÃ¡logo con la contraseÃ±a temporal
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green.shade600),
              const SizedBox(width: 10),
              const Expanded(child: Text('ContraseÃ±a reseteada')),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'La nueva contraseÃ±a temporal de ${user.nombreCompleto} es:',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  children: [
                    Text(
                      tempPassword,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        fontFamily: 'monospace',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () async {
                        await Clipboard.setData(
                          ClipboardData(text: tempPassword),
                        );
                        if (!ctx.mounted) return;
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          const SnackBar(
                            content: Text('ContraseÃ±a temporal copiada'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: const Icon(Icons.copy, size: 18),
                      label: const Text('Copiar contraseÃ±a'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.amber.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Comunica esta contraseÃ±a al usuario. '
                        'Se le pedirÃ¡ cambiarla al iniciar sesiÃ³n.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyan.shade800,
                foregroundColor: Colors.white,
              ),
              child: const Text('Entendido'),
            ),
          ],
        ),
      );
      return;
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          backgroundColor: Colors.red.shade700,
        ),
      );
      return;
    }
  }

  Future<void> _resendInvitation(Usuario user) async {
    final dataAsync = ref.read(staffAdminDataProvider);
    final data = dataAsync.value;
    if (data == null) return;

    final auth = ref.read(authControllerProvider.notifier);
    final currentUser = auth.usuarioActual ?? await auth.getUser();
    if (currentUser == null || !mounted) return;

    final assignments = data.assignments
        .where((a) => a.usuarioId == user.id)
        .map((a) => a.bodegaId)
        .toSet();

    try {
      final repository = StaffAccountRepository(
        ref.read(supabaseClientProvider),
        ref.read(driftDatabaseProvider),
      );

      await repository.resendInvitation(
        correo: user.correo!,
        empresaId: currentUser.empresaId,
        adminUserId: currentUser.serverId,
        nombre: user.nombreCompleto,
        rolId: user.rolId,
        bodegaIds: assignments,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('InvitaciÃ³n re-enviada a ${user.correo}'),
          backgroundColor: Colors.green.shade600,
        ),
      );
      return;
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          backgroundColor: Colors.red.shade700,
        ),
      );
      return;
    }
  }

  Future<void> _disableUser(Usuario user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Desactivar personal'),
        content: Text('Se desactivara a ${user.nombreCompleto}.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Desactivar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final db = ref.read(driftDatabaseProvider);
    await db.authDao.deactivateUser(user.id);
    ref.invalidate(staffAdminDataProvider);
  }
}

class _SummaryCard extends StatelessWidget {
  final int totalUsers;
  final int totalRoles;
  final int totalWarehouses;
  final VoidCallback? onManageRoles;

  const _SummaryCard({
    required this.totalUsers,
    required this.totalRoles,
    required this.totalWarehouses,
    required this.onManageRoles,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.cyan.shade50,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.groups_2_outlined,
                  color: Colors.cyan.shade800,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Administra quien entra al sistema, que puede hacer y en cuales bodegas trabaja.',
                  style: TextStyle(color: Colors.grey.shade700, height: 1.35),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _StatChip(label: '$totalUsers personas'),
              _StatChip(label: '$totalRoles roles'),
              _StatChip(label: '$totalWarehouses bodegas'),
            ],
          ),
          if (onManageRoles != null) ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onManageRoles,
              icon: const Icon(Icons.admin_panel_settings_outlined),
              label: const Text('Gestionar roles'),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;

  const _StatChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}
