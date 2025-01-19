const express = require('express');
const Book = require('../models/Book');
const authMiddleware = require('../middleware/authMiddleware');

const router = express.Router();

// Create a new book (Admin only)
router.post('/', authMiddleware.verifyToken, authMiddleware.isAdmin, async (req, res) => {
  try {
    const {
      title, 
      author, 
      isbn, 
      description, 
      price, 
      priceType,
      accessType,
      downloadLink,
      genre,
      // New detailed fields
      bookDetails,
      images,
      format,
      pageCount,
      stockInfo,
      tags
    } = req.body;

    // Validate required fields
    if (!title || !author || !isbn) {
      return res.status(400).json({ message: 'Missing required book fields' });
    }

    // Validate price based on price type
    if (priceType === 'Free' && price > 0) {
      return res.status(400).json({ message: 'Free books must have a price of 0' });
    }

    if (priceType === 'Paid' && (price === undefined || price <= 0)) {
      return res.status(400).json({ message: 'Paid books must have a price greater than 0' });
    }

    // Check if book with same ISBN already exists
    const existingBook = await Book.findOne({ isbn });
    if (existingBook) {
      return res.status(400).json({ message: 'Book with this ISBN already exists' });
    }

    // Create new book with comprehensive details
    const newBook = new Book({
      title, 
      author, 
      isbn, 
      description, 
      price: price || 0, 
      priceType: priceType || 'Paid',
      accessType: accessType || 'Purchase',
      downloadLink,
      genre,
      bookDetails: {
        publisher: bookDetails?.publisher,
        publicationDate: bookDetails?.publicationDate,
        edition: bookDetails?.edition,
        language: bookDetails?.language || 'English',
        dimensions: bookDetails?.dimensions,
        weight: bookDetails?.weight
      },
      images: {
        coverImage: images?.coverImage || 'default-book-cover.jpg',
        additionalImages: images?.additionalImages || []
      },
      format,
      pageCount,
      stockInfo: {
        inStock: stockInfo?.inStock || 0,
        lowStockThreshold: stockInfo?.lowStockThreshold || 10
      },
      tags: tags || []
    });

    await newBook.save();

    res.status(201).json({
      message: 'Book added successfully',
      book: newBook
    });
  } catch (error) {
    res.status(500).json({ 
      message: 'Error creating book', 
      error: error.message 
    });
  }
});

// Get all books with filtering and pagination
router.get('/', async (req, res) => {
  try {
    const { 
      page = 1, 
      limit = 10, 
      genre, 
      minPrice, 
      maxPrice, 
      search 
    } = req.query;

    // Build query
    const query = {};
    if (genre) query.genre = genre;
    if (minPrice || maxPrice) {
      query.price = {};
      if (minPrice) query.price.$gte = Number(minPrice);
      if (maxPrice) query.price.$lte = Number(maxPrice);
    }
    if (search) {
      query.$or = [
        { title: { $regex: search, $options: 'i' } },
        { author: { $regex: search, $options: 'i' } },
        { tags: { $regex: search, $options: 'i' } }
      ];
    }

    const books = await Book.find(query)
      .select('-reviews') // Exclude detailed reviews
      .limit(Number(limit))
      .skip((page - 1) * limit)
      .sort({ createdAt: -1 });

    const total = await Book.countDocuments(query);

    res.json({
      books,
      currentPage: Number(page),
      totalPages: Math.ceil(total / limit),
      totalBooks: total
    });
  } catch (error) {
    res.status(500).json({ 
      message: 'Error fetching books', 
      error: error.message 
    });
  }
});

// Get a single book by ID
router.get('/:id', async (req, res) => {
  try {
    const book = await Book.findById(req.params.id);
    
    if (!book) {
      return res.status(404).json({ message: 'Book not found' });
    }

    res.json(book);
  } catch (error) {
    res.status(500).json({ 
      message: 'Error fetching book', 
      error: error.message 
    });
  }
});

// Update a book (Admin only)
router.put('/:id', authMiddleware.verifyToken, authMiddleware.isAdmin, async (req, res) => {
  try {
    const { id } = req.params;
    const updateData = req.body;

    // Prevent updating certain fields
    delete updateData._id;
    delete updateData.createdAt;
    delete updateData.reviews;
    delete updateData.rating;

    const book = await Book.findByIdAndUpdate(
      id, 
      { ...updateData, updatedAt: Date.now() }, 
      { new: true, runValidators: true }
    );

    if (!book) {
      return res.status(404).json({ message: 'Book not found' });
    }

    res.json({
      message: 'Book updated successfully',
      book
    });
  } catch (error) {
    res.status(500).json({ 
      message: 'Error updating book', 
      error: error.message 
    });
  }
});

// Add a review to a book
router.post('/:id/review', authMiddleware.verifyToken, async (req, res) => {
  try {
    const { id } = req.params;
    const { rating, comment } = req.body;

    const book = await Book.findById(id);
    if (!book) {
      return res.status(404).json({ message: 'Book not found' });
    }

    // Check if user has already reviewed this book
    const existingReview = book.reviews.find(
      review => review.user.toString() === req.userId
    );

    if (existingReview) {
      return res.status(400).json({ message: 'You have already reviewed this book' });
    }

    book.reviews.push({
      user: req.userId,
      rating,
      comment
    });

    await book.save();

    res.status(201).json({
      message: 'Review added successfully',
      book
    });
  } catch (error) {
    res.status(500).json({ 
      message: 'Error adding review', 
      error: error.message 
    });
  }
});

// New route to get book content
router.get('/:id/content', authMiddleware.verifyToken, async (req, res) => {
  try {
    const book = await Book.findById(req.params.id);
    
    if (!book) {
      return res.status(404).json({ message: 'Book not found' });
    }

    // Determine user's access level based on their role
    const user = await User.findById(req.userId);
    const userRole = user.role || 'Free';

    // Find the appropriate access permission
    const accessPermission = book.accessPermissions.find(
      perm => perm.userRole === userRole
    ) || { accessLevel: 'Preview' };

    // Prepare content based on access level
    let content;
    switch (accessPermission.accessLevel) {
      case 'Full':
        content = book.bookContent;
        break;
      case 'Partial':
        content = {
          chapters: book.bookContent.chapters.slice(0, 3),
          fullText: book.bookContent.fullText.slice(0, 1000)
        };
        break;
      case 'Preview':
      default:
        content = {
          chapters: book.bookContent.chapters.slice(0, 1),
          fullText: book.bookContent.fullText.slice(0, 500)
        };
    }

    res.json({
      bookId: book._id,
      title: book.title,
      contentType: book.contentType,
      content,
      accessLevel: accessPermission.accessLevel
    });
  } catch (error) {
    res.status(500).json({ 
      message: 'Error fetching book content', 
      error: error.message 
    });
  }
});

// Route to update reading progress
router.post('/:id/progress', authMiddleware.verifyToken, async (req, res) => {
  try {
    const { id } = req.params;
    const { 
      currentChapter, 
      currentPage, 
      completionPercentage 
    } = req.body;

    const book = await Book.findById(id);
    
    if (!book) {
      return res.status(404).json({ message: 'Book not found' });
    }

    // Find or create user's reading progress
    let userProgress = book.readingProgress.find(
      progress => progress.user.toString() === req.userId
    );

    if (!userProgress) {
      userProgress = {
        user: req.userId,
        currentChapter: currentChapter || 1,
        currentPage: currentPage || 1,
        completionPercentage: completionPercentage || 0,
        lastReadTimestamp: new Date()
      };
      book.readingProgress.push(userProgress);
    } else {
      userProgress.currentChapter = currentChapter || userProgress.currentChapter;
      userProgress.currentPage = currentPage || userProgress.currentPage;
      userProgress.completionPercentage = completionPercentage || userProgress.completionPercentage;
      userProgress.lastReadTimestamp = new Date();
    }

    await book.save();

    res.json({
      message: 'Reading progress updated',
      progress: userProgress
    });
  } catch (error) {
    res.status(500).json({ 
      message: 'Error updating reading progress', 
      error: error.message 
    });
  }
});

module.exports = router;
