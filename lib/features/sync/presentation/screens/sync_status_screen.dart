import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inventario_v2/core/presentation/widgets/custom_card.dart';
import 'package:inventario_v2/core/presentation/widgets/custom_status_badge.dart';
import 'package:inventario_v2/core/providers/app_bar_provider.dart';
import 'package:inventario_v2/core/providers/auto_sync_provider.dart';
import 'package:inventario_v2/features/sync/presentation/providers/sync_status_provider.dart';

class SyncStatusScreen extends ConsumerStatefulWidget {
  const SyncStatusScreen({super.key});

  @override
  ConsumerState<SyncStatusScreen> createState() => _SyncStatusScreenState();
}

class _SyncStatusScreenState extends ConsumerState<SyncStatusScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(appBarProvider.notifier).setOptions(
        title: "Estado de Sincronización",
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long, color: Colors.black87),
            onPressed: () => context.push('/log-viewer'),
            tooltip: "Ver Logs del Sistema",
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black87),
            onPressed: () => ref.read(syncStatusReportProvider.notifier).refreshStats(),
            tooltip: "Recargar Contadores",
          ),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final syncState = ref.watch(autoSyncProvider);
    final isSyncing = syncState.value?.isSyncing ?? false;
    final lastSync = syncState.value?.lastSync;
    final lastError = syncState.value?.lastError;

    final statsAsync = ref.watch(syncStatusReportProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(syncStatusReportProvider.notifier).refreshStats();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Panel Superior de Acciones Rápidas
              CustomCard(
                backgroundColor: isSyncing ? Colors.blue.shade50 : Colors.white,
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: isSyncing ? Colors.blue : Colors.green,
                          child: Icon(
                            isSyncing ? Icons.sync : Icons.cloud_done,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isSyncing ? "Sincronizando en segundo plano..." : "Motor de Sincronización Activo",
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                lastSync != null
                                    ? "Última sincronización: ${lastSync.hour.toString().padLeft(2, '0')}:${lastSync.minute.toString().padLeft(2, '0')}:${lastSync.second.toString().padLeft(2, '0')}"
                                    : "Esperando primer ciclo...",
                                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (lastError != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_amber, color: Colors.red, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                lastError,
                                style: TextStyle(color: Colors.red.shade800, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: isSyncing
                                ? null
                                : () async {
                                    await ref.read(autoSyncProvider.notifier).runFullSync();
                                    await ref.read(syncStatusReportProvider.notifier).refreshStats();
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: const Icon(Icons.cloud_sync),
                            label: const Text("FORZAR SINCRONIZACIÓN", style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: () => context.push('/log-viewer'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.terminal),
                          label: const Text("Ver Logs"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              const Text(
                "DESGLOSE POR TABLAS",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54),
              ),
              const SizedBox(height: 12),

              statsAsync.when(
                loading: () => const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator())),
                error: (err, _) => Center(child: Text("Error al cargar contadores: $err", style: const TextStyle(color: Colors.red))),
                data: (stats) {
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: stats.length,
                    itemBuilder: (context, index) {
                      final s = stats[index];
                      return CustomCard(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    s.displayName,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Tabla SQLite: ${s.tableName}",
                                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "${s.total} registros",
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    if (s.synced > 0)
                                      Padding(
                                        padding: const EdgeInsets.only(left: 4),
                                        child: CustomStatusBadge(
                                          status: "${s.synced} web",
                                          fontColor: Colors.green.shade800,
                                          backgroundColor: Colors.green.shade50,
                                        ),
                                      ),
                                    if (s.pending > 0)
                                      Padding(
                                        padding: const EdgeInsets.only(left: 4),
                                        child: CustomStatusBadge(
                                          status: "${s.pending} pend",
                                          fontColor: Colors.amber.shade900,
                                          backgroundColor: Colors.amber.shade50,
                                        ),
                                      ),
                                    if (s.errors > 0)
                                      Padding(
                                        padding: const EdgeInsets.only(left: 4),
                                        child: CustomStatusBadge(
                                          status: "${s.errors} err",
                                          fontColor: Colors.red.shade800,
                                          backgroundColor: Colors.red.shade50,
                                        ),
                                      ),
                                    if (s.total == 0)
                                      const CustomStatusBadge(
                                        status: "Vacía",
                                        fontColor: Colors.grey,
                                        backgroundColor: Colors.black12,
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
