import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/api_service.dart';
import '../routes/app_pages.dart';

class LoginController extends GetxController {
  TextEditingController? _emailController;
  TextEditingController? _passwordController;
  final ApiService _apiService = ApiService.to;
  
  final RxBool isLoading = false.obs;
  final RxString emailError = ''.obs;
  final RxString passwordError = ''.obs;
  final RxBool isPasswordVisible = false.obs;
  final RxBool hasConnectionError = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString token = ''.obs;
  final RxBool isAuthenticated = false.obs;
  final RxMap userData = {}.obs;

  void setControllers(TextEditingController email, TextEditingController password) {
    _emailController = email;
    _passwordController = password;
  }

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
    if (_emailController == null || _passwordController == null) return;
    
    try {
      if (isLoading.value) return;
      
      isLoading.value = true;
      errorMessage.value = '';
      
      // Basic validation
      if (_emailController!.text.isEmpty || !GetUtils.isEmail(_emailController!.text)) {
        errorMessage.value = 'Please enter a valid email address';
        Get.snackbar(
          'Invalid Email',
          errorMessage.value,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900],
          duration: const Duration(seconds: 3),
        );
        return;
      }
      
      if (_passwordController!.text.isEmpty || _passwordController!.text.length < 6) {
        errorMessage.value = 'Password must be at least 6 characters';
        Get.snackbar(
          'Invalid Password',
          errorMessage.value,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900],
          duration: const Duration(seconds: 3),
        );
        return;
      }
      
      final response = await _apiService.login(
        email: _emailController!.text,
        password: _passwordController!.text,
      );
      
      if (response['success'] == true) {
        // Store user data
        if (response['token'] != null) {
          token.value = response['token'];
          isAuthenticated.value = true;
          
          if (response['user'] != null) {
            userData.value = response['user'];
          }
          
          Get.snackbar(
            'Success',
            'Login successful',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green[100],
            colorText: Colors.green[900],
          );
          
          Get.offAllNamed(AppRoutes.home);
        }
      } else {
        errorMessage.value = response['message'] ?? 'Login failed';
        Get.snackbar(
          'Error',
          errorMessage.value,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900],
        );
      }
    } catch (e) {
      hasConnectionError.value = true;
      errorMessage.value = 'Connection error. Please check your internet connection.';
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    _emailController = null;
    _passwordController = null;
    super.onClose();
  }
}
