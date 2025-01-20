import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/api_service.dart';
import '../routes/app_pages.dart';

class LoginController extends GetxController {
  late final TextEditingController emailController;
  late final TextEditingController passwordController;
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
      if (isLoading.value) return;
      
      isLoading.value = true;
      errorMessage.value = '';
      
      // Basic validation
      if (emailController.text.isEmpty || !GetUtils.isEmail(emailController.text)) {
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
      
      if (passwordController.text.isEmpty || passwordController.text.length < 6) {
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
        email: emailController.text,
        password: passwordController.text,
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
            duration: const Duration(seconds: 2),
          );
          
          // Navigate to home after short delay
          await Future.delayed(const Duration(seconds: 1));
          Get.offAllNamed(AppRoutes.home);
        }
      } else {
        String errorMessage = '';
        switch (response['error']) {
          case 'EMAIL_NOT_VERIFIED':
            errorMessage = response['message'] ?? 'Please verify your email before logging in';
            Get.snackbar(
              'Email Not Verified',
              errorMessage,
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.orange[100],
              colorText: Colors.orange[900],
              duration: const Duration(seconds: 5),
              mainButton: TextButton(
                onPressed: () => Get.toNamed(
                  AppRoutes.verifyOtp,
                  arguments: {'email': emailController.text},
                ),
                child: const Text('Verify Now'),
              ),
            );
            break;
          case 'INVALID_CREDENTIALS':
            errorMessage = 'Invalid email or password';
            Get.snackbar(
              'Login Failed',
              errorMessage,
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red[100],
              colorText: Colors.red[900],
              duration: const Duration(seconds: 3),
            );
            break;
          default:
            errorMessage = response['message'] ?? 'Login failed. Please try again.';
            Get.snackbar(
              'Login Failed',
              errorMessage,
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red[100],
              colorText: Colors.red[900],
              duration: const Duration(seconds: 3),
            );
        }
      }
    } catch (e) {
      print('Login Error: $e');
      Get.snackbar(
        'Error',
        'Failed to login. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
