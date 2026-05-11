import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConnectivityChecker {
  Future<bool> isOnline() async {
    try {
      final result = await InternetAddress.lookup('api.openai.com')
          .timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}

final connectivityCheckerProvider = Provider<ConnectivityChecker>(
  (_) => ConnectivityChecker(),
);
