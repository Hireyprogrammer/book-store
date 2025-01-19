import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../services/api_service.dart';

class AuthBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApiService>(() => ApiService());
    Get.lazyPut<AuthController>(() => AuthController());
  }
}
