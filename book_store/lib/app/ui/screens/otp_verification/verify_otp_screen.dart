import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../controllers/verify_otp_controller.dart';

class VerifyOtpScreen extends GetView<VerifyOtpController> {
  const VerifyOtpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String email = Get.arguments['email'] as String;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Verify Your Email', style: GoogleFonts.poppins()),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Enter the verification code sent to',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              email,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            TextField(
              controller: controller.otpController,
              decoration: InputDecoration(
                labelText: 'Verification Code',
                hintText: '000000',
                prefixIcon: const Icon(Icons.lock_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 2,
                  ),
                ),
              ),
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              maxLength: 6,
              onChanged: (value) {
                // Clear error message when user starts typing
                if (controller.errorMessage.isNotEmpty) {
                  controller.errorMessage.value = '';
                }
              },
            ),
            const SizedBox(height: 24),
            Obx(() => ElevatedButton(
              onPressed: controller.isLoading.value
                  ? null
                  : () {
                      if (controller.otpController.text.length == 6) {
                        controller.verifyOtp(email);
                      } else {
                        Get.snackbar(
                          'Invalid Code',
                          'Please enter a 6-digit verification code',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.red[100],
                          colorText: Colors.red[900],
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: controller.isLoading.value
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Verify Code',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            )),
            const SizedBox(height: 16),
            Obx(() => TextButton(
              onPressed: controller.isLoading.value
                  ? null
                  : () => controller.resendOtp(email),
              child: Text(
                'Resend Code',
                style: GoogleFonts.poppins(
                  color: controller.isLoading.value
                      ? Colors.grey
                      : Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}
