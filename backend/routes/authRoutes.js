const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const User = require('../models/User');
const authMiddleware = require('../middleware/authMiddleware');
const { body, validationResult } = require('express-validator');

const router = express.Router();

// Input Validation Middleware
const validateRegistration = [
  body('username').trim().isLength({ min: 3 }).withMessage('Username must be at least 3 characters'),
  body('email').trim().isEmail().withMessage('Invalid email address'),
  body('password').isLength({ min: 6 }).withMessage('Password must be at least 6 characters')
];

// User Registration with Enhanced Validation
router.post('/register', validateRegistration, async (req, res) => {
  // Validate input
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ 
      error: 'Validation Failed', 
      details: errors.array() 
    });
  }

  try {
    const { username, email, password, role } = req.body;

    // Check if user already exists
    let existingUser = await User.findOne({ $or: [{ email }, { username }] });
    if (existingUser) {
      return res.status(409).json({ 
        error: 'USER_ALREADY_EXISTS', 
        message: 'A user with this email or username already exists' 
      });
    }

    // Hash password
    const salt = await bcrypt.genSalt(Number(process.env.SALT_ROUNDS));
    const hashedPassword = await bcrypt.hash(password, salt);

    // Create new user
    const newUser = new User({
      username,
      email,
      password: hashedPassword,
      role: role || 'user'
    });

    await newUser.save();

    // Generate JWT
    const token = jwt.sign(
      { userId: newUser._id, username: newUser.username, role: newUser.role },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRATION }
    );

    res.status(201).json({
      message: 'User registered successfully',
      user: {
        id: newUser._id,
        username: newUser.username,
        email: newUser.email,
        role: newUser.role
      },
      token
    });

  } catch (error) {
    console.error('Registration error:', error);
    res.status(500).json({ 
      error: 'REGISTRATION_ERROR', 
      message: 'An unexpected error occurred during registration' 
    });
  }
});

// User Login with Enhanced Security
router.post('/login', [
  body('email').trim().isEmail().withMessage('Invalid email address'),
  body('password').notEmpty().withMessage('Password is required')
], async (req, res) => {
  // Validate input
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ 
      error: 'Validation Failed', 
      details: errors.array() 
    });
  }

  try {
    const { email, password } = req.body;

    // Find user
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(401).json({ 
        error: 'INVALID_CREDENTIALS', 
        message: 'Invalid email or password' 
      });
    }

    // Check password
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(401).json({ 
        error: 'INVALID_CREDENTIALS', 
        message: 'Invalid email or password' 
      });
    }

    // Generate JWT
    const token = jwt.sign(
      { userId: user._id, username: user.username, role: user.role },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRATION }
    );

    res.status(200).json({
      message: 'Login successful',
      user: {
        id: user._id,
        username: user.username,
        email: user.email,
        role: user.role
      },
      token
    });

  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ 
      error: 'LOGIN_ERROR', 
      message: 'An unexpected error occurred during login' 
    });
  }
});

// Get User Profile (Protected Route)
router.get('/profile', authMiddleware.verifyToken, async (req, res) => {
  try {
    const user = await User.findById(req.userId).select('-password');
    res.json(user);
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
});

// Profile Management Routes
// Update User Profile
router.put('/profile', authMiddleware.verifyToken, async (req, res) => {
  try {
    const { 
      firstName, 
      lastName, 
      bio, 
      phoneNumber, 
      address,
      preferences 
    } = req.body;

    const user = await User.findById(req.userId);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Update profile fields
    user.profile.firstName = firstName || user.profile.firstName;
    user.profile.lastName = lastName || user.profile.lastName;
    user.profile.bio = bio || user.profile.bio;
    user.profile.phoneNumber = phoneNumber || user.profile.phoneNumber;

    // Update address if provided
    if (address) {
      user.profile.address = {
        street: address.street || user.profile.address.street,
        city: address.city || user.profile.address.city,
        state: address.state || user.profile.address.state,
        country: address.country || user.profile.address.country,
        zipCode: address.zipCode || user.profile.address.zipCode
      };
    }

    // Update preferences
    if (preferences) {
      user.preferences.newsletter = preferences.newsletter ?? user.preferences.newsletter;
      user.preferences.darkMode = preferences.darkMode ?? user.preferences.darkMode;
    }

    await user.save();

    res.json({ 
      message: 'Profile updated successfully', 
      user: {
        id: user._id,
        username: user.username,
        email: user.email,
        profile: user.profile,
        preferences: user.preferences
      } 
    });
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// Upload Avatar
router.post('/avatar', authMiddleware.verifyToken, async (req, res) => {
  try {
    const { avatarUrl } = req.body;

    if (!avatarUrl) {
      return res.status(400).json({ message: 'Avatar URL is required' });
    }

    const user = await User.findById(req.userId);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    user.profile.avatar = avatarUrl;
    await user.save();

    res.json({ 
      message: 'Avatar updated successfully', 
      avatarUrl: user.profile.avatar 
    });
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// Get Public Profile (for other users to view)
router.get('/profile/:username', async (req, res) => {
  try {
    const user = await User.findOne({ username: req.params.username })
      .select('username profile.firstName profile.lastName profile.bio profile.avatar');
    
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    res.json(user);
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// Admin Initialization Route
router.post('/init-admin', async (req, res) => {
  try {
    // Check if admin already exists
    const existingAdmin = await User.findOne({ role: 'admin' });
    if (existingAdmin) {
      return res.status(400).json({ 
        error: 'ADMIN_ALREADY_EXISTS', 
        message: 'An admin user has already been created' 
      });
    }

    // Create admin using environment variables
    const salt = await bcrypt.genSalt(Number(process.env.SALT_ROUNDS));
    const hashedPassword = await bcrypt.hash(process.env.ADMIN_PASSWORD, salt);

    const adminUser = new User({
      username: 'bookstore_admin',
      email: process.env.ADMIN_EMAIL,
      password: hashedPassword,
      role: 'admin'
    });

    await adminUser.save();

    res.status(201).json({ 
      message: 'Admin user created successfully', 
      email: process.env.ADMIN_EMAIL 
    });
  } catch (error) {
    console.error('Admin initialization error:', error);
    res.status(500).json({ 
      error: 'ADMIN_INIT_FAILED', 
      message: 'Failed to create admin user' 
    });
  }
});

module.exports = router;
