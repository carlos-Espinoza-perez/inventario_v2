import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:inventario_v2/core/db/app_database.dart';
import 'package:inventario_v2/features/assistant/domain/models/assistant_entry_models.dart';

class AssistantEntryDraftRepository {
  final AppDatabase _db;
  static const _uuid = Uuid();

  AssistantEntryDraftRepository(this._db);

  Future<AssistantEntrySession> startOrResume({
    required String empresaId,
    required String usuarioId,
    required String bodegaId,
  }) async {
    final existing =
        await (_db.select(_db.assistantEntrySessions)
              ..where((tbl) => tbl.empresaId.equals(empresaId))
              ..where((tbl) => tbl.usuarioId.equals(usuarioId))
              ..where((tbl) => tbl.bodegaId.equals(bodegaId))
              ..where((tbl) => tbl.status.equals('active'))
              ..orderBy([(tbl) => OrderingTerm.desc(tbl.updatedAt)])
              ..limit(1))
            .getSingleOrNull();
    if (existing != null) return existing;

    final now = DateTime.now();
    final id = _uuid.v4();
    await _db
        .into(_db.assistantEntrySessions)
        .insert(
          AssistantEntrySessionsCompanion.insert(
            id: id,
            empresaId: empresaId,
            usuarioId: usuarioId,
            bodegaId: bodegaId,
            status: const Value('active'),
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );
    return (_db.select(
      _db.assistantEntrySessions,
    )..where((tbl) => tbl.id.equals(id))).getSingle();
  }

  Future<AssistantEntrySession?> getActive({
    required String empresaId,
    required String usuarioId,
    required String bodegaId,
  }) {
    return (_db.select(_db.assistantEntrySessions)
          ..where((tbl) => tbl.empresaId.equals(empresaId))
          ..where((tbl) => tbl.usuarioId.equals(usuarioId))
          ..where((tbl) => tbl.bodegaId.equals(bodegaId))
          ..where((tbl) => tbl.status.equals('active'))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.updatedAt)])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<AssistantEntryDraftLine> addItem({
    required String sessionId,
    required String proposedName,
    required String? productId,
    required String? resolvedName,
    required String? categoryId,
    required String? categoryName,
    required double quantity,
    required double? unitCost,
    required double? unitPrice,
    required bool isNewProduct,
    List<String> candidates = const [],
  }) async {
    final status = _statusFor(
      productId: productId,
      categoryName: categoryName,
      quantity: quantity,
      unitCost: unitCost,
      unitPrice: unitPrice,
      candidates: candidates,
    );
    final now = DateTime.now();
    final id = _uuid.v4();
    await _db
        .into(_db.assistantEntrySessionItems)
        .insert(
          AssistantEntrySessionItemsCompanion.insert(
            id: id,
            sessionId: sessionId,
            productId: Value(productId),
            proposedName: proposedName,
            resolvedName: Value(resolvedName),
            categoryId: Value(categoryId),
            categoryName: Value(categoryName),
            quantity: quantity,
            unitCost: Value(unitCost),
            unitPrice: Value(unitPrice),
            status: Value(status),
            candidatesJson: Value(
              candidates.isEmpty ? null : jsonEncode(candidates),
            ),
            isNewProduct: Value(isNewProduct),
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );
    await touchSession(sessionId);
    return (await getDraft(
      sessionId,
    )).lines.firstWhere((line) => line.id == id);
  }

  Future<void> updateCategory({
    required String sessionId,
    required String categoryId,
    required String categoryName,
  }) async {
    final latest = await _latestItem(sessionId);
    if (latest == null) return;
    await (_db.update(
      _db.assistantEntrySessionItems,
    )..where((tbl) => tbl.id.equals(latest.id))).write(
      AssistantEntrySessionItemsCompanion(
        categoryId: Value(categoryId),
        categoryName: Value(categoryName),
        status: Value(
          _statusFor(
            productId: latest.productId,
            categoryName: categoryName,
            quantity: latest.quantity,
            unitCost: latest.unitCost,
            unitPrice: latest.unitPrice,
            candidates: _decodeCandidates(latest.candidatesJson),
          ),
        ),
        updatedAt: Value(DateTime.now()),
      ),
    );
    await touchSession(sessionId);
  }

  Future<void> markSessionConfirmed(String sessionId) async {
    await _markSession(sessionId, 'confirmed');
  }

  Future<void> cancelSession(String sessionId) async {
    await _markSession(sessionId, 'cancelled');
  }

  Future<void> touchSession(String sessionId) {
    return (_db.update(
      _db.assistantEntrySessions,
    )..where((tbl) => tbl.id.equals(sessionId))).write(
      AssistantEntrySessionsCompanion(updatedAt: Value(DateTime.now())),
    );
  }

  Future<AssistantEntrySessionDraft> getDraft(String sessionId) async {
    final session = await (_db.select(
      _db.assistantEntrySessions,
    )..where((tbl) => tbl.id.equals(sessionId))).getSingle();
    final items =
        await (_db.select(_db.assistantEntrySessionItems)
              ..where((tbl) => tbl.sessionId.equals(sessionId))
              ..orderBy([(tbl) => OrderingTerm.asc(tbl.createdAt)]))
            .get();

    return AssistantEntrySessionDraft(
      sessionId: session.id,
      bodegaId: session.bodegaId,
      lines: items.map(_mapItem).toList(),
    );
  }

  Future<AssistantEntrySessionItem?> _latestItem(String sessionId) {
    return (_db.select(_db.assistantEntrySessionItems)
          ..where((tbl) => tbl.sessionId.equals(sessionId))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<void> _markSession(String sessionId, String status) {
    return (_db.update(
      _db.assistantEntrySessions,
    )..where((tbl) => tbl.id.equals(sessionId))).write(
      AssistantEntrySessionsCompanion(
        status: Value(status),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  AssistantEntryDraftLine _mapItem(AssistantEntrySessionItem item) {
    return AssistantEntryDraftLine(
      id: item.id,
      productId: item.productId,
      proposedName: item.proposedName,
      displayName: item.resolvedName ?? item.proposedName,
      categoryId: item.categoryId,
      categoryName: item.categoryName,
      quantity: item.quantity,
      unitCost: item.unitCost,
      unitPrice: item.unitPrice,
      status: item.status,
      isNewProduct: item.isNewProduct,
      candidates: _decodeCandidates(item.candidatesJson),
    );
  }

  List<String> _decodeCandidates(String? raw) {
    if (raw == null || raw.isEmpty) return const [];
    try {
      return (jsonDecode(raw) as List).whereType<String>().toList();
    } catch (_) {
      return const [];
    }
  }

  String _statusFor({
    required String? productId,
    required String? categoryName,
    required double quantity,
    required double? unitCost,
    required double? unitPrice,
    required List<String> candidates,
  }) {
    if (candidates.isNotEmpty) return 'needs_product_selection';
    if (quantity <= 0) return 'needs_quantity';
    if (categoryName == null || categoryName.trim().isEmpty) {
      return 'needs_category';
    }
    if (unitCost == null) return 'needs_cost';
    if (unitPrice == null) return 'needs_price';
    return 'ready';
  }
}
