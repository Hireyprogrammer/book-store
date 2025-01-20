import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../../controllers/auth_controller.dart';
import '../../../theme/app_theme.dart';
import 'package:lottie/lottie.dart';

class VerifyOtpScreen extends GetView<AuthController> {
  const VerifyOtpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final email = Get.arguments['email'] as String;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Verify Email'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: theme.primaryColor),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() => SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // Email verification animation with error handling
              Container(
                height: 200,
                child: Lottie.network(
                  'https://assets3.lottiefiles.com/packages/lf20_qwl4gi2d.json', // Email verification animation
                  height: 200,
                  repeat: true,
                  errorBuilder: (context, error, stackTrace) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.mark_email_unread_rounded,
                          size: 80,
                          color: theme.primaryColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Verify your email',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: theme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),
              // Title with gradient
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [theme.primaryColor, theme.colorScheme.secondary],
                ).createShader(bounds),
                child: Text(
                  'Verify Your Email',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Instructions
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      'Please enter the 6-digit code sent to:',
                      style: theme.textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      email,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // OTP Input field
              Obx(() => Column(
                children: [
                  // Remaining attempts indicator
                  if (controller.remainingAttempts.value < 3) 
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: controller.remainingAttempts.value > 0 
                            ? Colors.orange[100] 
                            : Colors.red[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: controller.remainingAttempts.value > 0 
                              ? Colors.orange 
                              : Colors.red,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            controller.remainingAttempts.value > 0 
                                ? Icons.warning_amber_rounded 
                                : Icons.error_outline,
                            color: controller.remainingAttempts.value > 0 
                                ? Colors.orange[900] 
                                : Colors.red[900],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            controller.remainingAttempts.value > 0
                                ? '${controller.remainingAttempts.value} attempts remaining'
                                : 'No attempts remaining. Please request a new code.',
                            style: TextStyle(
                              color: controller.remainingAttempts.value > 0 
                                  ? Colors.orange[900] 
                                  : Colors.red[900],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  PinCodeTextField(
                    appContext: context,
                    length: 6,
                    obscureText: false,
                    animationType: AnimationType.scale,
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(12),
                      fieldHeight: 56,
                      fieldWidth: 48,
                      activeFillColor: theme.primaryColor.withOpacity(0.1),
                      activeColor: theme.primaryColor,
                      selectedColor: theme.primaryColor,
                      selectedFillColor: theme.primaryColor.withOpacity(0.2),
                      inactiveFillColor: theme.cardColor,
                      inactiveColor: theme.dividerColor,
                    ),
                    animationDuration: const Duration(milliseconds: 300),
                    backgroundColor: Colors.transparent,
                    enableActiveFill: true,
                    errorAnimationController: controller.errorController,
                    controller: controller.otpController,
                    keyboardType: TextInputType.number,
                    onCompleted: (value) {
                      controller.verifyOtp(email: email, otp: value);
                    },
                    onChanged: (value) {
                      controller.currentText.value = value;
                    },
                    beforeTextPaste: (text) {
                      return text?.length == 6 && int.tryParse(text!) != null;
                    },
                  ),
                ],
              )),
              const SizedBox(height: 32),
              // Verify Button with loading state
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.currentText.value.length == 6
                          ? () => controller.verifyOtp(
                              email: email,
                              otp: controller.currentText.value,
                            )
                          : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: controller.isLoading.value ? 0 : 2,
                  ),
                  child: controller.isLoading.value
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Verify Email',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
              // Resend button with timer
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: theme.dividerColor,
                    width: 1,
                  ),
                ),
                child: TextButton.icon(
                  onPressed: controller.canResendCode.value
                      ? () => controller.resendVerificationCode(email)
                      : null,
                  icon: Icon(
                    Icons.refresh,
                    color: controller.canResendCode.value
                        ? theme.primaryColor
                        : theme.disabledColor,
                  ),
                  label: Text(
                    controller.canResendCode.value
                        ? 'Resend Code'
                        : 'Resend in ${controller.resendTimer.value}s',
                    style: TextStyle(
                      color: controller.canResendCode.value
                          ? theme.primaryColor
                          : theme.disabledColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      )),
    );
  }
}
