import 'dart:convert';
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
      ...AppConfig.headers,
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Comprehensive Health Check Method
  Future<Map<String, dynamic>> checkServerHealth() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/health'),
        headers: await _headers,
      ).timeout(Duration(seconds: _timeoutSeconds));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'status': true,
          'message': 'Server is healthy',
          'details': data
        };
      } else {
        return {
          'status': false,
          'message': 'Server returned non-200 status',
          'code': response.statusCode
        };
      }
    } catch (e) {
      return {
        'status': false,
        'message': 'Could not connect to server',
        'error': e.toString()
      };
    }
  }

  // User Registration
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/auth/register'),
        headers: await _headers,
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      ).timeout(Duration(seconds: _timeoutSeconds));

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // User Login
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: await _headers,
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(Duration(seconds: _timeoutSeconds));

      final result = _handleResponse(response);
      
      // Store token if login is successful
      if (result['success'] && result['token'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', result['token']);
      }

      return result;
    } catch (e) {
      return _handleError(e);
    }
  }

  // Logout method
  Future<Map<String, dynamic>> logout() async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/auth/logout'),
        headers: await _headers,
      ).timeout(Duration(seconds: _timeoutSeconds));

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // Password Reset
  Future<Map<String, dynamic>> resetPassword({
    required String email,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/auth/reset-password'),
        headers: await _headers,
        body: jsonEncode({
          'email': email,
        }),
      ).timeout(Duration(seconds: _timeoutSeconds));

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // Book-related methods
  Future<Map<String, dynamic>> fetchBooks() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/books'),
        headers: await _headers,
      ).timeout(Duration(seconds: _timeoutSeconds));

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // Enhanced Error Handling Method
  Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final responseBody = jsonDecode(response.body);
      switch (response.statusCode) {
        case 200:
        case 201:
          return {
            'success': true,
            'data': responseBody,
            'token': responseBody['token'],
            'message': responseBody['message'] ?? 'Success'
          };
        case 400:
          return {
            'success': false,
            'error': 'Bad Request',
            'message': responseBody['message'] ?? 'Invalid request',
            'details': responseBody
          };
        case 401:
          return {
            'success': false,
            'error': 'Unauthorized',
            'message': responseBody['message'] ?? 'Authentication failed',
            'action': 'logout'
          };
        case 403:
          return {
            'success': false,
            'error': 'Forbidden',
            'message': responseBody['message'] ?? 'Access denied',
          };
        case 404:
          return {
            'success': false,
            'error': 'Not Found',
            'message': responseBody['message'] ?? 'Resource not found',
          };
        case 500:
          return {
            'success': false,
            'error': 'Server Error',
            'message': responseBody['message'] ?? 'Internal server error',
          };
        default:
          return {
            'success': false,
            'error': 'Unknown Error',
            'message': 'An unexpected error occurred',
            'code': response.statusCode
          };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Parse Error',
        'message': 'Could not parse server response',
        'details': e.toString()
      };
    }
  }

  // Handle errors
  Map<String, dynamic> _handleError(dynamic e) {
    return {
      'success': false,
      'error': 'Network Error',
      'message': e.toString()
    };
  }
}
