import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../controllers/home_controller.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(() => Text(
                          controller.greeting.value,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        )).animate().fadeIn(delay: 200.ms).slideX(),
                        const SizedBox(height: 4),
                        const Text(
                          'Find your favorite book',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ).animate().fadeIn(delay: 400.ms).slideX(),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 24,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: IconButton(
                          icon: const Icon(Icons.person, color: Colors.white),
                          onPressed: controller.openProfile,
                        ),
                      ),
                    ).animate().scale(delay: 600.ms),
                  ],
                ),
              ),
            ),

            // Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    onChanged: controller.onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Search for books...',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2),
            ),

            // Categories
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Categories',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ).animate().fadeIn(delay: 1000.ms),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 40,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _buildCategoryChip('Fiction', 0),
                          _buildCategoryChip('Non-Fiction', 1),
                          _buildCategoryChip('Science', 2),
                          _buildCategoryChip('Technology', 3),
                          _buildCategoryChip('Business', 4),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Featured Books
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Featured Books',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ).animate().fadeIn(delay: 1200.ms),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 240,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _buildBookCard(
                            'The Psychology of Money',
                            'Morgan Housel',
                            'assets/images/psychology_money.jpg',
                            0,
                          ),
                          _buildBookCard(
                            'Atomic Habits',
                            'James Clear',
                            'assets/images/atomic_habits.jpg',
                            1,
                          ),
                          _buildBookCard(
                            'Deep Work',
                            'Cal Newport',
                            'assets/images/deep_work.jpg',
                            2,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Popular Authors
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Popular Authors',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ).animate().fadeIn(delay: 1400.ms),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 100,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _buildAuthorCard('Morgan Housel', 0),
                          _buildAuthorCard('James Clear', 1),
                          _buildAuthorCard('Cal Newport', 2),
                          _buildAuthorCard('Robert Kiyosaki', 3),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label, int index) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Obx(() => ChoiceChip(
        label: Text(label),
        selected: controller.selectedTopics.contains(label),
        onSelected: (selected) => controller.toggleTopic(label),
        backgroundColor: Colors.white,
        selectedColor: const Color(0xFF2196F3).withOpacity(0.2),
        labelStyle: TextStyle(
          color: controller.selectedTopics.contains(label)
              ? const Color(0xFF2196F3)
              : Colors.grey[600],
          fontWeight: controller.selectedTopics.contains(label)
              ? FontWeight.w600
              : FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: controller.selectedTopics.contains(label)
                ? const Color(0xFF2196F3).withOpacity(0.5)
                : Colors.grey.withOpacity(0.2),
          ),
        ),
        elevation: 0,
        pressElevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      )),
    ).animate().fadeIn(delay: Duration(milliseconds: 1000 + (index * 100))).slideX();
  }

  Widget _buildBookCard(String title, String author, String imageUrl, int index) {
    return GestureDetector(
      onTap: controller.openBookDetails,
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Image.asset(
                imageUrl,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    author,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 1200 + (index * 100))).slideX();
  }

  Widget _buildAuthorCard(String name, int index) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey[300],
            child: Text(
              name[0],
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 1400 + (index * 100))).scale();
  }
}
