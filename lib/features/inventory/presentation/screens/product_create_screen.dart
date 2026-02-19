import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as p;

// Core Providers
import 'package:inventario_v2/core/providers/app_bar_provider.dart';
import 'package:inventario_v2/core/providers/supabase_provider.dart';
import 'package:inventario_v2/core/services/image_storage_service.dart';

// Auth
import 'package:inventario_v2/features/auth/presentation/providers/auth_provider.dart';

// Inventory Data & Collections
import 'package:inventario_v2/features/inventory/data/collections/categoria_collection.dart';
import 'package:inventario_v2/features/inventory/data/collections/producto_collection.dart';
import 'package:inventario_v2/features/inventory/data/providers/categoria_provider.dart';
import 'package:inventario_v2/features/inventory/data/providers/producto_provider.dart';

// Widgets
import 'package:inventario_v2/features/inventory/presentation/widgets/autocomplete_field_product_create.dart';
import 'package:inventario_v2/features/inventory/presentation/widgets/autocomplete_grouped_field_product_create.dart';

class ProductCreateScreen extends ConsumerStatefulWidget {
  final ProductoCollection? productToEdit;

  const ProductCreateScreen({super.key, this.productToEdit});

  @override
  ConsumerState<ProductCreateScreen> createState() =>
      _ProductCreateScreenState();
}

class _ProductCreateScreenState extends ConsumerState<ProductCreateScreen> {
  final Color _primaryColor = Colors.cyan.shade800;

  // Controladores
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _categoryCtrl = TextEditingController();
  final TextEditingController _brandCtrl = TextEditingController();
  final TextEditingController _detailCtrl = TextEditingController();

  // Estado Local
  String? _selectedImagePath;
  bool _isSaving = false;

  final List<String> _brands = [
    "Levi's",
    "Nike",
    "Original",
    "Tommy Hilfiger",
    "Lovable",
    "Anabell",
    "Apolo",
    "Azucena",
    "Azura",
    "Differ",
    "Elena",
    "Emeli Engreida",
    "GQ",
    "Happy",
    "Isabella",
    "Jingo",
    "Kallua",
    "Liverpool",
    "Lucatonica",
    "Mobex",
    "Piecitos",
    "Rasi",
    "Roca",
    "Triyons",
    "Vicio",
    "Wearwold",
    "Yumbo",
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(appBarProvider.notifier)
          .setOptions(
            title: widget.productToEdit != null
                ? "Editar Producto"
                : "Nuevo Producto",
            showBackButton: true,
            actions: [],
          );

      // LÓGICA DE POBLADO DE DATOS MEJORADA
      _populateFieldsForEdit();
    });

    // Listeners para generar nombre automático (Smart Name)
    _categoryCtrl.addListener(_updateSmartName);
    _brandCtrl.addListener(_updateSmartName);
    _detailCtrl.addListener(_updateSmartName);
  }

  /// Función dedicada a rellenar los campos si estamos en modo edición
  void _populateFieldsForEdit() {
    if (widget.productToEdit == null) return;

    final product = widget.productToEdit!;

    // 1. Campos Básicos
    _nameController.text = product.nombre;
    if (mounted) {
      setState(() {
        _selectedImagePath = product.imagenLocal;
      });
    }

    // 2. Intentar sacar datos del JSON (Prioridad 1)
    if (product.especificacionJson != null &&
        product.especificacionJson!.isNotEmpty) {
      try {
        final specs = jsonDecode(product.especificacionJson!);
        if (specs is Map<String, dynamic>) {
          _brandCtrl.text = specs['brand'] ?? '';
          _detailCtrl.text = specs['detail'] ?? '';

          // Si el JSON tiene la categoría guardada como texto, úsala
          if (specs['category'] != null &&
              specs['category'].toString().isNotEmpty) {
            _categoryCtrl.text = specs['category'];
          }
        }
      } catch (e) {
        debugPrint("Error al parsear JSON de especificaciones: $e");
      }
    }

    if (_categoryCtrl.text.isEmpty && product.categoriaId.isNotEmpty) {
      final categoriasAsync = ref.read(listCategoriasAllProvider);
      final listaCategorias = categoriasAsync.valueOrNull ?? [];

      final foundCat = listaCategorias.firstWhere(
        (c) => c.serverId == product.categoriaId,
        orElse: () => CategoriaCollection(),
      );

      if (foundCat.serverId.isNotEmpty) {
        _categoryCtrl.text = foundCat.nombre;
      }
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

    List<String> parts = [];
    if (_categoryCtrl.text.isNotEmpty) parts.add(_categoryCtrl.text);
    if (_brandCtrl.text.isNotEmpty &&
        _brandCtrl.text.toLowerCase() != "generico") {
      parts.add(_brandCtrl.text);
    }
    if (_detailCtrl.text.isNotEmpty) parts.add(_detailCtrl.text);

    if (parts.isNotEmpty) {
      setState(() {
        _nameController.text = parts.join(" ");
      });
    }
  }

  Future<void> _openMagicCamera() async {
    final result = await context.push<Map<String, dynamic>>('/magic-camera');

    if (result != null) {
      setState(() {
        if (result['imagePath'] != null) {
          _selectedImagePath = result['imagePath'];
        }

        String cat = result['categoria'] ?? "";
        String brand = result['marca'] ?? "";
        String detail = result['detalle'] ?? "";

        if (cat.isNotEmpty) _categoryCtrl.text = cat;
        if (brand.isNotEmpty) _brandCtrl.text = brand;
        if (detail.isNotEmpty) _detailCtrl.text = detail;

        // Si es nuevo, sugerimos nombre
        if (widget.productToEdit == null) {
          List<String> nameParts = [];
          if (cat.isNotEmpty) nameParts.add(cat);
          if (brand.isNotEmpty && brand.toLowerCase() != "generico") {
            nameParts.add(brand);
          }
          if (detail.isNotEmpty) {
            String formattedDetail =
                detail[0].toUpperCase() + detail.substring(1);
            nameParts.add(formattedDetail);
          }
          _nameController.text = nameParts.join(" ");
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Producto identificado: ${_nameController.text}"),
            backgroundColor: _primaryColor,
          ),
        );
      }
    }
  }

  Map<String, List<String>> mapCategoriasToGroupedOptions(
    List<CategoriaCollection> todasLasCategorias,
  ) {
    final Map<String, List<String>> groupedOptions = {};

    final Map<String, String> padresMap = {
      for (var cat in todasLasCategorias.where(
        (c) => c.categoriaPadreId == null,
      ))
        cat.serverId: cat.nombre,
    };

    for (var nombrePadre in padresMap.values) {
      groupedOptions[nombrePadre] = [];
    }

    final hijos = todasLasCategorias.where((c) => c.categoriaPadreId != null);

    for (var hijo in hijos) {
      final nombrePadre = padresMap[hijo.categoriaPadreId];
      if (nombrePadre != null) {
        groupedOptions[nombrePadre]?.add(hijo.nombre);
      }
    }

    return groupedOptions;
  }

  @override
  Widget build(BuildContext context) {
    final listCategorias = ref.watch(listCategoriasAllProvider);
    final groupedOptions = mapCategoriasToGroupedOptions(
      listCategorias.value ?? [],
    );

    return Scaffold(
      backgroundColor: Colors.grey[50],
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isSaving ? null : _submitProductBase,
        backgroundColor: _isSaving ? Colors.grey : _primaryColor,
        icon: _isSaving
            ? const SizedBox(width: 0, height: 0)
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
                  Text("Guardando...", style: TextStyle(color: Colors.white)),
                ],
              )
            : const Text(
                "Guardar Producto",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // FOTO
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
                              color: Colors.black.withOpacity(0.12),
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
                                    "Escanear + Foto",
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

              // FORMULARIO
              const Text(
                "Ficha del Producto",
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
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    OpenAutocompleteGroupedField(
                      controller: _categoryCtrl,
                      label: "Categoría",
                      groupedOptions: groupedOptions,
                      icon: Icons.category_outlined,
                    ),
                    const SizedBox(height: 20),
                    OpenAutocompleteField(
                      controller: _brandCtrl,
                      label: "Marca",
                      options: _brands,
                      icon: Icons.branding_watermark_outlined,
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _detailCtrl,
                      decoration: InputDecoration(
                        labelText: "Modelo / Rasgos (Opcional)",
                        hintText: "Ej: Air Max, Rayado...",
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
                  color: Colors.cyan.shade50.withOpacity(0.5),
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
                    labelText: "Nombre del Producto (Editable)",
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
    // 1. Validaciones básicas
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Falta el nombre del producto")),
      );
      return;
    }

    if (mounted) setState(() => _isSaving = true);

    try {
      // 3. Buscar ID de Categoría por nombre
      final listCategorias = ref.read(listCategoriasAllProvider).value ?? [];
      final categoriaSeleccionada = listCategorias.firstWhere(
        (c) => c.nombre.toLowerCase() == _categoryCtrl.text.toLowerCase(),
        orElse: () => CategoriaCollection(),
      );

      if (categoriaSeleccionada.serverId.isEmpty) {
        throw Exception(
          "La categoría '${_categoryCtrl.text}' no es válida. Selecciónela de la lista.",
        );
      }

      // 4. Obtener Usuario
      final authController = ref.read(authControllerProvider.notifier);
      final usuario =
          authController.usuarioActual ?? await authController.getUser();

      if (usuario == null) {
        throw Exception("Usuario no encontrado, inicie sesión nuevamente.");
      }

      // 5. Procesar Imagen
      String? localPathFinal;
      String? webUrlFinal;

      if (_selectedImagePath != null) {
        // Solo copiamos si la imagen cambió (es diferente a la que ya teníamos)
        // O si es un producto nuevo.
        final esNuevaImagen =
            widget.productToEdit?.imagenLocal != _selectedImagePath;

        if (esNuevaImagen) {
          final File tempFile = File(_selectedImagePath!);
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
            } catch (e) {
              debugPrint("Error subiendo imagen: $e");
            }
          }
        } else {
          // Mantenemos la que ya tenía
          localPathFinal = widget.productToEdit?.imagenLocal;
          webUrlFinal = widget.productToEdit?.imagenUrl;
        }
      }

      // 6. Preparar Objeto
      final productoAGuardar = widget.productToEdit ?? ProductoCollection();

      productoAGuardar
        ..serverId = widget.productToEdit != null
            ? productoAGuardar.serverId
            : const Uuid().v4()
        ..nombre = _nameController.text
        ..categoriaId = categoriaSeleccionada.serverId
        ..empresaId = usuario.empresaId
        ..usuarioRegistroId = usuario.serverId
        ..especificacionJson = jsonEncode({
          'brand': _brandCtrl.text,
          'category': _categoryCtrl.text,
          'detail': _detailCtrl.text,
        })
        ..imagenLocal = localPathFinal ?? productoAGuardar.imagenLocal
        ..imagenUrl = webUrlFinal ?? productoAGuardar.imagenUrl
        ..fechaRegistro = widget.productToEdit != null
            ? productoAGuardar.fechaRegistro
            : DateTime.now()
        ..ultimaActualizacion = DateTime.now()
        ..pendienteSincronizacion = true
        ..estado = true;

      // 7. Guardar
      final repo = await ref.read(productoRepositoryProvider.future);
      await repo.saveProducto(productoAGuardar);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              webUrlFinal != null
                  ? "Guardado y sincronizado ☁️"
                  : "Guardado localmente 💾",
            ),
            backgroundColor: _primaryColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
