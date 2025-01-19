class AppConfig {
  // Backend Server Configuration
  static const String baseUrl = 'http://localhost:5000/api';
  
  // Timeout Configurations
  static const int connectionTimeout = 30; // seconds
  static const int receiveTimeout = 30; // seconds

  // Environment Modes
  static const String developmentMode = 'development';
  static const String productionMode = 'production';
  static const String currentMode = developmentMode;

  // Network Configuration
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Validate Server URL
  static bool isValidServerUrl(String url) {
    final urlPattern = RegExp(
      r'^(https?://)?'
      r'(([a-z\d]([a-z\d-]*[a-z\d])*)\.)+[a-z]{2,}'
      r'(:\d+)?(/.*)?$',
      caseSensitive: false,
    );
    return urlPattern.hasMatch(url);
  }
}

// Custom Exceptions for Network Handling
class ServerConnectionException implements Exception {
  final String message;
  ServerConnectionException(this.message);

  @override
  String toString() => 'ServerConnectionException: $message';
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}
