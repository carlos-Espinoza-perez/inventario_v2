import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventario_v2/core/db/app_database.dart';
import 'package:inventario_v2/core/providers/drift_provider.dart';
import 'package:inventario_v2/features/secretary/data/entity_resolver.dart';

import '../../drafts/adapters/entrada_draft_adapter.dart';
import '../../drafts/adapters/venta_draft_adapter.dart';
import '../../drafts/draft_engine.dart';

final draftEngineProvider = Provider<DraftEngine>((ref) {
  final db = ref.watch(driftDatabaseProvider);
  return DraftEngine(
    db: db,
    resolver: EntityResolver(db),
    adapters: [
      EntradaDraftAdapter(ref),
      VentaDraftAdapter(ref),
    ],
  );
});

/// Cabecera del borrador, reactiva (estado, bodega, meta).
final draftProvider =
    StreamProvider.family<SecretaryDraft?, String>((ref, draftId) {
  return ref.watch(driftDatabaseProvider).secretaryDao.watchDraft(draftId);
});

/// Ítems del borrador, reactivos (el dictado y la edición manual convergen acá).
final draftItemsProvider =
    StreamProvider.family<List<SecretaryDraftItem>, String>((ref, draftId) {
  return ref
      .watch(driftDatabaseProvider)
      .secretaryDao
      .watchDraftItems(draftId);
});
