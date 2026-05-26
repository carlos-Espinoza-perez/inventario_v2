import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../services/app_update_service.dart';

enum UpdateStatus {
  idle,
  checking,
  noUpdate,
  updateAvailable,
  downloading,
  readyToInstall,
  needsPermission,
  error,
}

class AppUpdateState {
  final UpdateStatus status;
  final UpdateType updateType;
  final AppUpdateInfo? info;
  final double downloadProgress;
  final String? errorMessage;
  final File? apkFile;

  const AppUpdateState({
    this.status = UpdateStatus.idle,
    this.updateType = UpdateType.noUpdate,
    this.info,
    this.downloadProgress = 0.0,
    this.errorMessage,
    this.apkFile,
  });

  AppUpdateState copyWith({
    UpdateStatus? status,
    UpdateType? updateType,
    AppUpdateInfo? info,
    double? downloadProgress,
    String? errorMessage,
    File? apkFile,
  }) {
    return AppUpdateState(
      status: status ?? this.status,
      updateType: updateType ?? this.updateType,
      info: info ?? this.info,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      errorMessage: errorMessage,
      apkFile: apkFile ?? this.apkFile,
    );
  }
}

class AppUpdateNotifier extends StateNotifier<AppUpdateState> {
  final AppUpdateService _service;

  AppUpdateNotifier(this._service) : super(const AppUpdateState());

  Future<void> checkForUpdate() async {
    if (state.status == UpdateStatus.checking) return;

    state = state.copyWith(status: UpdateStatus.checking);

    final result = await _service.checkForUpdate();

    if (result.type == UpdateType.noUpdate) {
      state = state.copyWith(status: UpdateStatus.noUpdate);
      return;
    }

    state = state.copyWith(
      status: UpdateStatus.updateAvailable,
      updateType: result.type,
      info: result.info,
    );
  }

  Future<void> downloadAndInstall() async {
    final info = state.info;
    if (info == null) return;
    if (state.status == UpdateStatus.downloading) return;

    state = state.copyWith(
      status: UpdateStatus.downloading,
      downloadProgress: 0.0,
      errorMessage: null,
    );

    await for (final progress in _service.downloadApk(
      info.apkUrl,
      onComplete: (file) async {
        state = state.copyWith(
          status: UpdateStatus.readyToInstall,
          downloadProgress: 1.0,
          apkFile: file,
        );
        final error = await _service.openInstaller(file);
        if (error == 'NEEDS_PERMISSION') {
          state = state.copyWith(
            status: UpdateStatus.needsPermission,
          );
        } else if (error != null) {
          state = state.copyWith(
            status: UpdateStatus.error,
            errorMessage: error,
          );
        }
      },
      onError: (error) {
        state = state.copyWith(
          status: UpdateStatus.error,
          errorMessage: error,
        );
      },
    )) {
      state = state.copyWith(downloadProgress: progress);
    }
  }

  Future<void> retryInstall() async {
    final file = state.apkFile;
    if (file == null) {
      await downloadAndInstall();
      return;
    }
    state = state.copyWith(status: UpdateStatus.readyToInstall, errorMessage: null);
    final error = await _service.openInstaller(file);
    if (error == 'NEEDS_PERMISSION') {
      state = state.copyWith(status: UpdateStatus.needsPermission);
    } else if (error != null) {
      state = state.copyWith(status: UpdateStatus.error, errorMessage: error);
    }
  }

  Future<void> openPermissionSettings() async {
    await openAppSettings();
  }

  void dismissOptional() {
    if (state.updateType == UpdateType.optionalUpdate) {
      state = state.copyWith(status: UpdateStatus.noUpdate);
    }
  }
}

final appUpdateServiceProvider = Provider<AppUpdateService>(
  (_) => AppUpdateService(),
);

final appUpdateProvider =
    StateNotifierProvider<AppUpdateNotifier, AppUpdateState>(
  (ref) => AppUpdateNotifier(ref.watch(appUpdateServiceProvider)),
);
