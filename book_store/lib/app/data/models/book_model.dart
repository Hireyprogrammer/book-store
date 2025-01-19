import 'dart:convert';

class Book {
  final String id;
  final String title;
  final String author;
  final String description;
  final double rating;
  final int ratingCount;
  final String price;
  final String coverUrl;
  final List<String> categories;
  final String language;
  final int pages;
  final String publishedDate;
  final String publisher;
  final String isbn;
  final int downloadCount;
  final bool isPremium;
  final String fileSize;
  final String format;
  final Map<String, dynamic>? metadata;

  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.rating,
    required this.ratingCount,
    required this.price,
    required this.coverUrl,
    required this.categories,
    required this.language,
    required this.pages,
    required this.publishedDate,
    required this.publisher,
    required this.isbn,
    required this.downloadCount,
    required this.isPremium,
    required this.fileSize,
    required this.format,
    this.metadata,
  });

  // Create a Book from JSON data
  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      author: json['author'] as String? ?? '',
      description: json['description'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      ratingCount: json['ratingCount'] as int? ?? 0,
      price: json['price'] as String? ?? '',
      coverUrl: json['coverUrl'] as String? ?? '',
      categories: (json['categories'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? [],
      language: json['language'] as String? ?? '',
      pages: json['pages'] as int? ?? 0,
      publishedDate: json['publishedDate'] as String? ?? '',
      publisher: json['publisher'] as String? ?? '',
      isbn: json['isbn'] as String? ?? '',
      downloadCount: json['downloadCount'] as int? ?? 0,
      isPremium: json['isPremium'] as bool? ?? false,
      fileSize: json['fileSize'] as String? ?? '0 MB',
      format: json['format'] as String? ?? 'PDF',
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  // Convert Book to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'description': description,
      'rating': rating,
      'ratingCount': ratingCount,
      'price': price,
      'coverUrl': coverUrl,
      'categories': categories,
      'language': language,
      'pages': pages,
      'publishedDate': publishedDate,
      'publisher': publisher,
      'isbn': isbn,
      'downloadCount': downloadCount,
      'isPremium': isPremium,
      'fileSize': fileSize,
      'format': format,
      if (metadata != null) 'metadata': metadata,
    };
  }

  // Copy with method for immutable updates
  Book copyWith({
    String? id,
    String? title,
    String? author,
    String? description,
    double? rating,
    int? ratingCount,
    String? price,
    String? coverUrl,
    List<String>? categories,
    String? language,
    int? pages,
    String? publishedDate,
    String? publisher,
    String? isbn,
    int? downloadCount,
    bool? isPremium,
    String? fileSize,
    String? format,
    Map<String, dynamic>? metadata,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      description: description ?? this.description,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      price: price ?? this.price,
      coverUrl: coverUrl ?? this.coverUrl,
      categories: categories ?? this.categories,
      language: language ?? this.language,
      pages: pages ?? this.pages,
      publishedDate: publishedDate ?? this.publishedDate,
      publisher: publisher ?? this.publisher,
      isbn: isbn ?? this.isbn,
      downloadCount: downloadCount ?? this.downloadCount,
      isPremium: isPremium ?? this.isPremium,
      fileSize: fileSize ?? this.fileSize,
      format: format ?? this.format,
      metadata: metadata ?? this.metadata,
    );
  }

  // Helper methods for metadata
  List<String> get awards => 
      (metadata?['awards'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];

  String? get readingTime => metadata?['readingTime'] as String?;

  bool get isBestseller => metadata?['bestseller'] as bool? ?? false;

  // Sample books for testing
  static const List<Book> sampleBooks = [
    Book(
      id: '1',
      title: 'Psychology of Money',
      author: 'Morgan Housel',
      description: 'Timeless lessons on wealth, greed, and happiness. Doing well with money isn\'t necessarily about what you know. '
          'It\'s about how you behave. And behavior is hard to teach, even to really smart people.',
      rating: 4.5,
      ratingCount: 2354,
      price: 'Free',
      coverUrl: 'assets/images/psychology_of_money.jpg',
      categories: ['Finance', 'Psychology', 'Self Help'],
      language: 'English',
      pages: 256,
      publishedDate: '2020-09-08',
      publisher: 'Harriman House',
      isbn: '978-0857197689',
      downloadCount: 15000,
      isPremium: false,
      fileSize: '2.3 MB',
      format: 'EPUB',
      metadata: {
        'awards': ['Financial Times Book of the Year'],
        'readingTime': '4.5 hours',
      },
    ),
    Book(
      id: '2',
      title: 'Atomic Habits',
      author: 'James Clear',
      description: 'An Easy & Proven Way to Build Good Habits & Break Bad Ones. '
          'No matter your goals, Atomic Habits offers a proven framework for improving every day.',
      rating: 4.8,
      ratingCount: 3876,
      price: '\$9.99',
      coverUrl: 'assets/images/atomic_habits.jpg',
      categories: ['Self Help', 'Productivity', 'Psychology'],
      language: 'English',
      pages: 320,
      publishedDate: '2018-10-16',
      publisher: 'Penguin Random House',
      isbn: '978-0735211292',
      downloadCount: 25000,
      isPremium: true,
      fileSize: '3.1 MB',
      format: 'PDF',
      metadata: {
        'bestseller': true,
        'readingTime': '5.3 hours',
      },
    ),
  ];

  // Get a sample book by ID
  static Book getSampleById(String id) {
    return sampleBooks.firstWhere(
      (book) => book.id == id,
      orElse: () => sampleBooks.first,
    );
  }

  @override
  String toString() => 'Book(title: $title, author: $author)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Book && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
