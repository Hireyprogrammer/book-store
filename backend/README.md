# Book Store Backend 

## Overview
A robust, feature-rich backend for a Book Store application built with Node.js, Express.js, and MongoDB.

## Key Features

### Authentication System
- User registration and login
- Role-based access control (User and Admin)
- JWT-based authentication
- Secure password hashing
- Profile management

### Book Management
- Comprehensive book catalog
- Advanced search and filtering
- Book reviews and ratings
- Admin book management

## Technologies Used
- Node.js
- Express.js
- MongoDB
- Mongoose
- JSON Web Token (JWT)
- Bcrypt.js
- Cors
- Dotenv

## Project Structure
```
backend/
│
├── models/
│   ├── User.js        # User data model
│   └── Book.js        # Book data model
│
├── routes/
│   ├── authRoutes.js  # Authentication endpoints
│   └── bookRoutes.js  # Book-related endpoints
│
├── middleware/
│   ├── authMiddleware.js     # Authentication middleware
│   └── profileValidation.js  # Profile validation middleware
│
├── .env               # Environment variables
├── server.js          # Main server configuration
└── package.json       # Project dependencies
```

## Getting Started

### Prerequisites
- Node.js (v16+ recommended)
- MongoDB
- npm or yarn

### Setup Instructions

1. Clone the repository
```bash
git clone https://github.com/yourusername/book-store-backend.git
cd book-store-backend
```

2. Install Dependencies
```bash
npm install
```

3. Configure Environment
- Copy `.env.example` to `.env`
- Update the following variables:
  - `PORT`: Backend server port (default: 3000)
  - `MONGODB_URI`: Your MongoDB connection string
  - `JWT_SECRET`: A long, random string for JWT signing
  - `CORS_ORIGIN`: Allowed frontend origins

4. Run the Application
```bash
# Development mode
npm run dev

# Production mode
npm start
```

## API Endpoints

### Authentication
- `POST /api/auth/register`: Register a new user
- `POST /api/auth/login`: User login
- `POST /api/auth/logout`: User logout

### Books
- `GET /api/books`: Fetch all books
- `POST /api/books`: Create a new book (admin only)
- `GET /api/books/:id`: Get a specific book

## Environment Variables
- `PORT`: Server port
- `MONGODB_URI`: MongoDB connection string
- `JWT_SECRET`: JWT token secret
- `SALT_ROUNDS`: Password hashing complexity
- `CORS_ORIGIN`: Allowed frontend origins

## Deployment
- Ensure all environment variables are set
- Use a process manager like PM2 for production
- Set up proper MongoDB hosting

## Troubleshooting
- Check MongoDB connection
- Verify environment variables
- Ensure all dependencies are installed

## Security
- Use strong, unique JWT secret
- Implement proper input validation
- Keep dependencies updated

## Authentication Endpoints

### User Registration
- `POST /api/auth/register`
```json
{
  "username": "johndoe",
  "email": "john@example.com",
  "password": "securepassword",
  "role": "user"
}
```

### User Login
- `POST /api/auth/login`
```json
{
  "username": "johndoe",
  "password": "securepassword"
}
```

### Profile Management
- `PUT /api/auth/profile`: Update user profile
- `POST /api/auth/avatar`: Upload avatar
- `GET /api/auth/profile`: Get user profile

## Book Endpoints

### Add Book (Admin Only)
- `POST /api/books`
```json
{
  "title": "Sample Book",
  "author": "John Writer",
  "isbn": "1234567890",
  "price": 19.99,
  "genre": "Fiction"
}
```

### Get Books
- `GET /api/books`
  - Supports pagination
  - Filtering by genre, price
  - Search by title, author

### Book Review
- `POST /api/books/:id/review`
```json
{
  "rating": 4,
  "comment": "Great book!"
}
```

## Security Features
- Password hashing
- JWT authentication
- Role-based access control
- Input validation
- Secure MongoDB connections

## Testing
- Run tests: `npm test`

## Contributing
1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License
MIT License

## Disclaimer
This is a sample implementation. Ensure proper security measures in production.

## Support
For issues or questions, please open a GitHub issue.

## Future Roadmap
- [ ] Add more advanced search capabilities
- [ ] Implement caching
- [ ] Add more comprehensive testing
- [ ] Create admin dashboard
