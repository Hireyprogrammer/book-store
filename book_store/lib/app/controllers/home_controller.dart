import 'package:get/get.dart';
import '../routes/app_pages.dart';

class HomeController extends GetxController {
  final RxString searchQuery = ''.obs;
  final RxList<String> selectedTopics = <String>[].obs;
  final RxString greeting = 'Good Morning'.obs;

  @override
  void onInit() {
    super.onInit();
    _updateGreeting();
  }

  void _updateGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      greeting.value = 'Good Morning';
    } else if (hour < 17) {
      greeting.value = 'Good Afternoon';
    } else {
      greeting.value = 'Good Evening';
    }
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    // Implement search functionality
  }

  void toggleTopic(String topic) {
    if (selectedTopics.contains(topic)) {
      selectedTopics.remove(topic);
    } else {
      selectedTopics.add(topic);
    }
  }

  void openBookDetails() {
    Get.toNamed(Routes.BOOK_DETAILS);
  }

  void openProfile() {
    Get.snackbar(
      'Coming Soon',
      'Profile functionality will be available soon!',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
