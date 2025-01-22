import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

class ApiService extends GetxService {
  static ApiService get to => Get.find();

  final String _baseUrl = AppConfig.baseUrl;

  Map<String, String> get _defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Future<Map<String, String>> get _headers async {
    final headers = Map<String, String>.from(_defaultHeaders);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    print('🔍 Processing response:');
    print('📊 Status code: ${response.statusCode}');
    print('📄 Response body: ${response.body}');
    
    try {
      final data = jsonDecode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'success': true,
          ...data,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'An error occurred',
          'error': data['error'],
        };
      }
    } catch (e) {
      print('❌ Error processing response: $e');
      return {
        'success': false,
        'message': 'Failed to process response',
        'error': e.toString(),
      };
    }
  }

  Map<String, dynamic> _handleError(dynamic error) {
    print('❌ Handling error: $error');
    if (error is SocketException) {
      return {
        'success': false,
        'message': 'Unable to connect to server. Please check your internet connection.',
        'error_type': 'connection_error',
        'error': error.toString()
      };
    } else if (error is TimeoutException) {
      return {
        'success': false,
        'message': 'Server is taking too long to respond. Please try again.',
        'error_type': 'timeout_error',
        'error': error.toString()
      };
    }
    return {
      'success': false,
      'message': 'An unexpected error occurred. Please try again.',
      'error_type': 'unknown_error',
      'error': error.toString()
    };
  }

  Future<Map<String, dynamic>> _makeRequest(
    String method,
    String endpoint,
    Map<String, dynamic> body, {
    int retryCount = 0,
  }) async {
    try {
      print('🔄 Making $method request to $endpoint (Attempt ${retryCount + 1}/${AppConfig.maxRetries})');
      
      final headers = await _headers;
      final uri = Uri.parse('$_baseUrl$endpoint');
      
      http.Response response;
      switch (method.toUpperCase()) {
        case 'POST':
          response = await http
              .post(uri, headers: headers, body: jsonEncode(body))
              .timeout(Duration(seconds: AppConfig.connectionTimeout));
          break;
        default:
          throw UnsupportedError('Unsupported HTTP method: $method');
      }

      final result = _handleResponse(response);
      return result;
    } catch (e) {
      if (e is TimeoutException || e is SocketException) {
        if (retryCount < AppConfig.maxRetries - 1) {
          print('⚠️ Request failed, retrying in ${AppConfig.retryDelay} seconds...');
          await Future.delayed(Duration(seconds: AppConfig.retryDelay));
          return _makeRequest(method, endpoint, body, retryCount: retryCount + 1);
        }
      }
      return _handleError(e);
    }
  }

  // User Registration
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    print('📝 Starting registration process:');
    final requestBody = {
      'username': name,
      'email': email,
      'password': password,
      'role': 'user'
    };
    return _makeRequest('POST', AppConfig.registerEndpoint, requestBody);
  }

  // Login user
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    print('🔐 Attempting Login:');
    final requestBody = {
      'email': email,
      'password': password,
    };
    final result = await _makeRequest('POST', AppConfig.loginEndpoint, requestBody);
    
    if (result['success'] == true && result['token'] != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', result['token']);
      print('✅ Token stored successfully');
    }
    
    return result;
  }

  // Verify OTP
  Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      print('🔐 Attempting OTP verification:');
      print('🌐 Base URL: $_baseUrl');
      print('📍 Endpoint: $_baseUrl${AppConfig.verifyEmailEndpoint}');
      print('📧 Email: $email');
      print('🔑 Verification Code: $otp');
      
      final headers = await _headers;
      print('📤 Request Headers: $headers');
      
      final requestBody = {
        'email': email,
        'pin': otp,
        'otp': otp,  // Send both for compatibility
      };
      print('📦 Request Body: ${jsonEncode(requestBody)}');

      final response = await http
          .post(
            Uri.parse('$_baseUrl${AppConfig.verifyEmailEndpoint}'),
            headers: headers,
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: AppConfig.connectionTimeout));

      print('📥 Response Status Code: ${response.statusCode}');
      print('📥 Response Headers: ${response.headers}');
      print('📥 Response Body: ${response.body}');

      final result = _handleResponse(response);
      print('🔄 Processed Result: $result');

      if (result['success'] == true && result['token'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', result['token']);
        print('✅ Token stored successfully');
      }

      return result;
    } catch (e) {
      print('❌ Error during verification: $e');
      return _handleError(e);
    }
  }

  // Resend verification code
  Future<Map<String, dynamic>> resendVerification({
    required String email,
  }) async {
    try {
      print('📨 Requesting new verification code:');
      print('🌐 Base URL: $_baseUrl');
      print('📍 Endpoint: $_baseUrl${AppConfig.resendVerificationEndpoint}');
      print('📧 Email: $email');

      final headers = await _headers;
      print('📤 Request Headers: $headers');

      final response = await http
          .post(
            Uri.parse('$_baseUrl${AppConfig.resendVerificationEndpoint}'),
            headers: headers,
            body: jsonEncode({
              'email': email,
            }),
          )
          .timeout(const Duration(seconds: AppConfig.connectionTimeout));

      print('📥 Response Status Code: ${response.statusCode}');
      print('📥 Response Headers: ${response.headers}');
      print('📥 Response Body: ${response.body}');

      return _handleResponse(response);
    } catch (e) {
      print('❌ Error during resend verification: $e');
      return _handleError(e);
    }
  }

  // Verify Email
  Future<Map<String, dynamic>> verifyEmail({
    required String email,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/auth/verify-email'),
      headers: await _headers,
      body: jsonEncode({
        'email': email,
      }),
    );
    return _handleResponse(response);
  }

  // Logout
  Future<Map<String, dynamic>> logout() async {
    try {
      print('Attempting logout'); // Debug log
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      return {'success': true, 'message': 'Logged out successfully'};
    } catch (e) {
      print('Logout error: $e');
      return _handleError(e);
    }
  }

  // Check Authentication Status
  Future<bool> isAuthenticated() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      return token != null;
    } catch (e) {
      print('Auth check error: $e');
      return false;
    }
  }

  // Server Health Check
  Future<Map<String, dynamic>> checkServerHealth() async {
    try {
      print('🔍 Checking server health at: $_baseUrl/health'); // Debug log

      final response = await http
          .get(
            Uri.parse('$_baseUrl/health'),
            headers: await _headers,
          )
          .timeout(Duration(seconds: 5));

      print(
          '🏥 Health check response: ${response.statusCode} - ${response.body}'); // Debug log

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Server is healthy',
          'status': response.statusCode
        };
      } else {
        return {
          'success': false,
          'message': 'Server is not responding properly',
          'status': response.statusCode
        };
      }
    } catch (e) {
      print('❌ Health check error: $e'); // Debug log
      return {
        'success': false,
        'message': 'Could not connect to server',
        'error': e.toString()
      };
    }
  }

  // Password Reset
  Future<Map<String, dynamic>> resetPassword({
    required String email,
  }) async {
    try {
      print('Attempting password reset for: $email'); // Debug log

      final response = await http
          .post(
            Uri.parse('$_baseUrl/api/auth/forgot-password'),
            headers: await _headers,
            body: jsonEncode({
              'email': email,
            }),
          )
          .timeout(Duration(seconds: 10));

      print(
          'Reset password response status: ${response.statusCode}'); // Debug log
      print('Reset password response body: ${response.body}'); // Debug log

      return _handleResponse(response);
    } catch (e) {
      print('Reset password error: $e'); // Debug log
      return _handleError(e);
    }
  }
}
