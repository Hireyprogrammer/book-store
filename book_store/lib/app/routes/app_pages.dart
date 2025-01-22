import 'package:get/get.dart';
import '../ui/screens/splash/splash_screen.dart';
import '../ui/screens/login/login_screen.dart';
import '../ui/screens/signup/signup_screen.dart';
import '../ui/screens/home/home_screen.dart';
import '../ui/screens/book_details/book_details_screen.dart';
import '../ui/screens/forgot_password/forgot_password_screen.dart';
import '../ui/screens/otp_verification/verify_otp_screen.dart';
import '../controllers/verify_otp_controller.dart';
import '../bindings/splash_binding.dart';
import '../bindings/login_binding.dart';
import '../bindings/signup_binding.dart';
import '../bindings/home_binding.dart';
import '../bindings/book_details_binding.dart';
import '../bindings/auth_binding.dart';
import '../bindings/forgot_password_binding.dart';

part 'app_routes.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String bookDetails = '/book_details';
  static const String forgotPassword = '/forgot_password';
  static const String verifyOtp = '/verify_otp';
}

class AppPages {
  AppPages._();

  // Remove the initial route definition since it's now set in main.dart
  
  static final routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
      binding: SplashBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
      binding: LoginBinding(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: AppRoutes.signup,
      page: () => const SignupScreen(),
      binding: SignupBinding(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
      binding: HomeBinding(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: AppRoutes.bookDetails,
      page: () => const BookDetailsScreen(),
      binding: BookDetailsBinding(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => const ForgotPasswordScreen(),
      binding: ForgotPasswordBinding(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: AppRoutes.verifyOtp,
      page: () => const VerifyOtpScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<VerifyOtpController>(() => VerifyOtpController(), fenix: true);
      }),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 500),
    ),
  ];
}
