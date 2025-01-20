class AppConfig {
  // Backend Server Configuration
  static const String baseUrl = 'http://10.0.2.2:5000'; // Android emulator localhost
  // static const String baseUrl = 'http://localhost:5000'; // For web or desktop
  
  // API Endpoints
  static const String registerEndpoint = '/api/auth/register';
  static const String loginEndpoint = '/api/auth/login';
  static const String verifyEmailEndpoint = '/api/auth/verify-email';
  static const String resendVerificationEndpoint = '/api/auth/resend-verification';
  
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
    try {
      final uri = Uri.parse(url);
      return uri.isScheme('http') || uri.isScheme('https');
    } catch (e) {
      return false;
    }
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
