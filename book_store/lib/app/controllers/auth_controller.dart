import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/api_service.dart';
import '../utils/connection_diagnostic.dart';
import '../config/app_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find();

  final ApiService _apiService = ApiService.to;

  final RxBool isLoading = false.obs;
  final RxBool isLoggedIn = false.obs;
  final RxBool isPasswordVisible = false.obs;
  final RxBool isServerConnected = false.obs;
  final RxBool isInternetAvailable = false.obs;
  final Rx<String?> token = Rx<String?>(null);
  final Rx<Map<String, dynamic>?> userData = Rx<Map<String, dynamic>?>(null);
  final Rx<Map<String, dynamic>?> connectionReport = Rx<Map<String, dynamic>?>(null);

  @override
  void onInit() {
    super.onInit();
    _checkInitialAuthStatus();
    _performConnectionDiagnostics();
    ever(isLoggedIn, _setInitialScreen);
  }

  Future<void> _performConnectionDiagnostics() async {
    try {
      isLoading.value = true;
      
      // Check internet connectivity
      isInternetAvailable.value = await ConnectionDiagnostic.checkInternetConnection();
      
      // Validate server URL
      final isValidUrl = ConnectionDiagnostic.validateServerUrl(AppConfig.baseUrl);
      
      // Perform server health check
      final healthCheckResult = await _apiService.checkServerHealth();
      isServerConnected.value = healthCheckResult['success'] ?? false;

      // Generate comprehensive connection report
      connectionReport.value = {
        'internetAvailable': isInternetAvailable.value,
        'serverConnected': isServerConnected.value,
        'validServerUrl': isValidUrl,
        'serverDetails': healthCheckResult,
        'timestamp': DateTime.now().toIso8601String(),
      };

      // Log connection diagnostics
      if (!isInternetAvailable.value || !isServerConnected.value) {
        Get.snackbar(
          'Connection Issue',
          'Please check your internet and server connection',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Diagnostic Error',
        'Failed to perform connection diagnostics',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _checkInitialAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final storedToken = prefs.getString('auth_token');
    
    if (storedToken != null) {
      token.value = storedToken;
      isLoggedIn.value = true;
    }
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;
      final response = await _apiService.register(
        name: name,
        email: email,
        password: password,
      );

      if (response['success']) {
        // Handle successful registration
        Get.snackbar(
          'Success',
          'Account created successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        
        // Automatically log in after registration
        await login(email: email, password: password);
      } else {
        // Handle registration failure
        Get.snackbar(
          'Error',
          response['message'] ?? 'Registration failed',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An unexpected error occurred',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;
      final response = await _apiService.login(
        email: email,
        password: password,
      );

      if (response['success']) {
        // Update authentication state
        token.value = response['token'];
        isLoggedIn.value = true;
        userData.value = response['data'];

        // Navigate to home screen
        Get.offAllNamed('/home');

        Get.snackbar(
          'Success',
          'Logged in successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        // Handle login failure
        Get.snackbar(
          'Error',
          response['message'] ?? 'Login failed',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An unexpected error occurred',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      isLoading.value = true;
      final response = await _apiService.logout();

      if (response['success']) {
        // Clear authentication state
        token.value = null;
        isLoggedIn.value = false;
        userData.value = null;

        // Navigate to login screen
        Get.offAllNamed('/login');

        Get.snackbar(
          'Success',
          'Logged out successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          response['message'] ?? 'Logout failed',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An unexpected error occurred',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _setInitialScreen(bool isLoggedIn) {
    if (isLoggedIn && isServerConnected.value) {
      Get.offAllNamed('/home');
    } else {
      Get.offAllNamed('/login');
    }
  }

  // Optional: Manual connection recheck
  Future<void> recheckConnection() async {
    await _performConnectionDiagnostics();
  }
}
