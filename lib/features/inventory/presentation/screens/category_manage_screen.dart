import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventario_v2/core/constants/permission_codes.dart';
import 'package:inventario_v2/core/db/app_database.dart';
import 'package:inventario_v2/core/presentation/mixins/app_bar_config_mixin.dart';
import 'package:inventario_v2/core/providers/app_bar_provider.dart';
import 'package:inventario_v2/core/providers/drift_provider.dart';
import 'package:inventario_v2/core/services/app_logger.dart';
import 'package:inventario_v2/features/auth/presentation/providers/auth_provider.dart';
import 'package:inventario_v2/features/auth/presentation/providers/authorization_provider.dart';
import 'package:inventario_v2/features/inventory/data/providers/categoria_provider.dart';

class CategoryManageScreen extends ConsumerStatefulWidget {
  const CategoryManageScreen({super.key});

  @override
  ConsumerState<CategoryManageScreen> createState() =>
      _CategoryManageScreenState();
}

class _CategoryManageScreenState extends ConsumerState<CategoryManageScreen>
    with AppBarConfigMixin {
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _tallasCtrl = TextEditingController();
  String? _parentId;

  @override
  void configureAppBar() {
    ref.read(appBarProvider.notifier).setOptions(
      title: 'Categorias',
      subtitle: 'Organiza tu catalogo',
      showBackButton: true,
    );
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(configureAppBar);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _tallasCtrl.dispose();
    super.dispose();
  }

  Future<void> _showCategoryDialog(
    List<Categoria> categorias, {
    Categoria? category,
  }) async {
    _nameCtrl.text = category?.nombre ?? '';
    _parentId = category?.categoriaPadreId;
    
    _tallasCtrl.text = '';
    if (category?.especificacionJson != null && category!.especificacionJson!.isNotEmpty) {
      try {
        final Map<String, dynamic> spec = jsonDecode(category.especificacionJson!);
        if (spec.containsKey('tallas_permitidas')) {
          final List<dynamic> tallas = spec['tallas_permitidas'];
          _tallasCtrl.text = tallas.join(', ');
        }
      } catch (e, st) {
        AppLogger.error('Error decodificando tallas permitidas', e, st);
      }
    }

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setLocalState) => AlertDialog(
            title: Text(
              category == null ? 'Nueva categoria' : 'Editar categoria',
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nombre de la categoria',
                      hintText: 'Ej. Camisetas, Deportivo...',
                    ),
                    autofocus: true,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _tallasCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Tallas Permitidas (Opcional)',
                      hintText: 'Ej. S, M, L o 32, 34, 36',
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String?>(
                    initialValue: _parentId,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Categoria padre',
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Sin padre'),
                      ),
                      ...categorias
                          .where((item) => category == null || item.id != category.id)
                          .map(
                            (item) => DropdownMenuItem<String?>(
                              value: item.id,
                              child: Text(item.nombre),
                            ),
                          ),
                    ],
                    onChanged: (value) {
                      setLocalState(() {
                        _parentId = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => _saveCategory(category),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyan.shade800,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Guardar'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveCategory(Categoria? existing) async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes ingresar el nombre de la categoria')),
      );
      return;
    }

    try {
      final auth = ref.read(authControllerProvider.notifier);
      final user = auth.usuarioActual ?? await auth.getUser();
      if (user == null) return;

      final db = ref.read(driftDatabaseProvider);
      final duplicated = await db.inventoryDao.findCategoriaByName(
        empresaId: user.empresaId,
        name: name,
        categoriaPadreId: _parentId,
        excludeCategoriaId: existing?.id,
      );

      if (duplicated != null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ya existe una categoria con ese nombre en ese nivel'),
          ),
        );
        return;
      }

      String? especificacionJson = existing?.especificacionJson;
      final tallasStr = _tallasCtrl.text.trim();
      
      Map<String, dynamic> spec = {};
      if (especificacionJson != null && especificacionJson.isNotEmpty) {
        try {
          spec = jsonDecode(especificacionJson);
        } catch (e, st) {
          AppLogger.error('Error decodificando especificacionJson', e, st);
        }
      }
      
      if (tallasStr.isNotEmpty) {
        final tallasList = tallasStr.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
        spec['tallas_permitidas'] = tallasList;
        especificacionJson = jsonEncode(spec);
      } else {
        spec.remove('tallas_permitidas');
        especificacionJson = spec.isEmpty ? null : jsonEncode(spec);
      }

      await db.inventoryDao.saveCategoria(
        categoriaId: existing?.id,
        empresaId: user.empresaId,
        nombre: name,
        categoriaPadreId: _parentId,
        usuarioRegistroId: user.serverId,
        especificacionJson: especificacionJson,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Categoria guardada con exito')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _deleteCategory(Categoria category) async {
    final categorias = ref.read(listCategoriasAllProvider).value ?? [];
    final children = categorias
        .where((c) => c.categoriaPadreId == category.id)
        .toList();

    if (children.isNotEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se puede eliminar una categoria con subcategorias asociadas',
          ),
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar categoria'),
        content: Text('Estas seguro de eliminar "${category.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Si, eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final db = ref.read(driftDatabaseProvider);
      await db.inventoryDao.deactivateCategoria(category.id);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Categoria eliminada')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncCategorias = ref.watch(listCategoriasAllProvider);
    final authorization = ref.watch(authorizationStateProvider).value;
    final canCreate = authorization?.can(PermissionCode.categoryCreate) ?? false;
    final canUpdate = authorization?.can(PermissionCode.categoryUpdate) ?? false;
    final canDelete = authorization?.can(PermissionCode.categoryDelete) ?? false;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      floatingActionButton: canCreate
          ? asyncCategorias.whenOrNull(
              data: (categorias) => FloatingActionButton(
                onPressed: () => _showCategoryDialog(categorias),
                backgroundColor: Colors.cyan.shade800,
                child: const Icon(Icons.add, color: Colors.white),
              ),
            )
          : null,
      body: asyncCategorias.when(
        data: (categorias) {
          if (categorias.isEmpty) {
            return const Center(child: Text('No hay categorias creadas.'));
          }

          final rootCategories = categorias
              .where((item) => item.categoriaPadreId == null)
              .toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: rootCategories.length,
            itemBuilder: (context, index) {
              final root = rootCategories[index];
              final children = categorias
                  .where((item) => item.categoriaPadreId == root.id)
                  .toList();

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ExpansionTile(
                  title: Text(
                    root.nombre,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    children.isEmpty
                        ? 'Categoria principal'
                        : '${children.length} subcategorias',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (canUpdate)
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () =>
                              _showCategoryDialog(categorias, category: root),
                        ),
                      if (canDelete)
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () => _deleteCategory(root),
                        ),
                    ],
                  ),
                  children: [
                    if (children.isEmpty)
                      const ListTile(
                        dense: true,
                        title: Text('Sin subcategorias'),
                      ),
                    ...children.map(
                      (child) => ListTile(
                        leading: const Icon(Icons.subdirectory_arrow_right),
                        title: Text(child.nombre),
                        subtitle: const Text('Subcategoria'),
                        trailing: Wrap(
                          spacing: 4,
                          children: [
                            if (canUpdate)
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _showCategoryDialog(
                                  categorias,
                                  category: child,
                                ),
                              ),
                            if (canDelete)
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                ),
                                onPressed: () => _deleteCategory(child),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
