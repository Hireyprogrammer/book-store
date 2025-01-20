import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/api_service.dart';
import '../routes/app_pages.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final ApiService _apiService = ApiService.to;
  
  final RxBool isLoading = false.obs;
  final RxString emailError = ''.obs;
  final RxString passwordError = ''.obs;
  final RxBool isPasswordVisible = false.obs;
  final RxBool hasConnectionError = false.obs;

  void validateEmail(String value) {
    if (value.isEmpty) {
      emailError.value = 'Email is required';
    } else if (!GetUtils.isEmail(value)) {
      emailError.value = 'Please enter a valid email';
    } else {
      emailError.value = '';
    }
  }

  void validatePassword(String value) {
    if (value.isEmpty) {
      passwordError.value = 'Password is required';
    } else if (value.length < 6) {
      passwordError.value = 'Password must be at least 6 characters';
    } else {
      passwordError.value = '';
    }
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void retryConnection() {
    hasConnectionError.value = false;
    login();
  }

  Future<void> login() async {
    try {
      // Show loading state
      isLoading.value = true;

      // Reset error messages
      emailError.value = '';
      passwordError.value = '';

      // Validate fields
      validateEmail(emailController.text);
      validatePassword(passwordController.text);

      // Check if there are any validation errors
      if (emailError.value.isNotEmpty || passwordError.value.isNotEmpty) {
        return;
      }

      // Make API call to login
      final response = await _apiService.login(
        email: emailController.text,
        password: passwordController.text,
      );

      if (response['success']) {
        // Show success message
        Get.snackbar(
          'Success',
          'Login successful!',
          backgroundColor: Colors.green[100],
          colorText: Colors.green[900],
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );

        // Navigate to home screen
        Get.offAllNamed(AppRoutes.home);
      } else {
        final errorMessage = response['message'] ?? 'Login failed';
        
        // Check for specific error types
        if (response['error_type'] == 'connection_error') {
          hasConnectionError.value = true;
          Get.snackbar(
            'Connection Error',
            'Unable to connect to server. Please check your internet connection.',
            backgroundColor: Colors.orange[100],
            colorText: Colors.orange[900],
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 5),
            icon: const Icon(Icons.wifi_off, color: Colors.orange),
            mainButton: TextButton(
              onPressed: retryConnection,
              child: const Text('Retry'),
            ),
          );
        } else if (errorMessage.toLowerCase().contains('email')) {
          emailError.value = errorMessage;
        } else if (errorMessage.toLowerCase().contains('password')) {
          passwordError.value = errorMessage;
        } else {
          Get.snackbar(
            'Login Error',
            errorMessage,
            backgroundColor: Colors.red[100],
            colorText: Colors.red[900],
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 5),
          );
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An unexpected error occurred',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
