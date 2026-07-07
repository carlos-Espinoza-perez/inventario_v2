import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:inventario_v2/core/db/app_database.dart';
import 'package:inventario_v2/features/secretary/data/entity_resolver.dart';
import 'package:inventario_v2/features/secretary/domain/models/assistant_operational_context.dart';
import 'package:uuid/uuid.dart';

import 'adapters/draft_type_adapter.dart';

/// Ítem crudo tal como llega del dictado o del LLM.
class RawDraftItem {
  final String nombre;
  final double cantidad;
  final double? costoUnitario;
  final double? precioUnitario;

  const RawDraftItem({
    required this.nombre,
    required this.cantidad,
    this.costoUnitario,
    this.precioUnitario,
  });

  factory RawDraftItem.fromJson(Map<String, dynamic> j) => RawDraftItem(
        nombre: j['nombre']?.toString() ?? '',
        cantidad: (j['cantidad'] as num?)?.toDouble() ?? 0,
        costoUnitario: (j['costoUnitario'] as num?)?.toDouble(),
        precioUnitario: (j['precioUnitario'] as num?)?.toDouble(),
      );
}

/// Motor genérico de borradores: crea/edita tablas temporales y delega la
/// validación y ejecución en el adapter del tipo (entrada, venta, ...).
class DraftEngine {
  final AppDatabase _db;
  final EntityResolver _resolver;
  final Map<String, DraftTypeAdapter> _adapters;

  DraftEngine({
    required AppDatabase db,
    required EntityResolver resolver,
    required List<DraftTypeAdapter> adapters,
  })  : _db = db,
        _resolver = resolver,
        _adapters = {for (final a in adapters) a.type: a};

  bool supportsType(String draftType) => _adapters.containsKey(draftType);

  DraftTypeAdapter _adapterFor(String draftType) {
    final adapter = _adapters[draftType];
    if (adapter == null) {
      throw ArgumentError('Tipo de borrador no soportado: $draftType');
    }
    return adapter;
  }

  Future<SecretaryDraft> createDraft({
    required String draftType,
    String? sessionId,
    String? bodegaId,
    String? clienteNombre,
    String? saleType,
    String? descripcion,
  }) {
    _adapterFor(draftType);
    final meta = <String, dynamic>{
      if (clienteNombre != null) 'clienteNombre': clienteNombre,
      if (saleType != null) 'saleType': saleType,
      if (descripcion != null) 'descripcion': descripcion,
    };
    return _db.secretaryDao.createDraft(
      draftType: draftType,
      sessionId: sessionId,
      bodegaId: bodegaId,
      metaJson: meta.isEmpty ? null : jsonEncode(meta),
    );
  }

  /// Agrega ítems resolviendo cada producto contra el catálogo local.
  /// Ambiguos o no encontrados quedan en `needs_review` sin frenar el flujo.
  Future<List<SecretaryDraftItem>> addItems({
    required String draftId,
    required List<RawDraftItem> rawItems,
    required AssistantOperationalContext context,
  }) async {
    final draft = await _db.secretaryDao.getDraftById(draftId);
    if (draft == null) throw StateError('Borrador $draftId no existe.');
    final adapter = _adapterFor(draft.draftType);

    final inserted = <SecretaryDraftItem>[];
    for (final raw in rawItems) {
      if (raw.nombre.trim().isEmpty || raw.cantidad <= 0) continue;

      final resolution = await _resolver.resolveProduct(
        raw.nombre,
        empresaId: context.empresaId,
      );

      String status;
      String? productId;
      String? resolvedName;
      String? candidatesJson;
      double? unitCost = raw.costoUnitario;
      double? unitPrice = raw.precioUnitario;

      if (resolution.isResolved) {
        final producto = resolution.selected!;
        status = 'ready';
        productId = producto.id;
        resolvedName = producto.nombre;
        unitCost ??= adapter.defaultUnitCost(producto);
        unitPrice ??= adapter.defaultUnitPrice(producto);
      } else if (resolution.isAmbiguous) {
        status = 'needs_review';
        candidatesJson = jsonEncode([
          for (final c in resolution.candidates.take(5))
            {
              'id': c.id,
              'nombre': c.nombre,
              'precioBase': c.precioBase,
              'ultimoCosto': c.ultimoCosto,
              'ultimoPrecioVenta': c.ultimoPrecioVenta,
            },
        ]);
      } else {
        status = 'needs_review';
      }

      final item = await _db.secretaryDao.insertDraftItem(
        SecretaryDraftItemsCompanion.insert(
          id: const Uuid().v4(),
          draftId: draftId,
          productId: Value(productId),
          proposedName: raw.nombre,
          resolvedName: Value(resolvedName),
          quantity: raw.cantidad,
          unitCost: Value(unitCost),
          unitPrice: Value(unitPrice),
          status: Value(status),
          candidatesJson: Value(candidatesJson),
        ),
      );
      inserted.add(item);
    }
    return inserted;
  }

  Future<void> updateItem(
    String itemId, {
    double? cantidad,
    double? costoUnitario,
    double? precioUnitario,
    String? productoId,
    String? resolvedName,
  }) {
    return _db.secretaryDao.updateDraftItem(
      itemId,
      SecretaryDraftItemsCompanion(
        quantity: cantidad != null ? Value(cantidad) : const Value.absent(),
        unitCost:
            costoUnitario != null ? Value(costoUnitario) : const Value.absent(),
        unitPrice: precioUnitario != null
            ? Value(precioUnitario)
            : const Value.absent(),
        productId: productoId != null ? Value(productoId) : const Value.absent(),
        resolvedName:
            resolvedName != null ? Value(resolvedName) : const Value.absent(),
        // Si se asigna producto, la fila queda lista.
        status: productoId != null ? const Value('ready') : const Value.absent(),
        candidatesJson:
            productoId != null ? const Value(null) : const Value.absent(),
      ),
    );
  }

  Future<void> removeItem(String itemId) =>
      _db.secretaryDao.removeDraftItem(itemId);

  Future<void> setHeader(
    String draftId, {
    String? bodegaId,
    String? clienteNombre,
    String? saleType,
    String? descripcion,
  }) async {
    final draft = await _db.secretaryDao.getDraftById(draftId);
    if (draft == null) throw StateError('Borrador $draftId no existe.');

    final meta = draft.metaJson != null
        ? Map<String, dynamic>.from(jsonDecode(draft.metaJson!))
        : <String, dynamic>{};
    if (clienteNombre != null) meta['clienteNombre'] = clienteNombre;
    if (saleType != null) meta['saleType'] = saleType;
    if (descripcion != null) meta['descripcion'] = descripcion;

    await _db.secretaryDao.updateDraft(
      draftId,
      SecretaryDraftsCompanion(
        bodegaId: bodegaId != null ? Value(bodegaId) : const Value.absent(),
        metaJson: Value(meta.isEmpty ? null : jsonEncode(meta)),
      ),
    );
  }

  Future<void> discard(String draftId) {
    return _db.secretaryDao.updateDraft(
      draftId,
      const SecretaryDraftsCompanion(status: Value('discarded')),
    );
  }

  /// Errores de validación previos a ejecutar (lista vacía = listo).
  Future<List<String>> validate(String draftId) async {
    final draft = await _db.secretaryDao.getDraftById(draftId);
    if (draft == null) return ['El borrador no existe.'];
    final items = await _db.secretaryDao.getDraftItems(draftId);

    final errors = <String>[];
    if (items.isEmpty) errors.add('El borrador no tiene ítems.');
    final pendientes =
        items.where((i) => i.status != 'ready' || i.productId == null).length;
    if (pendientes > 0) {
      errors.add('$pendientes ítem(s) pendientes de revisar/resolver.');
    }
    if (items.any((i) => i.quantity <= 0)) {
      errors.add('Hay ítems con cantidad inválida.');
    }
    errors.addAll(_adapterFor(draft.draftType).validate(draft, items));
    return errors;
  }

  /// Ejecuta la transacción real. Requiere confirmación previa del usuario
  /// (la UI solo llama esto desde el botón Confirmar).
  Future<String> execute(
    String draftId,
    AssistantOperationalContext context,
  ) async {
    final errors = await validate(draftId);
    if (errors.isNotEmpty) {
      throw StateError(errors.join(' '));
    }
    final draft = (await _db.secretaryDao.getDraftById(draftId))!;
    final items = await _db.secretaryDao.getDraftItems(draftId);

    final resultRef =
        await _adapterFor(draft.draftType).execute(draft, items, context);

    await _db.secretaryDao.updateDraft(
      draftId,
      SecretaryDraftsCompanion(
        status: const Value('executed'),
        resultRefId: Value(resultRef),
      ),
    );
    return resultRef;
  }
}
