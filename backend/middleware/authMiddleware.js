const jwt = require('jsonwebtoken');
const User = require('../models/User');

const authMiddleware = {
  // Verify JWT Token
  verifyToken: (req, res, next) => {
    const token = req.headers['authorization']?.split(' ')[1];
    
    if (!token) {
      return res.status(403).json({ message: 'No token provided' });
    }

    try {
      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      req.userId = decoded.id;
      req.userRole = decoded.role;
      next();
    } catch (error) {
      return res.status(401).json({ message: 'Unauthorized' });
    }
  },

  // Check if user is admin
  isAdmin: async (req, res, next) => {
    try {
      const user = await User.findById(req.userId);
      if (user.role !== 'admin') {
        return res.status(403).json({ message: 'Admin access required' });
      }
      next();
    } catch (error) {
      res.status(500).json({ message: 'Server error' });
    }
  }
};

module.exports = authMiddleware;
