import 'package:flutter_riverpod/flutter_riverpod.dart';

// Constante para evitar errores de escritura (typos)
const String kFiltroBajoStock = 'bajo_stock';

// --- PROVIDER GLOBAL DE SELECCIÓN ---
// null = "Todos"
// kFiltroBajoStock = "Bajo Stock"
// "uuid-..." = ID de una categoría específica
final filtroCategoriaSeleccionadoProvider = StateProvider<String?>(
  (ref) => null,
);
