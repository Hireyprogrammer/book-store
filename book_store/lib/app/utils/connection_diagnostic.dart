import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart' show kDebugMode;

class ConnectionDiagnostic {
  // Check internet connectivity
  static Future<bool> checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(Duration(seconds: 5));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } on TimeoutException catch (_) {
      return false;
    }
  }

  // Validate server URL
  static bool validateServerUrl(String url) {
    final urlPattern = RegExp(
      r'^(https?://)?'
      r'(([a-z\d]([a-z\d-]*[a-z\d])*)\.)+[a-z]{2,}'
      r'(:\d+)?(/.*)?$',
      caseSensitive: false,
    );
    return urlPattern.hasMatch(url);
  }

  // Comprehensive connectivity report
  static Future<Map<String, dynamic>> getConnectivityReport() async {
    return {
      'internetConnected': await checkInternetConnection(),
      'platform': Platform.operatingSystem,
      'platformVersion': Platform.operatingSystemVersion,
      'isDebugMode': kDebugMode,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  // Network latency test
  static Future<int> measureLatency(String url) async {
    try {
      final stopwatch = Stopwatch()..start();
      await HttpClient()
          .getUrl(Uri.parse(url))
          .then((request) => request.close())
          .timeout(Duration(seconds: 10));
      stopwatch.stop();
      return stopwatch.elapsedMilliseconds;
    } catch (e) {
      return -1; // Indicates failure
    }
  }
}

// Custom network exceptions
class NetworkException implements Exception {
  final String message;
  final int? statusCode;

  NetworkException(this.message, {this.statusCode});

  @override
  String toString() => 'NetworkException: $message (Status: $statusCode)';
}
