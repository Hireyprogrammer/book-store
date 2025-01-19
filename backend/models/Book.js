const mongoose = require('mongoose');

const BookSchema = new mongoose.Schema({
  title: {
    type: String,
    required: true,
    trim: true,
    minlength: 2,
    maxlength: 200
  },
  author: {
    type: String,
    required: true,
    trim: true,
    minlength: 2,
    maxlength: 100
  },
  isbn: {
    type: String,
    unique: true,
    required: true,
    validate: {
      validator: function(v) {
        return /^(?:ISBN(?:-1[03])?:? )?(?=[0-9X]{10}$|(?=(?:[0-9]+[- ]){3})[- 0-9X]{13}$)[0-9]{1,5}[- ]?[0-9]+[- ]?[0-9]+[- ]?[0-9X]$/.test(v);
      },
      message: props => `${props.value} is not a valid ISBN!`
    }
  },
  description: {
    type: String,
    trim: true,
    maxlength: 2000
  },
  price: {
    type: Number,
    required: true,
    min: 0,
    max: 1000,
    set: v => Number(v.toFixed(2))
  },
  priceType: {
    type: String,
    enum: ['Free', 'Paid'],
    default: 'Paid'
  },
  accessType: {
    type: String,
    enum: ['Open Access', 'Subscription', 'Purchase'],
    default: 'Purchase'
  },
  contentType: {
    type: String,
    enum: ['Text', 'PDF', 'EPUB', 'HTML'],
    default: 'Text'
  },
  bookContent: {
    type: {
      chapters: [{
        title: {
          type: String,
          required: true,
          trim: true,
          maxlength: 200
        },
        content: {
          type: String,
          trim: true
        },
        pageRange: {
          start: {
            type: Number,
            min: 1
          },
          end: {
            type: Number,
            min: 1
          }
        }
      }],
      fullText: {
        type: String,
        trim: true
      },
      contentUrl: {
        type: String,
        trim: true,
        validate: {
          validator: function(v) {
            // Optional URL validation for book content
            return !v || /^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$/.test(v);
          },
          message: props => `${props.value} is not a valid URL!`
        }
      }
    },
    default: {}
  },
  readingProgress: {
    type: [{
      user: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User'
      },
      currentChapter: {
        type: Number,
        default: 1
      },
      currentPage: {
        type: Number,
        default: 1
      },
      completionPercentage: {
        type: Number,
        default: 0,
        min: 0,
        max: 100
      },
      lastReadTimestamp: {
        type: Date
      }
    }],
    default: []
  },
  accessPermissions: {
    type: [{
      userRole: {
        type: String,
        enum: ['Free', 'Basic', 'Premium', 'Admin']
      },
      accessLevel: {
        type: String,
        enum: ['Preview', 'Partial', 'Full']
      }
    }],
    default: [{ userRole: 'Free', accessLevel: 'Preview' }]
  },
  bookDetails: {
    publisher: {
      type: String,
      trim: true,
      maxlength: 100
    },
    publicationDate: {
      type: Date
    },
    edition: {
      type: String,
      trim: true,
      maxlength: 50
    },
    language: {
      type: String,
      default: 'English',
      trim: true
    },
    dimensions: {
      length: {
        type: Number,
        min: 0
      },
      width: {
        type: Number,
        min: 0
      },
      height: {
        type: Number,
        min: 0
      },
      unit: {
        type: String,
        enum: ['cm', 'inches'],
        default: 'cm'
      }
    },
    weight: {
      value: {
        type: Number,
        min: 0
      },
      unit: {
        type: String,
        enum: ['g', 'kg', 'lbs'],
        default: 'g'
      }
    }
  },
  images: {
    coverImage: {
      type: String,
      default: 'default-book-cover.jpg'
    },
    additionalImages: [{
      type: String
    }]
  },
  genre: {
    type: String,
    enum: [
      'Fiction', 'Non-Fiction', 'Science Fiction', 'Fantasy', 
      'Mystery', 'Thriller', 'Romance', 'Historical Fiction', 
      'Biography', 'Self-Help', 'Science', 'Technology', 
      'Philosophy', 'Poetry', 'Children\'s', 'Young Adult'
    ]
  },
  format: {
    type: String,
    enum: ['Hardcover', 'Paperback', 'Ebook', 'Audiobook']
  },
  pageCount: {
    type: Number,
    min: 1,
    max: 10000
  },
  stockInfo: {
    inStock: {
      type: Number,
      default: 0,
      min: 0
    },
    lowStockThreshold: {
      type: Number,
      default: 10
    }
  },
  rating: {
    average: {
      type: Number,
      default: 0,
      min: 0,
      max: 5
    },
    count: {
      type: Number,
      default: 0,
      min: 0
    }
  },
  tags: [{
    type: String,
    trim: true,
    maxlength: 20
  }],
  reviews: [{
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    },
    rating: {
      type: Number,
      required: true,
      min: 1,
      max: 5
    },
    comment: {
      type: String,
      trim: true,
      maxlength: 1000
    },
    createdAt: {
      type: Date,
      default: Date.now
    }
  }],
  createdAt: {
    type: Date,
    default: Date.now
  },
  updatedAt: {
    type: Date,
    default: Date.now
  }
}, {
  timestamps: true
});

// Middleware to update rating when a review is added
BookSchema.methods.updateRating = function() {
  if (this.reviews.length > 0) {
    const totalRating = this.reviews.reduce((sum, review) => sum + review.rating, 0);
    this.rating.average = Number((totalRating / this.reviews.length).toFixed(2));
    this.rating.count = this.reviews.length;
  }
};

// Pre-save hook to update rating
BookSchema.pre('save', function(next) {
  if (this.isModified('reviews')) {
    this.updateRating();
  }
  next();
});

module.exports = mongoose.model('Book', BookSchema);
