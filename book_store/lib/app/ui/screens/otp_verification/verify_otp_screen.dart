import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../../controllers/auth_controller.dart';
import '../../../theme/app_theme.dart';

class VerifyOtpScreen extends GetView<AuthController> {
  const VerifyOtpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final email = Get.arguments['email'] as String;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Obx(() => SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Text(
                'Verify Your Email',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Please enter the 6-digit code sent to:',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                email,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              PinCodeTextField(
                appContext: context,
                length: 6,
                obscureText: false,
                animationType: AnimationType.fade,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(8),
                  fieldHeight: 50,
                  fieldWidth: 45,
                  activeFillColor: Colors.white,
                  activeColor: Theme.of(context).primaryColor,
                  selectedColor: Theme.of(context).primaryColor,
                  inactiveColor: Colors.grey[300],
                ),
                animationDuration: const Duration(milliseconds: 300),
                backgroundColor: Colors.transparent,
                enableActiveFill: false,
                errorAnimationController: controller.errorController,
                controller: controller.otpController,
                onCompleted: (value) {
                  // Auto verify when all digits are entered
                  controller.verifyOtp(email: email, otp: value);
                },
                onChanged: (value) {
                  controller.currentText.value = value;
                },
                beforeTextPaste: (text) {
                  // Allow only digits
                  if (text == null) return false;
                  return text.length == 6 && int.tryParse(text) != null;
                },
              ),
              const SizedBox(height: 24),
              if (controller.isLoading.value)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: controller.currentText.value.length == 6
                      ? () => controller.verifyOtp(
                          email: email,
                          otp: controller.currentText.value,
                        )
                      : null,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Verify Email'),
                ),
              const SizedBox(height: 24),
              TextButton.icon(
                onPressed: controller.canResendCode.value
                    ? () => controller.resendVerificationCode(email)
                    : null,
                icon: const Icon(Icons.refresh),
                label: Text(
                  controller.canResendCode.value
                      ? 'Resend Code'
                      : 'Resend in ${controller.resendTimer.value}s',
                ),
              ),
            ],
          ),
        ),
      )),
    );
  }
}
