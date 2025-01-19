import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/book_details_controller.dart';

class BookDetailsScreen extends GetView<BookDetailsController> {
  const BookDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return CustomScrollView(
          slivers: [
            _buildAppBar(context),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBookInfo(context),
                    const SizedBox(height: 20),
                    _buildRatingAndPrice(context),
                    const SizedBox(height: 24),
                    _buildDescription(context),
                    const SizedBox(height: 24),
                    _buildBookDetails(context),
                    const SizedBox(height: 24),
                    _buildActionButtons(context),
                    const SizedBox(height: 32),
                    _buildReadButton(context),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              color: Theme.of(context).colorScheme.primary,
              child: const Center(
                child: Icon(Icons.book, size: 100, color: Colors.white),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 30,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        Obx(() => IconButton(
              icon: Icon(
                controller.isFavorite.value
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: Colors.white,
              ),
              onPressed: controller.toggleFavorite,
            )),
        IconButton(
          icon: const Icon(Icons.share, color: Colors.white),
          onPressed: controller.shareBook,
        ),
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onPressed: () => _showMoreOptions(context),
        ),
      ],
    );
  }

  Widget _buildBookInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          controller.book.value.title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const CircleAvatar(
              radius: 15,
              child: Icon(Icons.person, size: 20),
            ),
            const SizedBox(width: 8),
            Text(
              'By ${controller.book.value.author}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRatingAndPrice(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 20),
            const SizedBox(width: 4),
            Text(
              '${controller.book.value.rating}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '(${controller.book.value.ratingCount} ratings)',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
        Text(
          controller.book.value.price,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildDescription(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          controller.book.value.description,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildBookDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Book Details',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        _buildDetailRow('Language', controller.book.value.language),
        _buildDetailRow('Pages', controller.book.value.pages.toString()),
        _buildDetailRow('Published', controller.book.value.publishedDate),
        _buildDetailRow(
          'Categories',
          controller.book.value.categories.join(', '),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(
          icon: Icons.bookmark_border,
          label: 'Reading List',
          onTap: controller.addToReadingList,
        ),
        _buildActionButton(
          icon: Icons.share,
          label: 'Share',
          onTap: controller.shareBook,
        ),
        _buildActionButton(
          icon: Icons.flag_outlined,
          label: 'Report',
          onTap: controller.reportIssue,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: Colors.grey[600]),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadButton(BuildContext context) {
    return Obx(() {
      if (controller.isDownloading.value) {
        return Column(
          children: [
            LinearProgressIndicator(
              value: controller.downloadProgress.value,
            ),
            const SizedBox(height: 8),
            Text(
              'Downloading... ${(controller.downloadProgress.value * 100).toInt()}%',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        );
      }

      return SizedBox(
        width: double.infinity,
        height: 55,
        child: ElevatedButton(
          onPressed: controller.startReading,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          child: Text(
            controller.isInLibrary.value ? 'Continue Reading' : 'Start Reading',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    });
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.bookmark_add),
            title: const Text('Add to Reading List'),
            onTap: () {
              Get.back();
              controller.addToReadingList();
            },
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Share'),
            onTap: () {
              Get.back();
              controller.shareBook();
            },
          ),
          ListTile(
            leading: const Icon(Icons.flag),
            title: const Text('Report an Issue'),
            onTap: () {
              Get.back();
              controller.reportIssue();
            },
          ),
        ],
      ),
    );
  }
}
