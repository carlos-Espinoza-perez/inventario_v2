/// Utilidades para validación de UUIDs
class UuidValidator {
  UuidValidator._();

  /// Expresión regular para validar formato UUID v4
  static final RegExp _uuidRegex = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
    caseSensitive: false,
  );

  /// Valida si un string es un UUID válido
  /// 
  /// Retorna `true` si el valor es un UUID v4 válido.
  /// Retorna `false` si es null, vacío o no cumple el formato.
  static bool isValidUUID(String? value) {
    if (value == null || value.isEmpty) return false;
    return _uuidRegex.hasMatch(value);
  }

  /// Valida si un string es un UUID válido o null
  /// 
  /// Útil para campos opcionales que pueden ser null pero si tienen valor
  /// debe ser un UUID válido.
  static bool isValidUUIDOrNull(String? value) {
    if (value == null) return true;
    return isValidUUID(value);
  }

  /// Valida múltiples UUIDs
  /// 
  /// Retorna `true` solo si todos los valores son UUIDs válidos.
  static bool areValidUUIDs(List<String?> values) {
    return values.every((value) => isValidUUID(value));
  }
}
