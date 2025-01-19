const mongoose = require('mongoose');

const UserSchema = new mongoose.Schema({
  username: {
    type: String,
    required: true,
    unique: true,
    trim: true,
    minlength: 3
  },
  email: {
    type: String,
    required: true,
    unique: true,
    trim: true,
    lowercase: true
  },
  password: {
    type: String,
    required: true,
    minlength: 6
  },
  role: {
    type: String,
    enum: ['user', 'admin'],
    default: 'user'
  },
  profile: {
    firstName: {
      type: String,
      trim: true
    },
    lastName: {
      type: String,
      trim: true
    },
    bio: {
      type: String,
      maxlength: 500
    },
    avatar: {
      type: String,
      default: 'default-avatar.png'
    },
    phoneNumber: {
      type: String,
      validate: {
        validator: function(v) {
          return /^(\+\d{1,3}[- ]?)?\d{10}$/.test(v);
        },
        message: props => `${props.value} is not a valid phone number!`
      }
    },
    address: {
      street: String,
      city: String,
      state: String,
      country: String,
      zipCode: String
    }
  },
  preferences: {
    newsletter: {
      type: Boolean,
      default: false
    },
    darkMode: {
      type: Boolean,
      default: false
    }
  },
  bookmarks: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Book'
  }],
  createdAt: {
    type: Date,
    default: Date.now
  },
  lastLogin: {
    type: Date
  }
});

module.exports = mongoose.model('User', UserSchema);
