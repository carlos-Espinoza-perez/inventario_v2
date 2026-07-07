import 'package:inventario_v2/core/db/app_database.dart';
import 'package:inventario_v2/features/secretary/domain/models/assistant_operational_context.dart';

/// Contrato de cada tipo de borrador (entrada, venta, ajuste, ...).
/// Agregar un tipo nuevo = implementar esta clase, sin tocar el DraftEngine.
abstract class DraftTypeAdapter {
  /// 'entrada' | 'venta' | 'ajuste' | 'transferencia'
  String get type;

  /// Costo por defecto al resolver un producto sin costo dictado.
  double? defaultUnitCost(Producto producto);

  /// Precio por defecto al resolver un producto sin precio dictado.
  double? defaultUnitPrice(Producto producto);

  /// Validaciones específicas del tipo (además de las genéricas del motor).
  List<String> validate(SecretaryDraft draft, List<SecretaryDraftItem> items);

  /// Ejecuta la transacción real y devuelve una referencia del resultado.
  Future<String> execute(
    SecretaryDraft draft,
    List<SecretaryDraftItem> items,
    AssistantOperationalContext context,
  );
}
