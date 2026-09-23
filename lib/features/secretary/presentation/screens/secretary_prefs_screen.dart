import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inventario_v2/core/db/app_database.dart';
import 'package:inventario_v2/core/presentation/mixins/app_bar_config_mixin.dart';
import 'package:inventario_v2/core/providers/app_bar_provider.dart';
import 'package:inventario_v2/core/providers/drift_provider.dart';

import '../../voice/voice_session_controller.dart'
    show
        voicePauseMsFromPrefs,
        toolAnnounceFromPrefs,
        voiceConfirmFromPrefs,
        listenModeFromPrefs,
        ListenMode;

/// Preferencias del secretario + curación de memorias. Los cambios se
/// guardan al instante y sincronizan (ai_preferences / ai_memories).
class SecretaryPrefsScreen extends ConsumerStatefulWidget {
  const SecretaryPrefsScreen({super.key});

  @override
  ConsumerState<SecretaryPrefsScreen> createState() =>
      _SecretaryPrefsScreenState();
}

class _SecretaryPrefsScreenState extends ConsumerState<SecretaryPrefsScreen>
    with AppBarConfigMixin {
  AiPreference? _prefs;
  List<Bodega> _bodegas = const [];
  List<AiMemory> _memories = const [];
  bool _loading = true;

  @override
  void configureAppBar() {
    ref
        .read(appBarProvider.notifier)
        .setOptions(title: 'Preferencias del secretario', showBackButton: true);
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(configureAppBar);
    _load();
  }

  Future<void> _load() async {
    final db = ref.read(driftDatabaseProvider);
    final prefs = await db.secretaryDao.getOrCreatePreferences();
    final bodegas = await db.authDao.getActiveBodegasByEmpresa(prefs.empresaId);
    final memories = await db.secretaryDao.getActiveMemories(
      empresaId: prefs.empresaId,
      usuarioId: prefs.usuarioId,
    );
    if (!mounted) return;
    setState(() {
      _prefs = prefs;
      _bodegas = bodegas;
      _memories = memories;
      _loading = false;
    });
  }

  Future<void> _save(AiPreferencesCompanion changes) async {
    final prefs = _prefs;
    if (prefs == null) return;
    final db = ref.read(driftDatabaseProvider);
    await db.secretaryDao.updatePreferences(prefs.id, changes);
    final updated = await db.secretaryDao.getPreferences(
      empresaId: prefs.empresaId,
      usuarioId: prefs.usuarioId,
    );
    if (mounted && updated != null) setState(() => _prefs = updated);
  }

  /// Guarda una clave dentro de extraJson preservando las demás.
  Future<void> _saveExtra(String key, Object value) async {
    final prefs = _prefs;
    if (prefs == null) return;
    Map<String, dynamic> extra;
    try {
      extra = prefs.extraJson != null
          ? Map<String, dynamic>.from(jsonDecode(prefs.extraJson!))
          : <String, dynamic>{};
    } catch (_) {
      extra = <String, dynamic>{};
    }
    extra[key] = value;
    await _save(AiPreferencesCompanion(extraJson: Value(jsonEncode(extra))));
  }

  @override
  Widget build(BuildContext context) {
    final prefs = _prefs;
    return Scaffold(
      body: _loading || prefs == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(12),
              children: [
                _sectionTitle(context, 'Estilo'),
                ListTile(
                  title: const Text('Tono'),
                  trailing: DropdownButton<String>(
                    value: prefs.tone,
                    items: const [
                      DropdownMenuItem(value: 'formal', child: Text('Formal')),
                      DropdownMenuItem(
                        value: 'neutral',
                        child: Text('Neutral'),
                      ),
                      DropdownMenuItem(value: 'casual', child: Text('Cercano')),
                    ],
                    onChanged: (v) => v != null
                        ? _save(AiPreferencesCompanion(tone: Value(v)))
                        : null,
                  ),
                ),
                ListTile(
                  title: const Text('Largo de respuestas'),
                  trailing: DropdownButton<String>(
                    value: prefs.verbosity,
                    items: const [
                      DropdownMenuItem(value: 'concise', child: Text('Breves')),
                      DropdownMenuItem(
                        value: 'normal',
                        child: Text('Normales'),
                      ),
                      DropdownMenuItem(
                        value: 'detailed',
                        child: Text('Detalladas'),
                      ),
                    ],
                    onChanged: (v) => v != null
                        ? _save(AiPreferencesCompanion(verbosity: Value(v)))
                        : null,
                  ),
                ),
                ListTile(
                  title: const Text('Bodega por defecto'),
                  trailing: DropdownButton<String?>(
                    value: _bodegas.any((b) => b.id == prefs.defaultBodegaId)
                        ? prefs.defaultBodegaId
                        : null,
                    hint: const Text('La activa'),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('La activa'),
                      ),
                      for (final b in _bodegas)
                        DropdownMenuItem<String?>(
                          value: b.id,
                          child: Text(b.nombre),
                        ),
                    ],
                    onChanged: (v) => _save(
                      AiPreferencesCompanion(defaultBodegaId: Value(v)),
                    ),
                  ),
                ),
                const Divider(),
                _sectionTitle(context, 'Voz'),
                SwitchListTile(
                  title: const Text('Modo voz habilitado'),
                  value: prefs.voiceEnabled,
                  onChanged: (v) =>
                      _save(AiPreferencesCompanion(voiceEnabled: Value(v))),
                ),
                ListTile(
                  title: const Text('Modo de escucha'),
                  subtitle: const Text(
                    'Mantener para hablar: el micrófono escucha solo '
                    'mientras mantenés presionado el círculo.',
                  ),
                  trailing: DropdownButton<ListenMode>(
                    value: listenModeFromPrefs(prefs),
                    items: const [
                      DropdownMenuItem(
                        value: ListenMode.handsFree,
                        child: Text('Manos libres'),
                      ),
                      DropdownMenuItem(
                        value: ListenMode.pushToTalk,
                        child: Text('Mantener para hablar'),
                      ),
                    ],
                    onChanged: (v) => _saveExtra(
                      'listenMode',
                      v == ListenMode.pushToTalk ? 'pushToTalk' : 'handsFree',
                    ),
                  ),
                ),
                SwitchListTile(
                  title: const Text('Leer respuestas en el chat de texto'),
                  value: prefs.autoReadResponses,
                  onChanged: (v) => _save(
                    AiPreferencesCompanion(autoReadResponses: Value(v)),
                  ),
                ),
                ListTile(
                  title: const Text('Velocidad de voz'),
                  subtitle: Slider(
                    value: prefs.ttsRate.clamp(0.5, 2.0),
                    min: 0.5,
                    max: 2.0,
                    divisions: 6,
                    label: '${prefs.ttsRate.toStringAsFixed(2)}x',
                    onChanged: (v) =>
                        _save(AiPreferencesCompanion(ttsRate: Value(v))),
                  ),
                ),
                ListTile(
                  title: const Text('Pausa antes de enviar (hablando)'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Cuánto silencio espera el micrófono antes de mandar '
                        'lo dicho. Subilo si te corta cuando pensás.',
                      ),
                      Slider(
                        value: voicePauseMsFromPrefs(prefs) / 1000,
                        min: 1.5,
                        max: 6.0,
                        divisions: 9,
                        label:
                            '${(voicePauseMsFromPrefs(prefs) / 1000).toStringAsFixed(1)} s',
                        onChanged: (v) => _saveExtra(
                          'voicePauseMs',
                          (v * 1000).round(),
                        ),
                      ),
                    ],
                  ),
                ),
                SwitchListTile(
                  title: const Text('Aviso al consultar'),
                  subtitle: const Text(
                    'En modo voz, avisa hablado ("Revisando el stock…") '
                    'apenas empieza a consultar datos, antes de responder.',
                  ),
                  value: toolAnnounceFromPrefs(prefs),
                  onChanged: (v) => _saveExtra('toolAnnounce', v),
                ),
                SwitchListTile(
                  title: const Text('Confirmar por voz'),
                  subtitle: const Text(
                    'Tras leer el resumen de un borrador, decir '
                    '"confirmar" o "sí" lo registra; "no" lo descarta. '
                    'Cualquier otra frase no ejecuta nada.',
                  ),
                  value: voiceConfirmFromPrefs(prefs),
                  onChanged: (v) => _saveExtra('voiceConfirm', v),
                ),
                const Divider(),
                _sectionTitle(context, 'Seguridad'),
                SwitchListTile(
                  title: const Text('Confirmar antes de registrar'),
                  subtitle: const Text(
                    'Desactivado: en el dictado, decir "listo" registra '
                    'directo (si no hay ítems por revisar).',
                  ),
                  value: prefs.confirmBeforeExecute,
                  onChanged: (v) => _save(
                    AiPreferencesCompanion(confirmBeforeExecute: Value(v)),
                  ),
                ),
                const Divider(),
                _sectionTitle(context, 'Soporte'),
                ListTile(
                  leading: const Icon(Icons.insights_outlined),
                  title: const Text('Diagnóstico'),
                  subtitle: const Text(
                    'Turnos, tokens, latencia y errores (solo en este '
                    'dispositivo).',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/secretary/diagnostics'),
                ),
                const Divider(),
                _sectionTitle(context, 'Memorias del secretario'),
                if (_memories.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text(
                      'Todavía no aprendí nada. Las memorias se crean solas '
                      'a partir de las conversaciones.',
                    ),
                  )
                else
                  for (final m in _memories)
                    ListTile(
                      leading: Icon(switch (m.category) {
                        'preference' => Icons.tune,
                        'rule' => Icons.rule,
                        'correction' => Icons.edit_note,
                        _ => Icons.lightbulb_outline,
                      }, size: 20),
                      title: Text(m.content),
                      subtitle: Text(
                        m.scope == 'business' ? 'Del negocio' : 'Personal',
                      ),
                      trailing: IconButton(
                        tooltip: 'Olvidar',
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () async {
                          await ref
                              .read(driftDatabaseProvider)
                              .secretaryDao
                              .deactivateMemory(m.id);
                          _load();
                        },
                      ),
                    ),
              ],
            ),
    );
  }

  Widget _sectionTitle(BuildContext context, String text) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
    child: Text(
      text,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        color: Theme.of(context).colorScheme.primary,
      ),
    ),
  );
}
