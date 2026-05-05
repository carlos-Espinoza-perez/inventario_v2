import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:inventario_v2/core/db/app_database.dart';
import 'package:inventario_v2/core/providers/app_bar_provider.dart';
import 'package:inventario_v2/core/providers/drift_provider.dart';
import 'package:inventario_v2/core/providers/supabase_provider.dart';
import 'package:inventario_v2/core/services/image_storage_service.dart';
import 'package:inventario_v2/features/inventory/data/providers/categoria_provider.dart';
import 'package:inventario_v2/features/inventory/presentation/widgets/autocomplete_field_product_create.dart';
import 'package:inventario_v2/features/inventory/presentation/widgets/autocomplete_grouped_field_product_create.dart';

class ProductCreateScreen extends ConsumerStatefulWidget {
  final Producto? productToEdit;
  final String? initialBarcode;

  const ProductCreateScreen({
    super.key,
    this.productToEdit,
    this.initialBarcode,
  });

  @override
  ConsumerState<ProductCreateScreen> createState() =>
      _ProductCreateScreenState();
}

class _ProductCreateScreenState extends ConsumerState<ProductCreateScreen> {
  final Color _primaryColor = Colors.cyan.shade800;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _categoryCtrl = TextEditingController();
  final TextEditingController _brandCtrl = TextEditingController();
  final TextEditingController _detailCtrl = TextEditingController();

  String? _selectedImagePath;
  bool _isSaving = false;

  final List<String> _brands = const [
    "Levi's",
    'Nike',
    'Original',
    'Tommy Hilfiger',
    'Lovable',
    'Anabell',
    'Apolo',
    'Azucena',
    'Azura',
    'Differ',
    'Elena',
    'Emeli Engreida',
    'GQ',
    'Happy',
    'Isabella',
    'Jingo',
    'Kallua',
    'Liverpool',
    'Lucatonica',
    'Mobex',
    'Piecitos',
    'Rasi',
    'Roca',
    'Triyons',
    'Vicio',
    'Wearwold',
    'Yumbo',
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(appBarProvider.notifier)
          .setOptions(
            title: widget.productToEdit != null
                ? 'Editar Producto'
                : 'Nuevo Producto',
            showBackButton: true,
            actions: [],
          );
      _populateFieldsForEdit();
    });
    _categoryCtrl.addListener(_updateSmartName);
    _brandCtrl.addListener(_updateSmartName);
    _detailCtrl.addListener(_updateSmartName);
  }

  void _populateFieldsForEdit() {
    final product = widget.productToEdit;
    if (product == null) return;
    _nameController.text = product.nombre;
    _selectedImagePath = product.imagenLocal;
    if (product.especificacionJson != null &&
        product.especificacionJson!.isNotEmpty) {
      try {
        final specs = jsonDecode(product.especificacionJson!);
        if (specs is Map<String, dynamic>) {
          _brandCtrl.text = specs['brand']?.toString() ?? '';
          _detailCtrl.text = specs['detail']?.toString() ?? '';
          _categoryCtrl.text = specs['category']?.toString() ?? '';
        }
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryCtrl.dispose();
    _brandCtrl.dispose();
    _detailCtrl.dispose();
    super.dispose();
  }

  void _updateSmartName() {
    if (widget.productToEdit != null) return;
    final parts = <String>[];
    if (_categoryCtrl.text.isNotEmpty) parts.add(_categoryCtrl.text.trim());
    if (_brandCtrl.text.isNotEmpty &&
        _brandCtrl.text.trim().toLowerCase() != 'generico') {
      parts.add(_brandCtrl.text.trim());
    }
    if (_detailCtrl.text.isNotEmpty) parts.add(_detailCtrl.text.trim());
    if (parts.isNotEmpty) {
      _nameController.text = parts.join(' ');
    }
  }

  Future<void> _openMagicCamera() async {
    final result = await context.push<Map<String, dynamic>>('/magic-camera');
    if (result == null) return;
    setState(() {
      if (result['imagePath'] != null) {
        _selectedImagePath = result['imagePath'] as String?;
      }
      _categoryCtrl.text = (result['categoria'] ?? '').toString();
      _brandCtrl.text = (result['marca'] ?? '').toString();
      _detailCtrl.text = (result['detalle'] ?? '').toString();
    });
    _updateSmartName();
  }

  Map<String, List<String>> _mapCategoriasToGroupedOptions(
    List<Categoria> categorias,
  ) {
    final groupedOptions = <String, List<String>>{};
    final padres = {
      for (final cat in categorias.where((c) => c.categoriaPadreId == null))
        cat.id: cat.nombre,
    };
    for (final parentName in padres.values) {
      groupedOptions[parentName] = [];
    }
    for (final hijo in categorias.where((c) => c.categoriaPadreId != null)) {
      final nombrePadre = padres[hijo.categoriaPadreId];
      if (nombrePadre != null) {
        groupedOptions[nombrePadre]!.add(hijo.nombre);
      }
    }
    return groupedOptions;
  }

  @override
  Widget build(BuildContext context) {
    final categorias = ref.watch(listCategoriasAllProvider).value ?? [];
    final groupedOptions = _mapCategoriasToGroupedOptions(categorias);

    if (_categoryCtrl.text.isEmpty && widget.productToEdit != null) {
      final current = categorias
          .where((c) => c.id == widget.productToEdit!.categoriaId)
          .firstOrNull;
      if (current != null) {
        _categoryCtrl.text = current.nombre;
      }
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isSaving ? null : _submitProductBase,
        backgroundColor: _isSaving ? Colors.grey : _primaryColor,
        icon: _isSaving
            ? const SizedBox.shrink()
            : const Icon(Icons.save, color: Colors.white),
        label: _isSaving
            ? Row(
                children: const [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                  SizedBox(width: 10),
                  Text('Guardando...', style: TextStyle(color: Colors.white)),
                ],
              )
            : const Text(
                'Guardar Producto',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: GestureDetector(
                  onTap: _isSaving ? null : _openMagicCamera,
                  child: Stack(
                    children: [
                      Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                          image: _selectedImagePath != null
                              ? DecorationImage(
                                  image: FileImage(File(_selectedImagePath!)),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: _selectedImagePath == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.camera_alt_rounded,
                                    size: 40,
                                    color: _primaryColor,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Escanear + Foto',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: _primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              )
                            : null,
                      ),
                      if (_selectedImagePath != null && !_isSaving)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.refresh, color: _primaryColor),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Ficha del Producto',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    OpenAutocompleteGroupedField(
                      controller: _categoryCtrl,
                      label: 'Categoria',
                      groupedOptions: groupedOptions,
                      icon: Icons.category_outlined,
                    ),
                    const SizedBox(height: 20),
                    OpenAutocompleteField(
                      controller: _brandCtrl,
                      label: 'Marca',
                      options: _brands,
                      icon: Icons.branding_watermark_outlined,
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _detailCtrl,
                      decoration: InputDecoration(
                        labelText: 'Modelo / Rasgos (Opcional)',
                        hintText: 'Ej: Air Max, Rayado...',
                        filled: true,
                        fillColor: Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: Icon(
                          Icons.edit_note,
                          color: Colors.grey[400],
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.cyan.shade50.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.cyan.shade100),
                ),
                child: TextField(
                  controller: _nameController,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  minLines: 1,
                  decoration: InputDecoration(
                    labelText: 'Nombre del Producto (Editable)',
                    labelStyle: TextStyle(
                      color: Colors.cyan.shade900,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    suffixIcon: Icon(
                      Icons.edit,
                      size: 18,
                      color: _primaryColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitProductBase() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Falta el nombre del producto')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final db = ref.read(driftDatabaseProvider);
      final sesion = await db.authDao.getSesionActiva();
      if (sesion == null) {
        throw Exception('No se pudo resolver la sesion activa.');
      }

      Categoria? categoriaSeleccionada;
      final categoriaNombre = _categoryCtrl.text.trim();
      if (categoriaNombre.isNotEmpty) {
        categoriaSeleccionada = await db.inventoryDao.findCategoriaByName(
          empresaId: sesion.empresa.id,
          name: categoriaNombre,
        );
      }
      categoriaSeleccionada ??= await db.inventoryDao.saveCategoria(
        categoriaId: null,
        empresaId: sesion.empresa.id,
        nombre: categoriaNombre.isEmpty ? 'General' : categoriaNombre,
        categoriaPadreId: null,
        usuarioRegistroId: sesion.usuario.id,
      );

      String? localPathFinal = widget.productToEdit?.imagenLocal;
      String? webUrlFinal = widget.productToEdit?.imagenUrl;
      if (_selectedImagePath != null) {
        final changedImage =
            widget.productToEdit?.imagenLocal != _selectedImagePath;
        if (changedImage) {
          final tempFile = File(_selectedImagePath!);
          if (await tempFile.exists()) {
            final appDir = await getApplicationDocumentsDirectory();
            final fileName = p.basename(tempFile.path);
            final permanentPath = '${appDir.path}/$fileName';
            final savedImage = await tempFile.copy(permanentPath);
            localPathFinal = savedImage.path;
            try {
              final storageService = ImageStorageService(
                ref.read(supabaseClientProvider),
              );
              webUrlFinal = await storageService.uploadProductImage(savedImage);
            } catch (_) {}
          }
        }
      }

      final bodegaIds = await db.authDao.getValidBodegasIds();
      final specs = jsonEncode({
        'brand': _brandCtrl.text.trim(),
        'category': categoriaSeleccionada.nombre,
        'detail': _detailCtrl.text.trim(),
      });

      final savedProduct = await db.inventoryDao.saveProductLifecycle(
        productId: widget.productToEdit?.id,
        empresaId: sesion.empresa.id,
        usuarioRegistroId: sesion.usuario.id,
        nombre: _nameController.text.trim(),
        categoriaId: categoriaSeleccionada.id,
        especificacionJson: specs,
        imagenLocal: localPathFinal,
        imagenUrl: webUrlFinal,
        ultimoCosto: widget.productToEdit?.ultimoCosto ?? 0,
        precioBase: widget.productToEdit?.precioBase ?? 0,
        defaultSku: widget.initialBarcode,
        bodegaIds: bodegaIds,
      );

      if (!mounted) return;
      Navigator.pop(context, {
        'productId': savedProduct.id,
        'categoriaId': savedProduct.categoriaId,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            webUrlFinal != null
                ? 'Guardado y sincronizado'
                : 'Guardado localmente',
          ),
          backgroundColor: _primaryColor,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
