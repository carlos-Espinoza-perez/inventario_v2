import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
// ✅ Import correcto
import 'package:inventario_v2/core/database/app_bar_provider.dart';

class ProductCreateScreen extends ConsumerStatefulWidget {
  const ProductCreateScreen({super.key});

  @override
  ConsumerState<ProductCreateScreen> createState() =>
      _ProductCreateScreenState();
}

class _ProductCreateScreenState extends ConsumerState<ProductCreateScreen> {
  // Color Primario definido por ti
  final Color _primaryColor = Colors.cyan.shade800;

  // Controladores
  final TextEditingController _nameController = TextEditingController();

  final TextEditingController _categoryCtrl = TextEditingController();
  final TextEditingController _brandCtrl = TextEditingController();
  final TextEditingController _detailCtrl = TextEditingController();

  String? _selectedImagePath;

  // Listas Sincronizadas
  final List<String> _categories = [
    "Camiseta",
    "Camiseta Polo",
    "Camisa",
    "Camisa Formal",
    "Blusa",
    "Jersey",
    "Suéter",
    "Sudadera",
    "Chaqueta",
    "Abrigo",
    "Saco",
    "Chaleco",
    "Jeans",
    "Pantalón",
    "Jogger",
    "Short",
    "Falda",
    "Vestido",
    "Traje",
    "Tenis",
    "Zapato",
    "Bota",
    "Sandalia",
    "Tacones",
    "Lentes",
    "Gorra",
    "Sombrero",
    "Cinturón",
    "Corbata",
    "Bolso",
    "Mochila",
    "Billetera",
    "Reloj",
    "Almohada",
    "Ropa de Cama",
    "Toalla",
    "Botella",
    "Taza",
    "Copa",
    "Vaso",
    "Sartén",
    "Olla",
    "Juguete",
    "Muñeca",
  ];

  final List<String> _brands = [
    "Nike",
    "Adidas",
    "Puma",
    "Reebok",
    "Under Armour",
    "Fila",
    "Asics",
    "Zara",
    "H&M",
    "Levis",
    "Calvin Klein",
    "Tommy Hilfiger",
    "Gucci",
    "Lacoste",
    "Shein",
    "Carter's",
    "Samsung",
    "Apple",
    "Sony",
    "LG",
    "Huawei",
    "Dell",
    "HP",
    "Lenovo",
    "Jingo",
    "Generico",
    "Totto",
    "Disney",
    "Marvel",
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(appBarProvider.notifier)
          .setOptions(title: "Nuevo Producto", showBackButton: true);
    });

    _categoryCtrl.addListener(_updateSmartName);
    _brandCtrl.addListener(_updateSmartName);
    _detailCtrl.addListener(_updateSmartName);
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
    List<String> parts = [];
    if (_categoryCtrl.text.isNotEmpty) parts.add(_categoryCtrl.text);
    if (_brandCtrl.text.isNotEmpty &&
        _brandCtrl.text.toLowerCase() != "generico")
      parts.add(_brandCtrl.text);
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
        if (result['imagePath'] != null)
          _selectedImagePath = result['imagePath'];

        String cat = result['categoria'] ?? "";
        String brand = result['marca'] ?? "";
        String detail = result['detalle'] ?? "";

        if (cat.isNotEmpty) _categoryCtrl.text = cat;
        if (brand.isNotEmpty) _brandCtrl.text = brand;
        if (detail.isNotEmpty) _detailCtrl.text = detail;

        List<String> nameParts = [];
        if (cat.isNotEmpty) nameParts.add(cat);
        if (brand.isNotEmpty && brand.toLowerCase() != "generico")
          nameParts.add(brand);
        if (detail.isNotEmpty) {
          String formattedDetail =
              detail[0].toUpperCase() + detail.substring(1);
          nameParts.add(formattedDetail);
        }
        _nameController.text = nameParts.join(" ");
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Producto identificado: ${_nameController.text}"),
            backgroundColor: _primaryColor, // Feedback con tu color
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],

      // ✅ BOTÓN CON COLOR CYAN
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _submitProductBase,
        label: const Text(
          "Guardar Producto",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        icon: const Icon(Icons.save, color: Colors.white),
        backgroundColor: _primaryColor, // Cyan Shade 800
      ),

      // ✅ CIERRE AL DAR CLIC FUERA
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
                  onTap: _openMagicCamera,
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
                              color: Colors.black12,
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
                                  // Icono Cyan
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
                      if (_selectedImagePath != null)
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
                    _OpenAutocompleteField(
                      controller: _categoryCtrl,
                      label: "Categoría",
                      options: _categories,
                      icon: Icons.category_outlined,
                    ),
                    const SizedBox(height: 20),
                    _OpenAutocompleteField(
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

              // ✅ NOMBRE EDITABLE CON ESTILO CYAN
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  // Fondo Cyan muy suave
                  color: Colors.cyan.shade50.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  // Borde Cyan suave
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
                    // Label Cyan oscuro
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

  void _submitProductBase() {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Falta el nombre del producto")),
      );
      return;
    }
    // Lógica para guardar
    print(
      "Guardando Producto: ${_nameController.text} | Foto: $_selectedImagePath",
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Producto Guardado"),
        backgroundColor: _primaryColor,
      ),
    );
  }
}

// --- WIDGET AUTOCOMPLETE (Sin Cambios Internos) ---
class _OpenAutocompleteField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final List<String> options;
  final IconData icon;

  const _OpenAutocompleteField({
    required this.controller,
    required this.label,
    required this.options,
    required this.icon,
  });

  @override
  State<_OpenAutocompleteField> createState() => _OpenAutocompleteFieldState();
}

class _OpenAutocompleteFieldState extends State<_OpenAutocompleteField> {
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return RawAutocomplete<String>(
          textEditingController: widget.controller,
          focusNode: _focusNode,
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text == '') return widget.options;
            return widget.options.where((String option) {
              return option.toLowerCase().contains(
                textEditingValue.text.toLowerCase(),
              );
            });
          },
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
            return TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                labelText: widget.label,
                filled: true,
                fillColor: Colors.grey[50],
                prefixIcon: Icon(
                  widget.icon,
                  size: 20,
                  color: Colors.grey[500],
                ),
                suffixIcon: const Icon(
                  Icons.arrow_drop_down,
                  color: Colors.grey,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                // Cuando se enfoca, el borde se pone Cyan
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.cyan.shade800, width: 2),
                ),
              ),
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4.0,
                color: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(12),
                  ),
                ),
                child: Container(
                  width: constraints.maxWidth,
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final option = options.elementAt(index);
                      return InkWell(
                        onTap: () => onSelected(option),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(option),
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
