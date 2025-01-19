import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../controllers/onboarding_controller.dart';

class OnboardingScreen extends GetView<OnboardingController> {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // PageView for onboarding pages
          PageView(
            controller: controller.pageController,
            onPageChanged: controller.onPageChanged,
            children: const [
              OnboardingPage(
                image: 'assets/images/onboarding1.png',
                title: 'Discover Books',
                description: 'Find your favorite books and discover new ones from our vast collection.',
                color: Color(0xFF2196F3),
              ),
              OnboardingPage(
                image: 'assets/images/onboarding2.png',
                title: 'Easy Reading',
                description: 'Read your books anytime, anywhere. Our app makes reading a breeze.',
                color: Color(0xFF4CAF50),
              ),
              OnboardingPage(
                image: 'assets/images/onboarding3.png',
                title: 'Save & Share',
                description: 'Bookmark your favorites and share them with friends and family.',
                color: Color(0xFFF44336),
              ),
            ],
          ),

          // Skip button
          Positioned(
            top: 50,
            right: 20,
            child: TextButton(
              onPressed: controller.skipToLogin,
              child: const Text(
                'Skip',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          // Bottom navigation
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Page indicator
                  Obx(
                    () => SmoothPageIndicator(
                      controller: controller.pageController,
                      count: 3,
                      effect: const WormEffect(
                        dotHeight: 10,
                        dotWidth: 10,
                        spacing: 8,
                        activeDotColor: Colors.blue,
                        dotColor: Colors.grey,
                      ),
                    ),
                  ),

                  // Next/Get Started button
                  Obx(
                    () => ElevatedButton(
                      onPressed: () => controller.nextPage(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        controller.currentPage.value == 2 ? 'Get Started' : 'Next',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final String image;
  final String title;
  final String description;
  final Color color;

  const OnboardingPage({
    super.key,
    required this.image,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      color: color,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image placeholder (replace with actual image)
          Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.book,
              size: 100,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 48),
          
          // Title
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Description
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
