import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

import '../services/app_logger.dart';

const _versionJsonUrl =
    'https://raw.githubusercontent.com/carlos-Espinoza-perez/inventario_v2/main/app_update/version.json';

enum UpdateType { noUpdate, optionalUpdate, requiredUpdate }

class AppUpdateInfo {
  final String versionName;
  final int versionCode;
  final int minRequiredVersionCode;
  final String apkUrl;
  final List<String> releaseNotes;
  final bool forceUpdate;
  final String publishedAt;

  const AppUpdateInfo({
    required this.versionName,
    required this.versionCode,
    required this.minRequiredVersionCode,
    required this.apkUrl,
    required this.releaseNotes,
    required this.forceUpdate,
    required this.publishedAt,
  });

  factory AppUpdateInfo.fromJson(Map<String, dynamic> json) {
    return AppUpdateInfo(
      versionName: json['versionName'] as String,
      versionCode: json['versionCode'] as int,
      minRequiredVersionCode: json['minRequiredVersionCode'] as int,
      apkUrl: json['apkUrl'] as String,
      releaseNotes: List<String>.from(json['releaseNotes'] as List),
      forceUpdate: json['forceUpdate'] as bool,
      publishedAt: json['publishedAt'] as String,
    );
  }
}

class UpdateCheckResult {
  final UpdateType type;
  final AppUpdateInfo? info;

  const UpdateCheckResult({required this.type, this.info});

  static const noUpdate = UpdateCheckResult(type: UpdateType.noUpdate);
}

class AppUpdateService {
  Future<bool> _hasConnection() async {
    final results = await Connectivity().checkConnectivity();
    return !results.contains(ConnectivityResult.none);
  }

  Future<UpdateCheckResult> checkForUpdate() async {
    try {
      if (!await _hasConnection()) return UpdateCheckResult.noUpdate;

      final response = await http
          .get(Uri.parse(_versionJsonUrl))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode != 200) return UpdateCheckResult.noUpdate;

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final info = AppUpdateInfo.fromJson(json);
      final packageInfo = await PackageInfo.fromPlatform();
      final localVersionCode = int.tryParse(packageInfo.buildNumber) ?? 0;

      if (localVersionCode >= info.versionCode) {
        return UpdateCheckResult.noUpdate;
      }

      final isRequired =
          info.forceUpdate || localVersionCode < info.minRequiredVersionCode;

      return UpdateCheckResult(
        type: isRequired ? UpdateType.requiredUpdate : UpdateType.optionalUpdate,
        info: info,
      );
    } catch (e, st) {
      AppLogger.warn('[AppUpdateService] checkForUpdate falló silenciosamente', e, st);
      return UpdateCheckResult.noUpdate;
    }
  }

  Stream<double> downloadApk(
    String apkUrl, {
    required void Function(File file) onComplete,
    required void Function(String error) onError,
  }) async* {
    File? tempFile;
    try {
      final dir = await getTemporaryDirectory();
      tempFile = File('${dir.path}/update_pending.apk');

      final request = http.Request('GET', Uri.parse(apkUrl));
      final response = await request.send().timeout(const Duration(minutes: 10));

      if (response.statusCode != 200) {
        onError('No se pudo descargar el archivo (código ${response.statusCode}).');
        return;
      }

      final totalBytes = response.contentLength ?? 0;
      var receivedBytes = 0;
      final sink = tempFile.openWrite();

      await for (final chunk in response.stream) {
        sink.add(chunk);
        receivedBytes += chunk.length;
        if (totalBytes > 0) {
          yield receivedBytes / totalBytes;
        }
      }

      await sink.flush();
      await sink.close();
      yield 1.0;
      onComplete(tempFile);
    } catch (e, st) {
      AppLogger.error('[AppUpdateService] Error durante la descarga', e, st);
      await _cleanTempFile(tempFile);
      onError('Error de descarga. Verifica tu conexión e intenta de nuevo.');
    }
  }

  Future<void> openInstaller(File apkFile) async {
    final result = await OpenFile.open(apkFile.path, type: 'application/vnd.android.package-archive');
    if (result.type != ResultType.done) {
      AppLogger.warn('[AppUpdateService] openInstaller: ${result.message}');
    }
  }

  Future<void> cleanTempApk() async {
    final dir = await getTemporaryDirectory();
    await _cleanTempFile(File('${dir.path}/update_pending.apk'));
  }

  Future<void> _cleanTempFile(File? file) async {
    try {
      if (file != null && await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }
}
