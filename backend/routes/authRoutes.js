const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const User = require('../models/User');
const authMiddleware = require('../middleware/authMiddleware');
const { body, validationResult } = require('express-validator');
const { sendWelcomeEmail, sendPasswordResetEmail, sendVerificationPinEmail, sendResetPinEmail } = require('../utils/emailService');
const crypto = require('crypto');

const router = express.Router();

// Generate 6-digit PIN
const generatePin = () => {
  return Math.floor(100000 + Math.random() * 900000).toString();
};

// Input Validation Middleware
const validateRegistration = [
  body('username').trim().isLength({ min: 3 }).withMessage('Username must be at least 3 characters'),
  body('email').trim().isEmail().withMessage('Invalid email address'),
  body('password').isLength({ min: 6 }).withMessage('Password must be at least 6 characters')
];

// Password Reset Validation
const validatePasswordReset = [
  body('email').trim().isEmail().withMessage('Invalid email address')
];

// User Registration
router.post('/register', validateRegistration, async (req, res) => {
  try {
    const { username, email, password, role } = req.body;
    console.log('\n=== Registration Attempt ===');
    console.log('Email:', email);

    // Check if user exists
    let existingUser = await User.findOne({ $or: [{ email }, { username }] });
    if (existingUser) {
      return res.status(409).json({ 
        error: 'USER_EXISTS', 
        message: 'User already exists' 
      });
    }

    // Create verification PIN
    const verificationPin = generatePin();
    const verificationPinExpiry = new Date(Date.now() + 15 * 60 * 1000);

    // Create user with hashed password
    const newUser = new User({
      username,
      email,
      password, // Will be hashed by pre-save middleware
      role: role || 'user',
      verificationPin,
      verificationPinExpiry,
      isVerified: false
    });

    await newUser.save();
    console.log('User created successfully');

    // Send verification email
    await sendVerificationPinEmail(email, username, verificationPin);
    console.log('Verification email sent');

    res.status(201).json({
      message: 'Registration successful. Please check your email for verification.',
      user: {
        id: newUser._id,
        username: newUser.username,
        email: newUser.email,
        isVerified: false
      }
    });
  } catch (error) {
    console.error('Registration error:', error);
    res.status(500).json({
      error: 'REGISTRATION_FAILED',
      message: 'Failed to register user'
    });
  }
});

// Verify Email with PIN
router.post('/verify-email', [
  body('email').trim().isEmail().withMessage('Invalid email address'),
  body('pin').trim().isLength({ min: 6, max: 6 }).withMessage('Invalid PIN code')
], async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ 
      error: 'Validation Failed', 
      details: errors.array() 
    });
  }

  try {
    const { email, pin } = req.body;

    // Find user with valid verification PIN
    const user = await User.findOne({
      email,
      verificationPin: pin,
      verificationPinExpiry: { $gt: Date.now() },
      isVerified: false
    });

    if (!user) {
      return res.status(400).json({
        error: 'INVALID_PIN',
        message: 'Invalid or expired verification code'
      });
    }

    // Update user verification status
    user.isVerified = true;
    user.verificationPin = undefined;
    user.verificationPinExpiry = undefined;
    await user.save();

    // Send welcome email
    await sendWelcomeEmail(user.email, user.username);

    // Generate JWT token
    const authToken = jwt.sign(
      { userId: user._id, role: user.role },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRATION }
    );

    res.json({
      message: 'Email verified successfully',
      token: authToken,
      user: {
        id: user._id,
        username: user.username,
        email: user.email,
        isVerified: true
      }
    });
  } catch (error) {
    console.error('Email verification error:', error);
    res.status(500).json({
      error: 'VERIFICATION_FAILED',
      message: 'Failed to verify email'
    });
  }
});

// Resend Verification PIN
router.post('/resend-verification', [
  body('email').trim().isEmail().withMessage('Invalid email address')
], async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ 
      error: 'Validation Failed', 
      details: errors.array() 
    });
  }

  try {
    const { email } = req.body;

    const user = await User.findOne({ email, isVerified: false });
    if (!user) {
      return res.status(400).json({
        error: 'INVALID_REQUEST',
        message: 'Invalid email or account already verified'
      });
    }

    // Generate new verification PIN
    const verificationPin = generatePin();
    const verificationPinExpiry = new Date(Date.now() + 15 * 60 * 1000); // 15 minutes

    // Update user with new PIN
    user.verificationPin = verificationPin;
    user.verificationPinExpiry = verificationPinExpiry;
    await user.save();

    // Send new verification PIN email
    await sendVerificationPinEmail(user.email, user.username, verificationPin);

    res.json({
      message: 'New verification code sent successfully'
    });
  } catch (error) {
    console.error('Resend verification error:', error);
    res.status(500).json({
      error: 'PIN_RESEND_FAILED',
      message: 'Failed to resend verification code'
    });
  }
});

// User Login
router.post('/login', [
  body('email').trim().isEmail().withMessage('Invalid email address'),
  body('password').notEmpty().withMessage('Password is required')
], async (req, res) => {
  try {
    const { email, password } = req.body;
    console.log('\n=== Login Attempt ===');
    console.log('Email:', email);
    console.log('Password length:', password.length);

    // Find user
    const user = await User.findOne({ email });
    if (!user) {
      console.log('No user found with email:', email);
      return res.status(401).json({
        error: 'INVALID_CREDENTIALS',
        message: 'Invalid email or password'
      });
    }

    console.log('Found user:', {
      id: user._id,
      email: user.email,
      isVerified: user.isVerified,
      passwordLength: user.password.length
    });

    // Check if email is verified
    if (!user.isVerified) {
      console.log('User not verified:', email);
      return res.status(401).json({
        error: 'EMAIL_NOT_VERIFIED',
        message: 'Please verify your email before logging in'
      });
    }

    // Check password
    const isMatch = await user.comparePassword(password);
    if (!isMatch) {
      console.log('Password mismatch for:', email);
      return res.status(401).json({
        error: 'INVALID_CREDENTIALS',
        message: 'Invalid email or password'
      });
    }

    // Generate token
    const token = user.generateAuthToken();
    console.log('Login successful for:', email);

    res.json({
      message: 'Login successful',
      token,
      user: {
        id: user._id,
        username: user.username,
        email: user.email,
        role: user.role,
        isVerified: user.isVerified
      }
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({
      error: 'LOGIN_FAILED',
      message: 'An error occurred during login'
    });
  }
});

// Get User Profile (Protected Route)
router.get('/profile', authMiddleware.verifyToken, async (req, res) => {
  try {
    const user = await User.findById(req.user.id).select('-password');
    if (!user) {
      return res.status(404).json({ 
        error: 'USER_NOT_FOUND',
        message: 'User not found' 
      });
    }
    
    res.json({
      success: true,
      user: {
        id: user._id,
        username: user.username,
        email: user.email,
        profile: user.profile,
        preferences: user.preferences
      }
    });
  } catch (error) {
    console.error('Profile fetch error:', error);
    res.status(500).json({ 
      error: 'SERVER_ERROR',
      message: 'Failed to fetch user profile' 
    });
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

    const user = await User.findById(req.user.id);
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
      success: true,
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

    const user = await User.findById(req.user.id);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    user.profile.avatar = avatarUrl;
    await user.save();

    res.json({ 
      success: true,
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

    res.json({
      success: true,
      user: {
        username: user.username,
        firstName: user.profile.firstName,
        lastName: user.profile.lastName,
        bio: user.profile.bio,
        avatar: user.profile.avatar
      }
    });
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// Request Password Reset (Step 1)
router.post('/forgot-password', [
  body('email').trim().isEmail().withMessage('Invalid email address')
], async (req, res) => {
  try {
    const { email } = req.body;
    console.log('\n=== Password Reset Request ===');
    console.log('Email:', email);

    const user = await User.findOne({ email });
    if (!user) {
      return res.status(404).json({
        error: 'USER_NOT_FOUND',
        message: 'No user found with this email address'
      });
    }

    // Generate reset PIN
    const resetPin = generatePin();
    const resetPinExpiry = new Date(Date.now() + 15 * 60 * 1000); // 15 minutes

    // Save reset PIN
    user.resetPin = resetPin;
    user.resetPinExpiry = resetPinExpiry;
    await user.save();
    console.log('Reset PIN generated');

    // Send reset PIN email
    await sendResetPinEmail(email, user.username, resetPin);
    console.log('Reset PIN email sent');

    res.json({
      message: 'Password reset instructions have been sent to your email'
    });
  } catch (error) {
    console.error('Password reset request error:', error);
    res.status(500).json({
      error: 'RESET_REQUEST_FAILED',
      message: 'Failed to process password reset request'
    });
  }
});

// Reset Password with PIN (Step 2)
router.post('/reset-password', [
  body('email').trim().isEmail().withMessage('Invalid email address'),
  body('pin').trim().isLength({ min: 6, max: 6 }).withMessage('Invalid PIN'),
  body('newPassword').isLength({ min: 6 }).withMessage('Password must be at least 6 characters')
], async (req, res) => {
  try {
    const { email, pin, newPassword } = req.body;
    console.log('\n=== Password Reset ===');
    console.log('Email:', email);

    // Find user with valid reset PIN
    const user = await User.findOne({
      email,
      resetPin: pin,
      resetPinExpiry: { $gt: Date.now() }
    });

    if (!user) {
      console.log('Invalid or expired PIN');
      return res.status(400).json({
        error: 'INVALID_PIN',
        message: 'Invalid or expired reset PIN'
      });
    }

    // Hash the new password
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(newPassword, salt);
    console.log('New password hashed');

    // Update password and clear reset PIN
    user.password = hashedPassword;
    user.resetPin = undefined;
    user.resetPinExpiry = undefined;
    await user.save();
    console.log('Password updated successfully');

    res.json({
      message: 'Password has been reset successfully. Please login with your new password.'
    });
  } catch (error) {
    console.error('Password reset error:', error);
    res.status(500).json({
      error: 'RESET_FAILED',
      message: 'Failed to reset password'
    });
  }
});

// Direct password reset (FOR TESTING ONLY)
router.post('/reset-password-direct', [
  body('email').trim().isEmail().withMessage('Invalid email address'),
  body('newPassword').isLength({ min: 6 }).withMessage('Password must be at least 6 characters')
], async (req, res) => {
  try {
    const { email, newPassword } = req.body;
    console.log('\n=== Direct Password Reset ===');
    console.log('Email:', email);

    const user = await User.findOne({ email });
    if (!user) {
      return res.status(404).json({
        error: 'USER_NOT_FOUND',
        message: 'No user found with this email address'
      });
    }

    // Update password
    user.password = newPassword;
    await user.save();
    console.log('Password updated successfully');

    res.json({
      message: 'Password has been reset successfully. Please login with your new password.'
    });
  } catch (error) {
    console.error('Password reset error:', error);
    res.status(500).json({
      error: 'RESET_FAILED',
      message: 'Failed to reset password'
    });
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
      success: true,
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
