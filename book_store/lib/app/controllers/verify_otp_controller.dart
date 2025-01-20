import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/api_service.dart';
import '../routes/app_pages.dart';

class VerifyOtpController extends GetxController {
  final otpController = TextEditingController();
  final ApiService _apiService = ApiService.to;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  Future<void> verifyOtp(String email) async {
    isLoading.value = true;
    errorMessage.value = '';
    
    try {
      final otp = otpController.text;
      final response = await _apiService.verifyOtp(email: email, otp: otp);

      if (response['success']) {
        Get.snackbar(
          'Success',
          'Email verified successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green[100],
          colorText: Colors.green[900],
        );
        // Navigate to the home screen after successful verification
        Get.offAllNamed(AppRoutes.home);
      } else {
        // Show error message to user
        errorMessage.value = response['message'] ?? 'Verification failed';
        Get.snackbar(
          'Error',
          errorMessage.value,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900],
        );
      }
    } catch (e) {
      errorMessage.value = 'An error occurred during verification';
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

  Future<void> resendOtp(String email) async {
    if (isLoading.value) return; // Prevent multiple requests
    
    isLoading.value = true;
    errorMessage.value = '';
    
    try {
      final response = await _apiService.resendVerification(email: email);

      if (response['success']) {
        Get.snackbar(
          'Success',
          'Verification code has been resent to your email',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green[100],
          colorText: Colors.green[900],
        );
      } else {
        errorMessage.value = response['message'] ?? 'Failed to resend verification code';
        Get.snackbar(
          'Error',
          errorMessage.value,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900],
        );
      }
    } catch (e) {
      errorMessage.value = 'An error occurred while resending verification code';
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
    otpController.dispose();
    super.onClose();
  }
}
