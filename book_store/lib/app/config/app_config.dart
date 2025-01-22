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
  static const int connectionTimeout = 15; // Reduced from 30 to 15 seconds
  static const int receiveTimeout = 15; // Reduced from 30 to 15 seconds
  static const int maxRetries = 3; // Maximum number of retry attempts
  static const int retryDelay = 1; // Delay between retries in seconds
  
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
  final int? statusCode;
  final String? details;

  ServerConnectionException(this.message, {this.statusCode, this.details});

  @override
  String toString() => 'ServerConnectionException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}${details != null ? '\nDetails: $details' : ''}';
}

class NetworkException implements Exception {
  final String message;
  final String? errorCode;
  final dynamic data;

  NetworkException(this.message, {this.errorCode, this.data});

  @override
  String toString() => 'NetworkException: $message${errorCode != null ? ' (Code: $errorCode)' : ''}';
}
