import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventario_v2/core/providers/auto_sync_provider.dart';

class SyncStatusBanner extends ConsumerWidget {
  const SyncStatusBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncAsync = ref.watch(autoSyncProvider);

    return syncAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (e, st) => const SizedBox.shrink(),
      data: (syncState) {
        if (syncState.isOnline && !syncState.hasPendingData && !syncState.hasError) {
          return const SizedBox.shrink();
        }

        final Color bannerColor;
        final String message;
        final IconData icon;

        if (!syncState.isOnline && syncState.hasPendingData) {
          bannerColor = Colors.orange.shade700;
          icon = Icons.cloud_off;
          message =
              'Sin conexión — ${syncState.pendingCount} cambio${syncState.pendingCount == 1 ? '' : 's'} pendiente${syncState.pendingCount == 1 ? '' : 's'}';
        } else if (syncState.hasError) {
          bannerColor = Colors.red.shade700;
          icon = Icons.sync_problem;
          message = 'Error de sincronización — toca para reintentar';
        } else if (syncState.hasPendingData) {
          bannerColor = Colors.blue.shade700;
          icon = Icons.sync;
          message =
              '${syncState.pendingCount} registro${syncState.pendingCount == 1 ? '' : 's'} pendiente${syncState.pendingCount == 1 ? '' : 's'} de sincronizar';
        } else {
          return const SizedBox.shrink();
        }

        return Material(
          color: bannerColor,
          child: InkWell(
            onTap: syncState.hasError
                ? () => ref.read(autoSyncProvider.notifier).runFullSync()
                : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(icon, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  if (syncState.hasError)
                    const Text(
                      'REINTENTAR',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
