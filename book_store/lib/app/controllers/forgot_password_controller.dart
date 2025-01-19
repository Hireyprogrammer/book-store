import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/api_service.dart';
import '../routes/app_pages.dart';

class ForgotPasswordController extends GetxController {
  final ApiService _apiService = ApiService.to;

  // Text Controller
  final TextEditingController emailController = TextEditingController();

  // Observables for form state and validation
  final RxString emailError = RxString('');
  final RxBool isLoading = false.obs;

  // Computed observable for reset button state
  RxBool get isEmailValid => 
    RxBool(emailError.value.isEmpty && 
           emailController.text.isNotEmpty);

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
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

  Future<void> resetPassword() async {
    // Validate email before attempting reset
    validateEmail(emailController.text);

    if (emailError.value.isNotEmpty) {
      return;
    }

    isLoading.value = true;

    try {
      final response = await _apiService.resetPassword(
        email: emailController.text.trim()
      );

      if (response['success']) {
        // Show success message
        Get.snackbar(
          'Success', 
          'Password reset link sent to your email',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Navigate back to login
        navigateToLogin();
      } else {
        // Show error message
        Get.snackbar(
          'Reset Failed', 
          response['message'] ?? 'Unable to send reset link',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error', 
        'An unexpected error occurred: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void navigateToLogin() {
    Get.offNamed(AppRoutes.login);
  }
}
