import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

class ApiService extends GetxService {
  static ApiService get to => Get.find();

  // Use configuration from AppConfig
  static const String _baseUrl = AppConfig.baseUrl;
  static const int _timeoutSeconds = AppConfig.connectionTimeout;

  // Headers with dynamic token support
  Future<Map<String, String>> get _headers async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Response Handler
  Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final data = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'success': true,
          'data': data,
          'message': data['message'] ?? 'Operation successful',
          'token': data['token'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Operation failed',
          'error': data['error'] ?? 'Unknown error',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      print('Response parsing error: $e'); // Debug log
      return {
        'success': false,
        'message': 'Failed to process server response',
        'error': e.toString(),
      };
    }
  }

  // Error Handler
  Map<String, dynamic> _handleError(dynamic error) {
    print('API Error: $error'); // For debugging
    return {
      'success': false,
      'message': error is TimeoutException
          ? 'Connection timeout. Please try again.'
          : 'An error occurred: ${error.toString()}',
      'error': error.toString(),
    };
  }

  // User Registration
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/auth/register'),
      headers: await _headers,
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );
    return _handleResponse(response);
  }

  // User Login
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      print('🔐 Attempting login to: $_baseUrl/api/auth/login'); // Debug log
      print('📧 Email: $email'); // Debug log

      final response = await http
          .post(
            Uri.parse('$_baseUrl/api/auth/login'),
            headers: await _headers,
            body: jsonEncode({
              'email': email,
              'password': password,
            }),
          )
          .timeout(Duration(seconds: _timeoutSeconds));

      print('📥 Login response status: ${response.statusCode}'); // Debug log
      print('📄 Login response body: ${response.body}'); // Debug log

      final result = _handleResponse(response);

      // Store token if login is successful
      if (result['success'] && result['token'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', result['token']);
      }

      return result;
    } catch (e) {
      print('❌ Login error: $e'); // Debug log
      if (e is SocketException) {
        return {
          'success': false,
          'message':
              'Could not connect to server. Please check your internet connection.',
          'error': e.toString()
        };
      } else if (e is TimeoutException) {
        return {
          'success': false,
          'message': 'Server is taking too long to respond. Please try again.',
          'error': e.toString()
        };
      }
      return _handleError(e);
    }
  }

  // Verify OTP
  Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/verify-otp'),
        headers: await _headers,
        body: jsonEncode({
          'email': email,
          'otp': otp,
        }),
      );
      return _handleResponse(response);
    } catch (e) {
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

  // Resend Verification
  Future<Map<String, dynamic>> resendVerification({
    required String email,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/auth/resend-verification'),
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
          .timeout(Duration(seconds: _timeoutSeconds));

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
