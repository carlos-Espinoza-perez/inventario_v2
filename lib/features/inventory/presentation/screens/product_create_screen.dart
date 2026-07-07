import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:inventario_v2/core/db/app_database.dart';
import 'package:inventario_v2/core/presentation/mixins/app_bar_config_mixin.dart';
import 'package:inventario_v2/core/providers/app_bar_provider.dart';
import 'package:inventario_v2/core/providers/drift_provider.dart';
import 'package:inventario_v2/core/providers/supabase_provider.dart';
import 'package:inventario_v2/core/services/app_logger.dart';
import 'package:inventario_v2/core/services/image_storage_service.dart';
import 'package:inventario_v2/features/inventory/data/providers/categoria_provider.dart';
import 'package:inventario_v2/features/inventory/presentation/widgets/autocomplete_field_product_create.dart';
import 'package:inventario_v2/features/inventory/utils/magic_text_parser.dart';
import 'package:inventario_v2/features/inventory/presentation/providers/product_creation_memory_provider.dart';

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

class _ProductCreateScreenState extends ConsumerState<ProductCreateScreen>
    with AppBarConfigMixin {
  final Color _primaryColor = Colors.cyan.shade800;
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();
  
  // Ocultos / Avanzados
  final TextEditingController _categoryCtrl = TextEditingController();
  final TextEditingController _subCategoryCtrl = TextEditingController();
  final TextEditingController _brandCtrl = TextEditingController();
  final TextEditingController _detailCtrl = TextEditingController();

  String? _selectedImagePath;
  bool _isSaving = false;
  bool _showAdvancedOptions = false;
  final Set<String> _selectedTallas = {};

  final List<String> _brands = const [
    'Anabell', 'Apolo', 'Aurora', 'Azucena', 'Azura', 'Crocs', 'Differ',
    'Elena', 'Emeli Engreida', 'GQ', 'Gotica', 'Happy', 'Hot', 'Isabella',
    'Jingo', 'Kallua', "Levi's", 'Liverpool', 'Lovable', 'Lucatonica', 'Mobex',
    'NY', 'Nike', 'Original', 'Penguin', 'Piecitos', 'Probox', 'Rasi', 'Roca',
    'Senador', 'SF', 'Tommy Hilfiger', 'Toxica', 'Triyons', 'Vicio', 'Wearwold',
    'Wrangler', 'Yumbo',
  ];

  @override
  void configureAppBar() {
    ref.read(appBarProvider.notifier).setOptions(
      title: widget.productToEdit != null ? 'Editar Producto' : 'Nuevo Producto',
      showBackButton: true,
      actions: [],
    );
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      configureAppBar();
      _populateFieldsForEditOrMemory();
      if (widget.productToEdit == null) {
        _nameFocusNode.requestFocus();
      }
    });

    _nameController.addListener(() {
      if (!_showAdvancedOptions) {
        _runMagicParsing();
      }
    });
  }

  void _runMagicParsing() {
    final text = _nameController.text;
    if (text.trim().isEmpty) {
      _categoryCtrl.clear();
      _subCategoryCtrl.clear();
      _brandCtrl.clear();
      _populateFieldsForEditOrMemory();
      if (mounted) setState(() {});
      return;
    }
    if (text.trim().length < 3) return;

    final categoriasAll = ref.read(listCategoriasAllProvider).value ?? [];
    
    // Parse Category
    final parsedCat = MagicTextParser.extractCategory(text: text, allCategories: categoriasAll);
    if (parsedCat['child'] != null) {
      _subCategoryCtrl.text = parsedCat['child']!.nombre;
      if (parsedCat['parent'] != null) {
        _categoryCtrl.text = parsedCat['parent']!.nombre;
      }
    } else if (parsedCat['parent'] != null) {
      _categoryCtrl.text = parsedCat['parent']!.nombre;
      _subCategoryCtrl.text = '';
    }

    // Parse Brand
    final parsedBrand = MagicTextParser.extractBrand(text: text, knownBrands: _brands);
    if (parsedBrand != null) {
      _brandCtrl.text = parsedBrand;
    }
    
    if (mounted) setState(() {});
  }

  void _populateFieldsForEditOrMemory() {
    if (widget.productToEdit != null) {
      final product = widget.productToEdit!;
      _nameController.text = product.nombre;
      _selectedImagePath = product.imagenLocal;
      if (product.especificacionJson != null &&
          product.especificacionJson!.isNotEmpty) {
        try {
          final specs = jsonDecode(product.especificacionJson!);
          if (specs is Map<String, dynamic>) {
            _brandCtrl.text = specs['brand']?.toString() ?? '';
            _detailCtrl.text = specs['detail']?.toString() ?? '';
            _categoryCtrl.text = specs['parent_category']?.toString() ?? specs['category']?.toString() ?? '';
            if (specs['parent_category'] != null) {
              _subCategoryCtrl.text = specs['category']?.toString() ?? '';
            }
          }
        } catch (e, st) {
          AppLogger.error('Error decodificando specs en product_create', e, st);
        }
      }
    } else {
      // Cargar de memoria "Sticky" para lote
      final memory = ref.read(productCreationMemoryProvider);
      if (memory.categoryName.isNotEmpty) {
        _categoryCtrl.text = memory.categoryName;
        _subCategoryCtrl.text = memory.subCategoryName;
        _brandCtrl.text = memory.brandName;
        if (mounted) setState(() {});
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryCtrl.dispose();
    _subCategoryCtrl.dispose();
    _brandCtrl.dispose();
    _detailCtrl.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  Future<void> _openMagicCamera() async {
    final result = await context.push<Map<String, dynamic>>('/magic-camera');
    if (result == null) return;
    setState(() {
      if (result['imagePath'] != null) {
        _selectedImagePath = result['imagePath'] as String?;
      }
      if (result['categoria'] != null && result['categoria'].toString().isNotEmpty) {
         _categoryCtrl.text = result['categoria'].toString();
      }
      if (result['marca'] != null && result['marca'].toString().isNotEmpty) {
         _brandCtrl.text = result['marca'].toString();
      }
      if (result['detalle'] != null && result['detalle'].toString().isNotEmpty) {
         _detailCtrl.text = result['detalle'].toString();
      }
      
      // Armar nombre sugerido si está vacío
      if (_nameController.text.isEmpty) {
        final parts = <String>[];
        if (_categoryCtrl.text.isNotEmpty) parts.add(_categoryCtrl.text);
        if (_brandCtrl.text.isNotEmpty) parts.add(_brandCtrl.text);
        if (_detailCtrl.text.isNotEmpty) parts.add(_detailCtrl.text);
        _nameController.text = parts.join(' ');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final categorias = ref.watch(listCategoriasAllProvider).value ?? [];

    Categoria? currentSelectedCategory;
    final catName = _subCategoryCtrl.text.isNotEmpty ? _subCategoryCtrl.text.trim() : _categoryCtrl.text.trim();
    if (catName.isNotEmpty) {
      currentSelectedCategory = categorias.where((c) => c.nombre == catName).firstOrNull;
    }
    
    List<String> suggestedTallas = [];
    if (currentSelectedCategory?.especificacionJson != null && currentSelectedCategory!.especificacionJson!.isNotEmpty) {
      try {
        final Map<String, dynamic> spec = jsonDecode(currentSelectedCategory.especificacionJson!);
        if (spec['tallas_permitidas'] is List) {
          suggestedTallas = (spec['tallas_permitidas'] as List).map((e) => e.toString()).toList();
        }
      } catch (e, st) {
        AppLogger.error('Error decodificando tallas en product_create', e, st);
      }
    }

    final parentCategories = categorias
        .where((c) => c.categoriaPadreId == null)
        .map((c) => c.nombre)
        .toList();

    final selectedParent = categorias
        .where((c) => c.nombre == _categoryCtrl.text && c.categoriaPadreId == null)
        .firstOrNull;
        
    final hasChildren = selectedParent != null && 
        categorias.any((c) => c.categoriaPadreId == selectedParent.id);

    final childCategories = selectedParent != null
        ? categorias
            .where((c) => c.categoriaPadreId == selectedParent.id)
            .map((c) => c.nombre)
            .toList()
        : <String>[];

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
                    width: 20, height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  ),
                  SizedBox(width: 10),
                  Text('Guardando...', style: TextStyle(color: Colors.white)),
                ],
              )
            : const Text('Guardar Rápido', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // HEADER INPUT (Smart Input)
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.cyan.withValues(alpha: 0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                  border: Border.all(color: Colors.cyan.shade100, width: 2),
                ),
                child: TextField(
                  controller: _nameController,
                  focusNode: _nameFocusNode,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submitProductBase(),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  minLines: 1,
                  decoration: InputDecoration(
                    labelText: 'Describe el producto',
                    hintText: 'Ej: Pantalón Levi\'s negro',
                    labelStyle: TextStyle(
                      color: Colors.cyan.shade900,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    prefixIcon: Icon(Icons.search, color: Colors.cyan.shade700),
                    suffixIcon: _nameController.text.isNotEmpty ? IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: () {
                        _nameController.clear();
                        if (mounted) setState(() {});
                      },
                    ) : null,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              
              // CHIPS DE ESTADO
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Text('Detección: ', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                  if (_categoryCtrl.text.isEmpty && _brandCtrl.text.isEmpty)
                    const Chip(
                      label: Text('Escribe para autodetectar', style: TextStyle(fontSize: 12)),
                      backgroundColor: Colors.transparent,
                    ),
                  if (_categoryCtrl.text.isNotEmpty)
                    InputChip(
                      avatar: const Icon(Icons.category, size: 16, color: Colors.white),
                      label: Text(
                        _subCategoryCtrl.text.isNotEmpty ? '${_categoryCtrl.text} ❯ ${_subCategoryCtrl.text}' : _categoryCtrl.text,
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      backgroundColor: Colors.cyan.shade700,
                      onPressed: () => setState(() => _showAdvancedOptions = true),
                      onDeleted: () {
                        setState(() {
                          _categoryCtrl.clear();
                          _subCategoryCtrl.clear();
                          // Clear memory too so it doesn't come back on empty
                          ref.read(productCreationMemoryProvider.notifier).clearMemory();
                        });
                      },
                      deleteIconColor: Colors.white70,
                    ),
                  if (_brandCtrl.text.isNotEmpty)
                    InputChip(
                      avatar: const Icon(Icons.branding_watermark, size: 16, color: Colors.white),
                      label: Text(
                        _brandCtrl.text,
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      backgroundColor: Colors.indigo.shade400,
                      onPressed: () => setState(() => _showAdvancedOptions = true),
                      onDeleted: () {
                        setState(() {
                          _brandCtrl.clear();
                          ref.read(productCreationMemoryProvider.notifier).clearMemory();
                        });
                      },
                      deleteIconColor: Colors.white70,
                    ),
                ],
              ),
              const SizedBox(height: 20),
              
              // CAMERA BUTTON
              Center(
                child: GestureDetector(
                  onTap: _isSaving ? null : _openMagicCamera,
                  child: Container(
                    width: _selectedImagePath != null ? 120 : double.infinity,
                    height: _selectedImagePath != null ? 120 : 60,
                    decoration: BoxDecoration(
                      color: _selectedImagePath != null ? Colors.white : Colors.cyan.shade50,
                      borderRadius: BorderRadius.circular(_selectedImagePath != null ? 24 : 12),
                      border: _selectedImagePath != null ? null : Border.all(color: Colors.cyan.shade200),
                      boxShadow: _selectedImagePath != null ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ] : null,
                      image: _selectedImagePath != null
                          ? DecorationImage(
                              image: FileImage(File(_selectedImagePath!)),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _selectedImagePath == null
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt, color: _primaryColor),
                              const SizedBox(width: 8),
                              Text(
                                'Añadir Foto (Opcional)',
                                style: TextStyle(
                                  color: _primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          )
                        : null,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // ADVANCED TOGGLE
              if (!_showAdvancedOptions)
                Center(
                  child: TextButton.icon(
                    onPressed: () => setState(() => _showAdvancedOptions = true),
                    icon: const Icon(Icons.tune),
                    label: const Text('Opciones Avanzadas / Manuales'),
                    style: TextButton.styleFrom(foregroundColor: Colors.grey.shade700),
                  ),
                ),

              if (_showAdvancedOptions) ...[
                const Text(
                  'Detalles Manuales',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      OpenAutocompleteField(
                        controller: _categoryCtrl,
                        label: 'Categoría',
                        options: parentCategories,
                        icon: Icons.category_outlined,
                      ),
                      if (hasChildren) ...[
                        const SizedBox(height: 20),
                        OpenAutocompleteField(
                          controller: _subCategoryCtrl,
                          label: 'Subcategoría',
                          options: childCategories,
                          icon: Icons.account_tree_outlined,
                        ),
                      ],
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
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: 'Modelo / Rasgos (Opcional)',
                          hintText: 'Ej: Air Max, Rayado...',
                          filled: true,
                          fillColor: Colors.grey[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: Icon(Icons.edit_note, color: Colors.grey[400]),
                          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              if (widget.productToEdit == null && suggestedTallas.isNotEmpty) ...[
                const SizedBox(height: 25),
                const Text(
                  'Tallas detectadas (Opcional):',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: suggestedTallas.map((talla) {
                    final isSelected = _selectedTallas.contains(talla);
                    return FilterChip(
                      label: Text(talla),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedTallas.add(talla);
                          } else {
                            _selectedTallas.remove(talla);
                          }
                        });
                      },
                      selectedColor: _primaryColor.withValues(alpha: 0.2),
                      checkmarkColor: _primaryColor,
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitProductBase() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor describe el producto')),
      );
      _nameFocusNode.requestFocus();
      return;
    }

    setState(() => _isSaving = true);
    try {
      final db = ref.read(driftDatabaseProvider);
      final sesion = await db.authDao.getSesionActiva();
      if (sesion == null) {
        throw Exception('No se pudo resolver la sesion activa.');
      }

      final categoriaNombre = _categoryCtrl.text.trim();
      final subCategoriaNombre = _subCategoryCtrl.text.trim();
      final marcaNombre = _brandCtrl.text.trim();
      
      // Guardar en memoria Sticky para el siguiente producto en lote
      ref.read(productCreationMemoryProvider.notifier).saveMemory(
        categoryName: categoriaNombre,
        subCategoryName: subCategoriaNombre,
        brandName: marcaNombre,
      );

      final categoriasAll = ref.read(listCategoriasAllProvider).value ?? [];
      final parentCatEntity = categoriasAll.where((c) => c.nombre == categoriaNombre && c.categoriaPadreId == null).firstOrNull;
      final checkHasChildren = parentCatEntity != null && categoriasAll.any((c) => c.categoriaPadreId == parentCatEntity.id);

      if (checkHasChildren && subCategoriaNombre.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, selecciona la subcategoría específica')),
        );
        setState(() {
          _isSaving = false;
          _showAdvancedOptions = true;
        });
        return;
      }

      Categoria? parentCategoria;
      if (categoriaNombre.isNotEmpty) {
        parentCategoria = await db.inventoryDao.findCategoriaByName(
          empresaId: sesion.empresa.id,
          name: categoriaNombre,
        );
      }
      parentCategoria ??= await db.inventoryDao.saveCategoria(
        categoriaId: null,
        empresaId: sesion.empresa.id,
        nombre: categoriaNombre.isEmpty ? 'General' : categoriaNombre,
        categoriaPadreId: null,
        usuarioRegistroId: sesion.usuario.id,
      );

      Categoria? categoriaSeleccionada;
      if (subCategoriaNombre.isNotEmpty) {
        Categoria? childCategoria = await db.inventoryDao.findCategoriaByName(
          empresaId: sesion.empresa.id,
          name: subCategoriaNombre,
        );
        childCategoria ??= await db.inventoryDao.saveCategoria(
          categoriaId: null,
          empresaId: sesion.empresa.id,
          nombre: subCategoriaNombre,
          categoriaPadreId: parentCategoria.id,
          usuarioRegistroId: sesion.usuario.id,
        );
        categoriaSeleccionada = childCategoria;
      } else {
        categoriaSeleccionada = parentCategoria;
      }

      // NO SUBIR A SUPABASE AQUI. Solo copiar archivo localmente.
      String? localPathFinal = widget.productToEdit?.imagenLocal;
      String? webUrlFinal = widget.productToEdit?.imagenUrl;
      bool needsBackgroundUpload = false;

      if (_selectedImagePath != null) {
        final changedImage = widget.productToEdit?.imagenLocal != _selectedImagePath;
        if (changedImage) {
          final tempFile = File(_selectedImagePath!);
          if (await tempFile.exists()) {
            final appDir = await getApplicationDocumentsDirectory();
            final fileName = p.basename(tempFile.path);
            final permanentPath = '${appDir.path}/$fileName';
            final savedImage = await tempFile.copy(permanentPath);
            localPathFinal = savedImage.path;
            needsBackgroundUpload = true;
          }
        }
      }

      final bodegaIds = await db.authDao.getValidBodegasIds();
      final specs = jsonEncode({
        'brand': marcaNombre,
        'category': categoriaSeleccionada.nombre,
        'parent_category': parentCategoria.nombre,
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
        imagenUrl: webUrlFinal, // Mantenemos la antigua o null
        ultimoCosto: widget.productToEdit?.ultimoCosto ?? 0,
        precioBase: widget.productToEdit?.precioBase ?? 0,
        defaultSku: widget.initialBarcode,
        bodegaIds: bodegaIds,
        tallasSeleccionadas: widget.productToEdit == null && _selectedTallas.isNotEmpty ? _selectedTallas.toList() : null,
      );

      // Lanzar subida en background (Fire and Forget)
      if (needsBackgroundUpload && localPathFinal != null) {
        _uploadImageInBackground(
          productId: savedProduct.id,
          localPath: localPathFinal,
        );
      }

      if (!mounted) return;
      Navigator.pop(context, {
        'productId': savedProduct.id,
        'categoriaId': savedProduct.categoriaId,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Guardado localmente (Instantáneo)'),
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

  Future<void> _uploadImageInBackground({
    required String productId,
    required String localPath,
  }) async {
    try {
      final file = File(localPath);
      if (!await file.exists()) return;
      
      final storageService = ImageStorageService(ref.read(supabaseClientProvider));
      final webUrl = await storageService.uploadProductImage(file);
      
      final db = ref.read(driftDatabaseProvider);
      await db.inventoryDao.updateProductImage(productId, localPath, webUrl);
      AppLogger.info('Foto subida en background exitosamente para producto: $productId');
    } catch (e, st) {
      AppLogger.error('Error subiendo imagen en background', e, st);
    }
  }
}
