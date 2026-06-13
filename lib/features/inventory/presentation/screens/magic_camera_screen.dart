import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:go_router/go_router.dart';
import 'package:inventario_v2/core/services/app_logger.dart';

// -----------------------------------------------------------------------------
// 🧠 BASE DE DATOS LÓGICA (Tu diccionario)
// -----------------------------------------------------------------------------
class _ProductDatabase {
  // MARCAS
  static const List<String> knownBrands = [
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
    "Carter's",
  ];

  // CATEGORÍAS (Ordenado por especificidad)
  static const Map<String, String> categoryMap = {
    // Lentes (Evitar confusión con glass)
    'sunglasses': 'Lentes',
    'eyeglasses': 'Lentes',
    'spectacles': 'Lentes',
    'goggles': 'Lentes',

    // Ropa
    't-shirt': 'Camiseta', 'tee': 'Camiseta', 'polo': 'Camiseta Polo',
    'shirt': 'Camisa', 'blouse': 'Blusa', 'top': 'Blusa',
    'jersey': 'Jersey', 'sweater': 'Suéter', 'hoodie': 'Sudadera',
    'jacket': 'Chaqueta', 'coat': 'Abrigo', 'blazer': 'Saco', 'vest': 'Chaleco',
    'jeans': 'Jeans',
    'pants': 'Pantalón',
    'trousers': 'Pantalón',
    'joggers': 'Jogger',
    'shorts': 'Short', 'skirt': 'Falda', 'dress': 'Vestido', 'suit': 'Traje',

    // Calzado
    'sneaker': 'Tenis',
    'shoe': 'Zapato',
    'boot': 'Bota',
    'sandal': 'Sandalia',
    'heels': 'Tacones',

    // Accesorios
    'cap': 'Gorra',
    'hat': 'Sombrero',
    'belt': 'Cinturón',
    'bag': 'Bolso',
    'backpack': 'Mochila',
    'wallet': 'Billetera', 'watch': 'Reloj',

    // Hogar
    'pillow': 'Almohada', 'bedding': 'Ropa de Cama', 'towel': 'Toalla',
    'bottle': 'Botella', 'mug': 'Taza',
    'toy': 'Juguete', 'doll': 'Muñeca',
    // Palabras peligrosas al final
    'pan': 'Sartén', 'pot': 'Olla',
    'wine glass': 'Copa', 'glass': 'Vaso',
  };

  // RASGOS
  static const Map<String, String> visualTraitsMap = {
    'floral': 'Floreado',
    'pattern': 'Estampado',
    'striped': 'Rayado',
    'plaid': 'Cuadros',
    'dot': 'Lunares',
    'camo': 'Camuflaje',
    'graphic': 'Gráfico',
    'denim': 'Mezclilla',
    'leather': 'Cuero',
    'cotton': 'Algodón',
    'knit': 'Tejido',
    'black': 'Negro',
    'white': 'Blanco',
    'red': 'Rojo',
    'blue': 'Azul',
    'green': 'Verde',
    'yellow': 'Amarillo',
    'pink': 'Rosado',
    'purple': 'Morado',
  };
}

// -----------------------------------------------------------------------------
// 📸 PANTALLA: FOTO -> ANÁLISIS
// -----------------------------------------------------------------------------
class MagicCameraScreen extends StatefulWidget {
  const MagicCameraScreen({super.key});

  @override
  State<MagicCameraScreen> createState() => _MagicCameraScreenState();
}

class _MagicCameraScreenState extends State<MagicCameraScreen> {
  CameraController? _controller;
  bool _isAnalyzing = false; // Estado de carga (Loading)

  late ImageLabeler _imageLabeler;
  late TextRecognizer _textRecognizer;

  @override
  void initState() {
    super.initState();
    // Configuración de ML Kit
    // Usamos 0.60 para permitir más etiquetas, luego filtraremos con el diccionario.
    final options = ImageLabelerOptions(confidenceThreshold: 0.60);
    _imageLabeler = ImageLabeler(options: options);
    _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final camera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    // Resolución HIGH en lugar de MAX para evitar memory exceptions
    _controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
    );

    await _controller!.initialize();
    if (mounted) setState(() {});
  }

  // --- LÓGICA PRINCIPAL: TOMAR Y ANALIZAR ---
  Future<void> _takePhotoAndAnalyze() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _isAnalyzing) {
      return;
    }

    setState(() => _isAnalyzing = true); // Mostrar Spinner

    try {
      // 1. Tomar la foto en Alta Resolución
      final XFile photo = await _controller!.takePicture();

      // 2. Crear InputImage desde ARCHIVO (Es más seguro que desde bytes)
      final inputImage = InputImage.fromFilePath(photo.path);

      // 3. Ejecutar Análisis IA (Paralelo para velocidad)
      final Future<List<ImageLabel>> labelsFuture = _imageLabeler.processImage(
        inputImage,
      );
      final Future<RecognizedText> textFuture = _textRecognizer.processImage(
        inputImage,
      );

      final results = await Future.wait([labelsFuture, textFuture]);
      final labels = results[0] as List<ImageLabel>;
      final text = results[1] as RecognizedText;

      // 4. Procesar Resultados con "Lógica Estricta"
      String detectedCategory = "";
      String detectedBrand = "";
      Set<String> detectedTraits = {};

      // A. Categoría (Visual)
      for (var label in labels) {
        String tag = label.label.toLowerCase();

        // Prioridad 1: Buscar coincidencia exacta (Regex)
        for (var key in _ProductDatabase.categoryMap.keys) {
          final RegExp exactWord = RegExp(r'\b' + RegExp.escape(key) + r'\b');
          if (exactWord.hasMatch(tag)) {
            detectedCategory = _ProductDatabase.categoryMap[key]!;
            break;
          }
          // Fallback para palabras compuestas (ej: running shoe)
          if (key.contains(' ') && tag.contains(key)) {
            detectedCategory = _ProductDatabase.categoryMap[key]!;
            break;
          }
        }
        if (detectedCategory.isNotEmpty) {
          break; // Ya encontramos la categoría principal
        }
      }

      // B. Rasgos Visuales (Detalles)
      for (var label in labels) {
        String tag = label.label.toLowerCase();
        for (var key in _ProductDatabase.visualTraitsMap.keys) {
          if (tag.contains(key)) {
            detectedTraits.add(_ProductDatabase.visualTraitsMap[key]!);
          }
        }
      }

      // C. Marca (Texto OCR)
      String fullText = text.text.toLowerCase();
      for (var brand in _ProductDatabase.knownBrands) {
        final RegExp brandRegex = RegExp(
          r'\b' + RegExp.escape(brand.toLowerCase()) + r'\b',
        );
        if (brandRegex.hasMatch(fullText)) {
          detectedBrand = brand;
          break;
        }
      }

      // 5. Devolver resultados
      if (mounted) {
        context.pop({
          'categoria': detectedCategory,
          'marca': detectedBrand,
          'detalle': detectedTraits.take(3).join(", "), // Máximo 3 rasgos
          'imagePath': photo.path, // Devolvemos la foto HD
        });
      }
    } catch (e, st) {
      AppLogger.error("Error analizando foto", e, st);
      if (mounted) {
        setState(() => _isAnalyzing = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _imageLabeler.close();
    _textRecognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1. Si no está lista, mostramos carga
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // 2. CÁLCULO MATEMÁTICO PARA CORREGIR LA DISTORSIÓN
    final size = MediaQuery.of(context).size;
    final deviceRatio = size.width / size.height;

    // Obtenemos el ratio de la cámara (invertimos porque el sensor suele estar en landscape)
    // Nota: scale siempre debe ser >= 1 para evitar bordes negros
    double scale = 1.0;

    // La lógica: si la pantalla es más "flaca" que la cámara, escalamos la altura.
    // Si la pantalla es más "gorda", escalamos la anchura.
    // Este cálculo asume que estás en modo Retrato (Portrait).
    final cameraAspectRatio = _controller!.value.aspectRatio;
    scale = 1 / (cameraAspectRatio * deviceRatio);

    // Si el cálculo da menos de 1, invertimos para asegurar que haga zoom (cover)
    if (scale < 1) scale = 1 / scale;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. CÁMARA CON CORRECCIÓN DE ESCALA (Transform.scale)
          Center(
            child: Transform.scale(
              scale: scale,
              child: CameraPreview(_controller!),
            ),
          ),

          // 2. INTERFAZ (Igual que antes)
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.black45,
                        child: const BackButton(color: Colors.white),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),

                const Spacer(),

                // BOTÓN DE DISPARO
                Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: _isAnalyzing
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 15),
                              Text(
                                "Analizando...",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        )
                      : GestureDetector(
                          onTap: _takePhotoAndAnalyze,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4),
                              color: Colors.white24,
                            ),
                            child: Container(
                              margin: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                ),

                if (!_isAnalyzing)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: Text(
                      "Toma la foto",
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
