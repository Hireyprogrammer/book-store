import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/api_service.dart';
import '../routes/app_pages.dart';

class SignupController extends GetxController {
  final ApiService _apiService = ApiService.to;

  // Text Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  // Observables for form state and validation
  final RxBool isPasswordVisible = false.obs;
  final RxString nameError = RxString('');
  final RxString emailError = RxString('');
  final RxString passwordError = RxString('');
  final RxString confirmPasswordError = RxString('');
  final RxBool isLoading = false.obs;
  
  // Computed observable for signup button state
  RxBool get isSignupValid => 
    RxBool(nameError.value.isEmpty && 
           emailError.value.isEmpty && 
           passwordError.value.isEmpty && 
           confirmPasswordError.value.isEmpty &&
           nameController.text.isNotEmpty &&
           emailController.text.isNotEmpty &&
           passwordController.text.isNotEmpty &&
           confirmPasswordController.text.isNotEmpty);

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void validateName(String? name) {
    if (name == null || name.isEmpty) {
      nameError.value = 'Name is required';
    } else if (name.length < 2) {
      nameError.value = 'Name must be at least 2 characters';
    } else if (!_isValidName(name)) {
      nameError.value = 'Please enter a valid name';
    } else {
      nameError.value = '';
    }
  }

  bool _isValidName(String name) {
    // Basic name validation: allows letters, spaces, and hyphens
    final nameRegex = RegExp(r'^[a-zA-Z\s-]+$');
    return nameRegex.hasMatch(name);
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
    } else if (password.length < 8) {
      passwordError.value = 'Password must be at least 8 characters';
    } else if (!_isStrongPassword(password)) {
      passwordError.value = 'Password must include uppercase, lowercase, number, and symbol';
    } else {
      passwordError.value = '';
    }
    validateConfirmPassword(confirmPasswordController.text);
  }

  void validateConfirmPassword(String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      confirmPasswordError.value = 'Please confirm your password';
    } else if (confirmPassword != passwordController.text) {
      confirmPasswordError.value = 'Passwords do not match';
    } else {
      confirmPasswordError.value = '';
    }
  }

  bool _isStrongPassword(String password) {
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasLowercase = password.contains(RegExp(r'[a-z]'));
    final hasNumber = password.contains(RegExp(r'[0-9]'));
    final hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    return hasUppercase && hasLowercase && hasNumber && hasSpecialChar;
  }

  Future<void> signUp() async {
    isLoading.value = true;
    nameError.value = '';
    emailError.value = '';
    passwordError.value = '';
    confirmPasswordError.value = '';

    if (nameController.text.isEmpty) {
      nameError.value = 'Name is required';
    }
    if (emailController.text.isEmpty) {
      emailError.value = 'Email is required';
    }
    if (passwordController.text.isEmpty) {
      passwordError.value = 'Password is required';
    }
    if (confirmPasswordController.text.isEmpty) {
      confirmPasswordError.value = 'Confirm password is required';
    }
    if (passwordController.text != confirmPasswordController.text) {
      confirmPasswordError.value = 'Passwords do not match';
    }

    if (nameError.value.isEmpty && emailError.value.isEmpty && passwordError.value.isEmpty && confirmPasswordError.value.isEmpty) {
      final response = await _apiService.register(
        name: nameController.text,
        email: emailController.text,
        password: passwordController.text,
      );

      if (response['success']) {
        // Navigate to the OTP verification screen
        Get.toNamed(Routes.OTP_VERIFICATION);
      } else {
        // Handle error message
        emailError.value = response['message'];
      }
    }
    isLoading.value = false;
  }

  void navigateToLogin() {
    Get.toNamed(AppRoutes.login);
  }
}
