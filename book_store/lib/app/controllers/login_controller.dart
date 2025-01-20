import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/api_service.dart';
import '../routes/app_pages.dart';

class LoginController extends GetxController {
  final ApiService _apiService = ApiService.to;

  // Text Controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Observables for form state and validation
  final RxBool isPasswordVisible = false.obs;
  final RxString emailError = RxString('');
  final RxString passwordError = RxString('');
  final RxBool isLoading = false.obs;
  
  // Computed observable for login button state
  RxBool get isLoginValid => 
    RxBool(emailError.value.isEmpty && 
           passwordError.value.isEmpty && 
           emailController.text.isNotEmpty && 
           passwordController.text.isNotEmpty);

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      emailError.value = 'Email is required';
    } else if (!GetUtils.isEmail(email)) {
      emailError.value = 'Invalid email format';
    } else {
      emailError.value = '';
    }
  }

  void validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      passwordError.value = 'Password is required';
    } else if (password.length < 6) {
      passwordError.value = 'Password must be at least 6 characters';
    } else {
      passwordError.value = '';
    }
  }

  Future<void> login() async {
    try {
      // Validate inputs first
      if (!isLoginValid.value) {
        Get.snackbar(
          'Login Error', 
          'Please check your email and password',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      isLoading.value = true;

      // Perform server health check first
      final healthCheck = await ApiService.to.checkServerHealth();
      if (!healthCheck['success']) {
        Get.snackbar(
          'Server Unavailable', 
          healthCheck['message'] ?? 'Could not connect to server',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
        isLoading.value = false;
        return;
      }

      // Proceed with login
      final response = await ApiService.to.login(
        email: emailController.text.trim(), 
        password: passwordController.text.trim()
      );

      isLoading.value = false;

      if (response['success'] == true) {
        // Successful login
        Get.offAllNamed(AppRoutes.home);
      } else {
        // Login failed
        Get.snackbar(
          'Login Failed',
          response['message'] ?? 'Invalid email or password',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      isLoading.value = false;
      print('Login Error Details: $e');  // Detailed error logging
      Get.snackbar(
        'Connection Error', 
        'Unable to connect to the server. Please check your network and try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    }
  }

  Future<void> _storeUserSession(Map<String, dynamic> response) async {
    // TODO: Implement secure token storage using SharedPreferences or secure storage
    // Example:
    // await SharedPreferences.getInstance().then((prefs) {
    //   prefs.setString('auth_token', response['token']);
    //   prefs.setString('user_id', response['user_id']);
    // });
  }

  void navigateToSignup() {
    Get.toNamed(AppRoutes.signup);
  }

  void forgotPassword() {
    Get.toNamed(AppRoutes.forgotPassword);
  }
}
