import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventario_v2/core/providers/supabase_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'knowledge_models.dart';

class WorkflowLoader {
  final SupabaseClient _supabase;

  static final Map<String, WorkflowDefinition> _workflowCache = {};
  static IntentCatalog? _intentCatalogCache;
  static List<ToolDefinition>? _toolsCatalogCache;

  WorkflowLoader(this._supabase);

  Future<IntentCatalog> loadIntentCatalog() async {
    if (_intentCatalogCache != null) return _intentCatalogCache!;

    final rows = await _supabase
        .from('assistant_intent_catalog')
        .select()
        .eq('active', true);

    _intentCatalogCache = IntentCatalog.fromRows(
      List<Map<String, dynamic>>.from(rows),
    );
    return _intentCatalogCache!;
  }

  Future<WorkflowDefinition> load(String workflowId) async {
    if (_workflowCache.containsKey(workflowId)) {
      return _workflowCache[workflowId]!;
    }

    final row = await _supabase
        .from('assistant_workflows')
        .select('definition')
        .eq('id', workflowId)
        .eq('active', true)
        .single();

    final definition = WorkflowDefinition.fromJson(
      row['definition'] as Map<String, dynamic>,
    );
    _workflowCache[workflowId] = definition;
    return definition;
  }

  Future<List<ToolDefinition>> loadToolsCatalog() async {
    if (_toolsCatalogCache != null) return _toolsCatalogCache!;

    final rows = await _supabase
        .from('assistant_tools_catalog')
        .select()
        .eq('active', true);

    _toolsCatalogCache = List<Map<String, dynamic>>.from(rows)
        .map((r) => ToolDefinition.fromJson(r))
        .toList();
    return _toolsCatalogCache!;
  }

  static void invalidateCache() {
    _workflowCache.clear();
    _intentCatalogCache = null;
    _toolsCatalogCache = null;
  }
}

final workflowLoaderProvider = Provider<WorkflowLoader>((ref) {
  return WorkflowLoader(ref.watch(supabaseClientProvider));
});
