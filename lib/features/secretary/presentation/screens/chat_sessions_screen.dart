import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventario_v2/core/db/app_database.dart';
import 'package:inventario_v2/core/presentation/mixins/app_bar_config_mixin.dart';
import 'package:inventario_v2/core/providers/app_bar_provider.dart';
import 'package:inventario_v2/core/providers/drift_provider.dart';

import '../providers/chat_sessions_provider.dart';
import '../providers/secretary_chat_provider.dart';

/// Historial de conversaciones del secretario: lista por actividad reciente,
/// retomar sesión y archivar.
class ChatSessionsScreen extends ConsumerStatefulWidget {
  const ChatSessionsScreen({super.key});

  @override
  ConsumerState<ChatSessionsScreen> createState() => _ChatSessionsScreenState();
}

class _ChatSessionsScreenState extends ConsumerState<ChatSessionsScreen>
    with AppBarConfigMixin {
  @override
  void configureAppBar() {
    ref
        .read(appBarProvider.notifier)
        .setOptions(title: 'Conversaciones', showBackButton: true);
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(configureAppBar);
  }

  @override
  Widget build(BuildContext context) {
    final sessionsAsync = ref.watch(chatSessionsProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ref.read(secretaryChatProvider.notifier).startNewSession();
          Navigator.of(context).pop();
        },
        icon: const Icon(Icons.add_comment_outlined),
        label: const Text('Nueva'),
      ),
      body: sessionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (sessions) {
          if (sessions.isEmpty) {
            return const Center(child: Text('Todavía no hay conversaciones.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.only(bottom: 88),
            itemCount: sessions.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final session = sessions[index];
              return ListTile(
                leading: const Icon(Icons.chat_bubble_outline),
                title: Text(
                  session.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  '${_formatDate(session.lastMessageAt)} · '
                  '${session.messageCount} mensajes',
                ),
                trailing: IconButton(
                  tooltip: 'Archivar',
                  icon: const Icon(Icons.archive_outlined),
                  onPressed: () => _archive(context, ref, session),
                ),
                onTap: () {
                  ref
                      .read(secretaryChatProvider.notifier)
                      .openSession(session.id);
                  Navigator.of(context).pop();
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _archive(
    BuildContext context,
    WidgetRef ref,
    ChatSession session,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Archivar conversación'),
        content: Text('¿Archivar "${session.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Archivar'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final db = ref.read(driftDatabaseProvider);
    await db.secretaryDao.updateSessionMeta(session.id, status: 'archived');

    // Si era la sesión abierta en el chat, empezar una nueva.
    final chatState = ref.read(secretaryChatProvider);
    if (chatState.sessionId == session.id) {
      ref.read(secretaryChatProvider.notifier).startNewSession();
    }
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(dt.year, dt.month, dt.day);
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    if (day == today) return 'Hoy $hh:$mm';
    if (day == today.subtract(const Duration(days: 1))) return 'Ayer $hh:$mm';
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/${dt.year} $hh:$mm';
  }
}
