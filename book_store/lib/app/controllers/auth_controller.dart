import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../routes/app_pages.dart';
import '../services/api_service.dart';

class AuthController extends GetxController {
  final ApiService _apiService = ApiService.to;
  
  // Loading and Error States
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  
  // Authentication States
  final RxBool isAuthenticated = false.obs;
  final Rx<String?> token = Rx<String?>(null);
  final Rx<Map<String, dynamic>?> userData = Rx<Map<String, dynamic>?>(null);

  // OTP Verification States
  final otpController = TextEditingController();
  final errorController = StreamController<ErrorAnimationType>.broadcast();
  final RxString currentText = ''.obs;
  final RxBool canResendCode = true.obs;
  final RxInt resendTimer = 60.obs;
  final RxInt remainingAttempts = 3.obs;  // Track remaining attempts
  Timer? _resendTimer;

  @override
  void onInit() {
    super.onInit();
    checkAuthStatus();
  }

  void startResendTimer() {
    canResendCode.value = false;
    resendTimer.value = 60;
    _resendTimer?.cancel(); // Cancel existing timer if any
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendTimer.value > 0) {
        resendTimer.value--;
      } else {
        canResendCode.value = true;
        timer.cancel();
      }
    });
  }

  Future<void> verifyOtp({required String email, required String otp}) async {
    try {
      if (isLoading.value) return;
      
      isLoading.value = true;
      errorMessage.value = '';
      
      // Check remaining attempts
      if (remainingAttempts.value <= 0) {
        errorController.add(ErrorAnimationType.shake);
        errorMessage.value = 'Too many invalid attempts. Please request a new code.';
        Get.snackbar(
          'Verification Locked',
          errorMessage.value,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900],
          duration: const Duration(seconds: 3),
        );
        return;
      }
      
      // Validate OTP format
      if (otp.length != 6 || !RegExp(r'^\d{6}$').hasMatch(otp)) {
        errorController.add(ErrorAnimationType.shake);
        errorMessage.value = 'Please enter a valid 6-digit code';
        Get.snackbar(
          'Invalid Code',
          errorMessage.value,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900],
          duration: const Duration(seconds: 3),
        );
        return;
      }
      
      final response = await _apiService.verifyOtp(email: email, otp: otp);
      print('Verification Response: $response'); // Debug log
      
      if (response['success'] == true) {
        // Clear OTP input and reset attempts
        otpController.clear();
        currentText.value = '';
        remainingAttempts.value = 3;
        
        Get.snackbar(
          'Success',
          'Email verified successfully. Please login to continue.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green[100],
          colorText: Colors.green[900],
          duration: const Duration(seconds: 2),
        );
        
        // Navigate to login after short delay to show success message
        await Future.delayed(const Duration(seconds: 1));
        Get.offAllNamed(AppRoutes.login);
      } else {
        // Handle specific error cases
        String errorMessage = '';
        switch (response['error']) {
          case 'ALREADY_VERIFIED':
            errorMessage = 'Email is already verified. Please login.';
            break;
          case 'CODE_EXPIRED':
            errorMessage = 'Code has expired. Please request a new code.';
            break;
          case 'INVALID_CODE':
            remainingAttempts.value--;
            errorMessage = 'Invalid code. ${remainingAttempts.value} attempts remaining.';
            break;
          case 'NO_CODE':
            errorMessage = 'No valid code found. Please request a new code.';
            break;
          default:
            errorMessage = response['message'] ?? 'Verification failed. Please try again.';
        }
        
        errorController.add(ErrorAnimationType.shake);
        this.errorMessage.value = errorMessage;
        
        Get.snackbar(
          'Verification Failed',
          errorMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900],
          duration: const Duration(seconds: 3),
        );
        
        // Clear OTP input on error
        otpController.clear();
        currentText.value = '';
        
        // If no attempts remaining, disable input
        if (remainingAttempts.value <= 0) {
          canResendCode.value = true;
          resendTimer.value = 0;
          if (_resendTimer?.isActive ?? false) {
            _resendTimer?.cancel();
          }
        }
      }
    } catch (e) {
      print('Verification Error: $e'); // Debug log
      errorController.add(ErrorAnimationType.shake);
      errorMessage.value = 'Failed to verify code. Please try again.';
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        duration: const Duration(seconds: 3),
      );
      
      // Clear OTP input on error
      otpController.clear();
      currentText.value = '';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resendVerificationCode(String email) async {
    try {
      if (isLoading.value || !canResendCode.value) return;
      
      isLoading.value = true;
      errorMessage.value = '';
      
      final response = await _apiService.resendVerification(email: email);
      
      if (response['success']) {
        // Reset attempts when new code is sent
        remainingAttempts.value = 3;
        
        Get.snackbar(
          'Success',
          'Verification code sent successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green[100],
          colorText: Colors.green[900],
          duration: const Duration(seconds: 2),
        );
        startResendTimer();
      } else {
        errorMessage.value = response['message'] ?? 'Failed to send verification code';
        Get.snackbar(
          'Error',
          errorMessage.value,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900],
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      errorMessage.value = 'Failed to send verification code. Please try again.';
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
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

      if (response['success'] == true) {
        // Store email for OTP verification
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('pending_verification_email', email);
        
        Get.snackbar(
          'Success',
          'Account created successfully. Please verify your email.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green[100],
          colorText: Colors.green[900],
          duration: const Duration(seconds: 3),
        );
        
        // Navigate to OTP verification screen
        Get.toNamed(
          AppRoutes.verifyOtp,
          arguments: {'email': email}
        );
      } else {
        Get.snackbar(
          'Error',
          response['message']?.toString() ?? 'Registration failed',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900],
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An unexpected error occurred',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        duration: const Duration(seconds: 3),
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
        isAuthenticated.value = true;
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
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      token.value = null;
      isAuthenticated.value = false;
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
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to logout. Please try again.',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void togglePasswordVisibility() {
    // isPasswordVisible.value = !isPasswordVisible.value;
  }

  void _setInitialScreen(bool isLoggedIn) {
    if (isLoggedIn) {
      Get.offAllNamed('/home');
    } else {
      Get.offAllNamed('/login');
    }
  }

  Future<void> checkAuthStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedToken = prefs.getString('auth_token');
      
      if (storedToken != null) {
        token.value = storedToken;
        isAuthenticated.value = true;
      }
    } catch (e) {
      isAuthenticated.value = false;
    }
  }

  @override
  void onClose() {
    otpController.dispose();
    errorController.close();
    _resendTimer?.cancel();
    super.onClose();
  }
}
