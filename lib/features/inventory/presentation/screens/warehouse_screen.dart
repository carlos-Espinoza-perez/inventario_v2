import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' hide Column; // Drift for queries
import 'package:inventario_v2/core/constants/permission_codes.dart';
import 'package:inventario_v2/core/providers/drift_provider.dart';
import 'package:inventario_v2/features/auth/presentation/providers/auth_provider.dart';
import 'package:inventario_v2/features/auth/presentation/providers/authorization_provider.dart';
import 'package:inventario_v2/core/providers/app_bar_provider.dart';
import 'package:inventario_v2/core/db/app_database.dart';
import 'package:inventario_v2/features/inventory/data/providers/bodega_provider.dart';
import 'package:inventario_v2/features/inventory/presentation/widgets/warehouse_item.dart';

class WarehouseScreen extends ConsumerStatefulWidget {
  const WarehouseScreen({super.key});

  @override
  ConsumerState<WarehouseScreen> createState() => _WarehouseScreenState();
}

class _WarehouseScreenState extends ConsumerState<WarehouseScreen> {
  @override
  Widget build(BuildContext context) {
    // Configurar el título del AppBar cada vez que se renderiza
    Future.microtask(() {
      ref
          .read(appBarProvider.notifier)
          .setOptions(
            title: "Bodegas",
            subtitle: "Gestión de Almacenes",
            showBackButton: true,
            actions: [],
          );
    });

    // 1. Escuchamos la lista de bodegas
    final bodegasAsync = ref.watch(bodegaListProvider);
    final authorization = ref.watch(authorizationStateProvider).value;
    final canUpdateStaff = authorization?.can(PermissionCode.staffUpdate) ?? false;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          // HEADER (Igual a tu diseño)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Lista de bodegas",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Material(
                color: Colors.blue,
                shape: const CircleBorder(),
                elevation: 4,
                shadowColor: Colors.blue.withValues(alpha: 0.4),
                child: InkWell(
                  onTap: () {
                    // Navegar a crear (Implementaremos esto luego)
                    context.push('/warehouse-create');
                  },
                  customBorder: const CircleBorder(),
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(Icons.add, color: Colors.white, size: 24),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // BUSCADOR CONECTADO
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              onChanged: (value) {
                // ACTUALIZAMOS EL PROVIDER DE BÚSQUEDA
                ref.read(bodegaSearchQueryProvider.notifier).state = value;
              },
              decoration: InputDecoration(
                hintText: "Buscar por nombre...",
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // LISTA REACTIVA (AsyncValue)
          Expanded(
            child: bodegasAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (bodegas) {
                if (bodegas.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.warehouse_outlined,
                          size: 60,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "No hay bodegas encontradas",
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: bodegas.length,
                  itemBuilder: (context, index) {
                    final bodega = bodegas[index];
                    return WarehouseItem(
                      name: bodega.nombre,
                      onTap: () => _navegarABodega(context, bodega),
                      onManageUsers: canUpdateStaff
                          ? () => _showManageUsersDialog(context, bodega)
                          : null,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _navegarABodega(BuildContext context, Bodega bodega) {
    // ¡CRÍTICO! Usar serverId (UUID) para sincronización con Supabase.
    // NO usar bodega.id (int local), ya que causará error 22P02 en Postgres.
    context.push('/warehouse-inventory/${bodega.serverId}', extra: bodega);
  }

  Future<void> _showManageUsersDialog(BuildContext context, Bodega bodega) async {
    final db = ref.read(driftDatabaseProvider);
    final auth = ref.read(authControllerProvider.notifier);
    final currentUser = auth.usuarioActual ?? await auth.getUser();
    if (currentUser == null) return;

    if (!mounted) return;

    try {
      final users = await db.authDao.getActiveUsersByEmpresa(currentUser.empresaId);
      final assignments = await (db.select(db.bodegasUsuarios)
            ..where((tbl) => tbl.bodegaId.equals(bodega.serverId) & tbl.estado.equals(true)))
          .get();
      final activeUserIds = assignments.map((a) => a.usuarioId).toSet();

      if (!mounted) return;

      final selectedUserIds = Set<String>.from(activeUserIds);

      await showDialog<void>(
        context: context,
        builder: (ctx) => StatefulBuilder(
          builder: (context, setLocalState) => AlertDialog(
            title: Text('Accesos - ${bodega.nombre}'),
            content: SizedBox(
              width: 400,
              height: 350,
              child: users.isEmpty
                  ? const Center(child: Text('No hay personal registrado en la empresa.'))
                  : ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (c, idx) {
                        final user = users[idx];
                        final isSelected = selectedUserIds.contains(user.id);
                        return CheckboxListTile(
                          title: Text(user.nombreCompleto),
                          subtitle: Text(user.correo ?? ''),
                          value: isSelected,
                          onChanged: (checked) {
                            setLocalState(() {
                              if (checked == true) {
                                selectedUserIds.add(user.id);
                              } else {
                                selectedUserIds.remove(user.id);
                              }
                            });
                          },
                        );
                      },
                    ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    await db.authDao.replaceWarehouseUserAssignments(
                      warehouseId: bodega.serverId,
                      currentUserId: currentUser.serverId,
                      userIds: selectedUserIds,
                    );
                    
                    if (!mounted) return;
                    ref.invalidate(bodegaListProvider);
                    
                    if (ctx.mounted) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Accesos de la bodega actualizados correctamente.'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (ctx.mounted) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        SnackBar(
                          content: Text('Error al guardar accesos: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade800,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Guardar'),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar datos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
