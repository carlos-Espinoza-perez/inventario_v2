import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventario_v2/core/constants/permission_codes.dart';
import 'package:inventario_v2/core/db/app_database.dart';
import 'package:inventario_v2/core/db/models/auth_admin_models.dart';
import 'package:inventario_v2/core/presentation/mixins/app_bar_config_mixin.dart';
import 'package:inventario_v2/core/providers/app_bar_provider.dart';
import 'package:inventario_v2/core/providers/drift_provider.dart';
import 'package:inventario_v2/features/auth/data/repositories/role_access_repository.dart';
import 'package:inventario_v2/features/auth/presentation/providers/auth_provider.dart';
import 'package:inventario_v2/features/auth/presentation/providers/authorization_provider.dart';

final roleManagementDataProvider =
    FutureProvider.autoDispose<RoleManagementDataDrift>((ref) async {
      final auth = ref.read(authControllerProvider.notifier);
      final user = auth.usuarioActual ?? await auth.getUser();
      if (user == null) {
        return const RoleManagementDataDrift(roles: [], accesses: []);
      }

      final db = ref.watch(driftDatabaseProvider);
      await RoleAccessRepository(db).ensureBaseRolesForUser(user);
      return db.authDao.getRoleManagementData(user.empresaId);
    });

class RoleManagementScreen extends ConsumerStatefulWidget {
  const RoleManagementScreen({super.key});

  @override
  ConsumerState<RoleManagementScreen> createState() =>
      _RoleManagementScreenState();
}

class _RoleManagementScreenState extends ConsumerState<RoleManagementScreen>
    with AppBarConfigMixin {
  @override
  void configureAppBar() {
    ref.read(appBarProvider.notifier).setOptions(
      title: 'Roles y permisos',
      subtitle: 'Controla el acceso por pantalla y accion',
      showBackButton: true,
    );
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(configureAppBar);
  }

  @override
  Widget build(BuildContext context) {
    final authorization = ref.watch(authorizationStateProvider).value;
    final dataAsync = ref.watch(roleManagementDataProvider);
    final canCreate = authorization?.can(PermissionCode.roleCreate) ?? false;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      floatingActionButton: canCreate
          ? FloatingActionButton.extended(
              onPressed: () => _showRoleDialog(),
              backgroundColor: Colors.cyan.shade800,
              icon: const Icon(
                Icons.admin_panel_settings_outlined,
                color: Colors.white,
              ),
              label: const Text(
                'Nuevo rol',
                style: TextStyle(color: Colors.white),
              ),
            )
          : null,
      body: dataAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (data) {
          final accessByRole = <String, Set<String>>{};
          for (final access in data.accesses) {
            accessByRole.putIfAbsent(access.rolId, () => <String>{}).add(
              access.codigoAcceso,
            );
          }

          if (data.roles.isEmpty) {
            return const Center(child: Text('No hay roles registrados.'));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.cyan.shade50,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.verified_user_outlined,
                        color: Colors.cyan.shade800,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'Cada rol puede tener permisos distintos para ver, crear, editar o borrar dentro del sistema.',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ...data.roles.map(
                (role) => _RoleCard(
                  role: role,
                  enabledCodes: accessByRole[role.id] ?? <String>{},
                  canEdit:
                      authorization?.can(PermissionCode.roleUpdate) ?? false,
                  canDelete:
                      authorization?.can(PermissionCode.roleDelete) ?? false,
                  onEdit: () => _showRoleDialog(role: role),
                  onDelete: role.userAdmin ? null : () => _deleteRole(role),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showRoleDialog({Role? role}) async {
    final nameCtrl = TextEditingController(text: role?.nombre ?? '');
    final selectedCodes = <String>{
      ...(role == null ? <String>{} : await _loadPermissions(role.id)),
    };
    var isAdmin = role?.userAdmin ?? false;

    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setLocalState) => AlertDialog(
          title: Text(role == null ? 'Nuevo rol' : 'Editar rol'),
          content: SizedBox(
            width: 560,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del rol',
                    ),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: isAdmin,
                    title: const Text('Administrador'),
                    subtitle: const Text(
                      'Un rol administrador tiene acceso total al sistema.',
                    ),
                    onChanged: (value) {
                      setLocalState(() {
                        isAdmin = value;
                        if (isAdmin) {
                          selectedCodes
                            ..clear()
                            ..addAll(adminDefaultPermissionCodes);
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  ...permissionSections.map(
                    (section) => Card(
                      elevation: 0,
                      color: Colors.grey.shade50,
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  section.icon,
                                  size: 18,
                                  color: Colors.cyan.shade800,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  section.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ...section.permissions.map(
                              (permission) => CheckboxListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                value: selectedCodes.contains(permission.code),
                                title: Text(permission.label),
                                subtitle: Text(permission.description),
                                onChanged: isAdmin
                                    ? null
                                    : (checked) {
                                        setLocalState(() {
                                          if (checked == true) {
                                            selectedCodes.add(permission.code);
                                          } else {
                                            selectedCodes.remove(permission.code);
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
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                await _saveRole(
                  existing: role,
                  name: nameCtrl.text.trim(),
                  isAdmin: isAdmin,
                  selectedCodes: isAdmin
                      ? adminDefaultPermissionCodes.toSet()
                      : selectedCodes,
                );
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyan.shade800,
                foregroundColor: Colors.white,
              ),
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<Set<String>> _loadPermissions(String roleId) async {
    final db = ref.read(driftDatabaseProvider);
    return db.authDao.getRolePermissionCodes(roleId);
  }

  Future<void> _saveRole({
    required Role? existing,
    required String name,
    required bool isAdmin,
    required Set<String> selectedCodes,
  }) async {
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El nombre del rol es obligatorio')),
      );
      return;
    }

    final auth = ref.read(authControllerProvider.notifier);
    final user = auth.usuarioActual ?? await auth.getUser();
    if (user == null) return;

    final db = ref.read(driftDatabaseProvider);
    final duplicated = await db.authDao.findActiveRoleByName(
      empresaId: user.empresaId,
      name: name,
      excludeRoleId: existing?.id,
    );
    if (duplicated != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ya existe un rol con ese nombre')),
      );
      return;
    }

    final role = await db.authDao.upsertRoleForEmpresa(
      empresaId: user.empresaId,
      currentUserId: user.serverId,
      roleId: existing?.id,
      name: name,
      isAdmin: isAdmin,
    );

    await RoleAccessRepository(db).syncRolePermissions(
      roleId: role.id,
      codes: selectedCodes,
      currentUserId: user.serverId,
    );

    ref.invalidate(roleManagementDataProvider);
    ref.invalidate(authorizationStateProvider);
  }

  Future<void> _deleteRole(Role role) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Desactivar rol'),
        content: Text('Se desactivara el rol "${role.nombre}".'),
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
    await db.authDao.deactivateRole(role.id);
    ref.invalidate(roleManagementDataProvider);
  }
}

class _RoleCard extends StatelessWidget {
  final Role role;
  final Set<String> enabledCodes;
  final bool canEdit;
  final bool canDelete;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;

  const _RoleCard({
    required this.role,
    required this.enabledCodes,
    required this.canEdit,
    required this.canDelete,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        role.nombre,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        role.userAdmin
                            ? 'Administrador con acceso total'
                            : '${enabledCodes.length} permisos activos',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                if (canEdit)
                  IconButton(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined),
                    tooltip: 'Editar rol',
                  ),
                if (canDelete && onDelete != null)
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Desactivar rol',
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: role.userAdmin
                  ? [
                      Chip(
                        label: const Text('Acceso total'),
                        backgroundColor: Colors.cyan.shade50,
                        side: BorderSide(color: Colors.cyan.shade100),
                      ),
                    ]
                  : enabledCodes
                        .map(
                          (code) => Chip(
                            label: Text(code),
                            backgroundColor: Colors.grey.shade100,
                            side: BorderSide(color: Colors.grey.shade200),
                          ),
                        )
                        .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
