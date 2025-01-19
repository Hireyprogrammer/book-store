import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../routes/app_pages.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Simulate initialization delay for 5 seconds
      await Future.delayed(const Duration(seconds: 5));
      
      // Navigate to login screen
      Get.offAllNamed(Routes.LOGIN);
    } catch (e) {
      print('Error during initialization: $e');
      // Still navigate to login screen even if there's an error
      Get.offAllNamed(Routes.LOGIN);
    }
  }
}
