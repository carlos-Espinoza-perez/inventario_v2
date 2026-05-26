import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/app_update_provider.dart';
import '../../services/app_update_service.dart';
import '../../theme/app_colors.dart';

class UpdateDialog extends ConsumerWidget {
  const UpdateDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appUpdateProvider);
    final info = state.info;
    final isRequired = state.updateType == UpdateType.requiredUpdate;

    return PopScope(
      canPop: !isRequired,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(isRequired),
              const SizedBox(height: 12),
              if (info != null) ...[
                Text(
                  'Versión ${info.versionName}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                ...info.releaseNotes.map(
                  (note) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(color: AppColors.textSecondary)),
                        Expanded(
                          child: Text(
                            note,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
              _buildBody(state, isRequired),
              const SizedBox(height: 20),
              _buildActions(context, ref, state, isRequired),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isRequired) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isRequired ? AppColors.warningLight : AppColors.infoLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isRequired ? Icons.warning_rounded : Icons.system_update_rounded,
            color: isRequired ? AppColors.warning : AppColors.info,
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            isRequired ? 'Actualización requerida' : 'Nueva actualización disponible',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(AppUpdateState state, bool isRequired) {
    if (state.status == UpdateStatus.downloading) {
      final percent = (state.downloadProgress * 100).toInt();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Descargando... $percent%',
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: state.downloadProgress,
            backgroundColor: AppColors.border,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            borderRadius: BorderRadius.circular(4),
            minHeight: 6,
          ),
        ],
      );
    }

    if (state.status == UpdateStatus.error) {
      return Text(
        state.errorMessage ?? 'Ocurrió un error. Intenta de nuevo.',
        style: const TextStyle(fontSize: 13, color: AppColors.error),
      );
    }

    if (state.status == UpdateStatus.readyToInstall) {
      return const Text(
        'Descarga completada. Si el instalador no se abrió, toca "Instalar" para continuar.',
        style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
      );
    }

    if (isRequired) {
      return const Text(
        'Esta versión ya no es compatible. Debes actualizar para continuar usando la app.',
        style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
      );
    }

    return const Text(
      'Puedes actualizar ahora o continuar usando esta versión temporalmente.',
      style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
    );
  }

  Widget _buildActions(
    BuildContext context,
    WidgetRef ref,
    AppUpdateState state,
    bool isRequired,
  ) {
    final notifier = ref.read(appUpdateProvider.notifier);
    final isDownloading = state.status == UpdateStatus.downloading;
    final isReady = state.status == UpdateStatus.readyToInstall;
    final isError = state.status == UpdateStatus.error;

    if (isDownloading) {
      return const SizedBox.shrink();
    }

    if (isReady || isError) {
      return FilledButton.icon(
        onPressed: () => notifier.retryInstall(),
        icon: const Icon(Icons.install_mobile_rounded, size: 18),
        label: const Text('Instalar'),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          minimumSize: const Size.fromHeight(44),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: () => notifier.downloadAndInstall(),
          icon: const Icon(Icons.download_rounded, size: 18),
          label: const Text('Actualizar ahora'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            minimumSize: const Size.fromHeight(44),
          ),
        ),
        if (!isRequired) ...[
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              notifier.dismissOptional();
              Navigator.of(context).pop();
            },
            child: const Text(
              'Después',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ],
      ],
    );
  }
}
