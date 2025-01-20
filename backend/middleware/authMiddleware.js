const jwt = require('jsonwebtoken');
const User = require('../models/User');

const authMiddleware = {
  verifyToken: async (req, res, next) => {
    try {
      let token;

      // Check for token in headers
      if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
        token = req.headers.authorization.split(' ')[1];
      }

      if (!token) {
        return res.status(401).json({
          error: 'NO_TOKEN',
          message: 'No token provided. Authorization denied.'
        });
      }

      try {
        // Verify token
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        
        // Get user from token
        const user = await User.findById(decoded.userId).select('-password');
        if (!user) {
          return res.status(401).json({
            error: 'USER_NOT_FOUND',
            message: 'User not found'
          });
        }

        // Set user info in request
        req.user = {
          id: user._id,
          username: user.username,
          email: user.email,
          role: user.role
        };
        
        next();
      } catch (error) {
        console.error('Token verification error:', error);
        return res.status(401).json({
          error: 'INVALID_TOKEN',
          message: 'Token is not valid or has expired'
        });
      }
    } catch (error) {
      console.error('Auth middleware error:', error);
      return res.status(500).json({
        error: 'SERVER_ERROR',
        message: 'Server error in authentication'
      });
    }
  },

  // Check if user is admin
  isAdmin: async (req, res, next) => {
    try {
      if (!req.user || req.user.role !== 'admin') {
        return res.status(403).json({
          error: 'ACCESS_DENIED',
          message: 'Admin access required'
        });
      }
      next();
    } catch (error) {
      console.error('Admin check error:', error);
      return res.status(500).json({
        error: 'SERVER_ERROR',
        message: 'Server error checking admin status'
      });
    }
  }
};

module.exports = authMiddleware;
