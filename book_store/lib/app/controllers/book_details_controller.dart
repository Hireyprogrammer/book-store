import 'package:get/get.dart';
import '../data/models/book_model.dart';

class BookDetailsController extends GetxController {
  // Book data
  final Rx<Book> book = Book.sampleBooks.first.obs;
  
  // UI States
  final RxBool isLoading = false.obs;
  final RxBool isFavorite = false.obs;
  final RxBool isDownloading = false.obs;
  final RxDouble downloadProgress = 0.0.obs;
  final RxBool isInLibrary = false.obs;

  // Reading progress
  final RxInt currentPage = 0.obs;
  final RxDouble readingProgress = 0.0.obs;
  final RxString lastReadDate = ''.obs;

  // Book ID to load
  final String? bookId;

  BookDetailsController({this.bookId});

  @override
  void onInit() {
    super.onInit();
    if (bookId != null) {
      book.value = Book.getSampleById(bookId!);
    }
    _loadBookDetails();
    _checkIfInLibrary();
    _loadReadingProgress();
  }

  Future<void> _loadBookDetails() async {
    isLoading.value = true;
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      // In a real app, you would fetch book details from an API
      // book.value = await bookRepository.getBookDetails(bookId);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load book details',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _checkIfInLibrary() async {
    // Simulate checking if book is in user's library
    await Future.delayed(const Duration(milliseconds: 500));
    isInLibrary.value = book.value.isPremium ? false : true;
  }

  Future<void> _loadReadingProgress() async {
    // Simulate loading reading progress
    await Future.delayed(const Duration(milliseconds: 500));
    currentPage.value = 0;
    readingProgress.value = 0.0;
    lastReadDate.value = DateTime.now().toString();
  }

  void toggleFavorite() {
    isFavorite.value = !isFavorite.value;
    Get.snackbar(
      'Success',
      isFavorite.value 
          ? 'Added ${book.value.title} to favorites' 
          : 'Removed ${book.value.title} from favorites',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> downloadBook() async {
    if (isDownloading.value) return;

    if (book.value.isPremium) {
      Get.snackbar(
        'Premium Content',
        'This book requires a premium subscription',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isDownloading.value = true;
    downloadProgress.value = 0.0;

    try {
      // Simulate download progress
      final totalSize = double.parse(
        book.value.fileSize.replaceAll(' MB', ''),
      );
      
      for (var i = 0; i <= 100; i += 10) {
        await Future.delayed(const Duration(milliseconds: 200));
        downloadProgress.value = i / 100;
        
        // Show progress with file size
        if (i % 20 == 0) {
          Get.snackbar(
            'Downloading',
            'Downloaded ${(totalSize * downloadProgress.value).toStringAsFixed(1)} MB of ${book.value.fileSize}',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      }
      
      isInLibrary.value = true;
      Get.snackbar(
        'Success',
        '${book.value.title} downloaded successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to download ${book.value.title}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isDownloading.value = false;
    }
  }

  Future<void> startReading() async {
    if (!isInLibrary.value) {
      if (book.value.isPremium) {
        Get.snackbar(
          'Premium Content',
          'Please subscribe to read this book',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
      await downloadBook();
    }
    
    if (isInLibrary.value) {
      // In a real app, you would navigate to the reading screen
      Get.snackbar(
        'Opening ${book.value.title}',
        'Starting from page ${currentPage.value}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void shareBook() {
    final bookInfo = '''
${book.value.title}
By ${book.value.author}
Published by ${book.value.publisher}
ISBN: ${book.value.isbn}
    ''';
    
    // Implement share functionality
    Get.snackbar(
      'Share',
      'Sharing $bookInfo',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void addToReadingList() {
    Get.snackbar(
      'Reading List',
      'Added ${book.value.title} to reading list',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void reportIssue() {
    Get.snackbar(
      'Report',
      'Thank you for reporting an issue with ${book.value.title}',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  String get bookFormat => book.value.format.toUpperCase();
  
  String get readingTime => 
      book.value.metadata?['readingTime'] ?? 'Unknown reading time';
  
  bool get isBestseller => 
      book.value.metadata?['bestseller'] ?? false;
  
  List<String> get awards => 
      (book.value.metadata?['awards'] as List<String>?) ?? [];

  @override
  void onClose() {
    // Clean up any resources
    super.onClose();
  }
}
