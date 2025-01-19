# 📚 Book Store Backend - Postman Endpoint Testing Guide

## 🔐 Authentication Endpoints

### 1. User Registration
- **Endpoint**: `POST /api/auth/register`
- **Purpose**: Create a new user account
- **Full URL**: `http://localhost:5000/api/auth/register`

#### Validation Requirements
- **Username**:
  - Minimum length: 3 characters
  - Cannot be empty
  - Must be unique
- **Email**:
  - Must be a valid email format
  - Cannot be empty
  - Must be unique
- **Password**:
  - Minimum length: 6 characters
  - No strict complexity requirements in current implementation

#### JSON Request Body
```json
{
    "username": "Abdifitah",
    "email": "abdifitah@gmail.com", 
    "password": "mohamed11",
    "role": "user"
}
```

#### Possible Validation Scenarios
1. **Successful Registration**
   - Status Code: 201 Created
   - Response includes:
     - User details
     - JWT authentication token
     - Success message

2. **Validation Failures**
   - Status Code: 400 Bad Request
   - Possible error scenarios:
     - Username too short
     - Invalid email format
     - Password too weak
     - Missing required fields

3. **Duplicate User Failures**
   - Status Code: 409 Conflict
   - Occurs when:
     - Email already exists
     - Username already taken

#### Headers
- `Content-Type`: `application/json`

#### Common Error Responses
```json
{
    "error": "VALIDATION_ERROR",
    "details": [
        {
            "msg": "Username must be at least 3 characters",
            "param": "username"
        }
    ]
}
```

#### Troubleshooting Tips
- Ensure server is running
- Check network connectivity
- Verify endpoint URL (`/api/auth/register`)
- Validate JSON payload
- Check console logs on server side

### 2. User Login
- **Endpoint**: `POST /auth/login`
- **Purpose**: Authenticate user and get JWT token

#### JSON Request Body
```json
{
    "email": "hireyprogrammer@gmail.com",
    "password": "maxamuud11"
}
```

#### Expected Responses
- **Success**: 
  - Status Code: 200 OK
  - Contains: User details, JWT token
- **Failure**: 
  - Status Code: 401 
  - Reasons: Invalid credentials

## 📖 Book Endpoints

### 3. Create Book (Admin Only)
- **Endpoint**: `POST /books`
- **Purpose**: Add a new book to the store
- **Authorization**: Requires Admin JWT Token

#### JSON Request Body
```json
{
    "title": "The Digital Renaissance",
    "author": "Alex Technovation",
    "isbn": "978-1234567890",
    "description": "A comprehensive exploration of digital transformation",
    "price": 29.99,
    "priceType": "Paid",
    "genre": "Non-Fiction, Technology",
    "bookDetails": {
        "publisher": "Tech Insights Press",
        "publicationDate": "2024-01-15",
        "language": "English"
    },
    "images": {
        "coverImage": "https://example.com/book-cover.jpg"
    },
    "format": "Hardcover",
    "pageCount": 350,
    "stockInfo": {
        "inStock": 500,
        "lowStockThreshold": 50
    },
    "tags": ["technology", "digital transformation"]
}
```

#### Expected Responses
- **Success**: 
  - Status Code: 201 Created
  - Contains: Created book details
- **Failure**: 
  - Status Code: 400/401/403
  - Reasons: Missing fields, unauthorized, duplicate ISBN

### 4. Get All Books
- **Endpoint**: `GET /books`
- **Purpose**: Retrieve list of books with filtering
- **Query Parameters**:
  - `page`: Page number (default: 1)
  - `limit`: Books per page (default: 10)
  - `genre`: Filter by book genre
  - `minPrice`: Minimum book price
  - `maxPrice`: Maximum book price
  - `search`: Search by title, author, or tags

#### Example Request URL
```
/books?page=1&limit=10&genre=Technology&minPrice=10&maxPrice=50&search=digital
```

#### Expected Responses
- **Success**: 
  - Status Code: 200 OK
  - Contains: Books array, pagination info
- **Failure**: 
  - Status Code: 500
  - Reasons: Server error

### 5. Get Book by ID
- **Endpoint**: `GET /books/:id`
- **Purpose**: Retrieve specific book details

#### Expected Responses
- **Success**: 
  - Status Code: 200 OK
  - Contains: Complete book details
- **Failure**: 
  - Status Code: 404
  - Reasons: Book not found

### 6. Update Book (Admin Only)
- **Endpoint**: `PUT /books/:id`
- **Purpose**: Update book details
- **Authorization**: Requires Admin JWT Token

#### JSON Request Body (Partial Update)
```json
{
    "price": 34.99,
    "stockInfo": {
        "inStock": 450
    },
    "description": "Updated book description"
}
```

#### Expected Responses
- **Success**: 
  - Status Code: 200 OK
  - Contains: Updated book details
- **Failure**: 
  - Status Code: 400/401/404
  - Reasons: Invalid data, unauthorized, book not found

## 🖥️ Localhost Configuration

### Local Server Setup
- **Default Port**: 5000
- **Base URL**: `http://localhost:5000`
- **Environment**: Development

### Starting Local Server
```bash
# Using npm
npm start

# Using nodemon (for development with auto-reload)
npm run dev
```

### Localhost Endpoint URLs
- **Full Base URL**: `http://localhost:5000/api/v1`
- **Authentication Base**: `http://localhost:5000/auth`
- **Books Base**: `http://localhost:5000/books`

### Network Configuration
- **Hostname**: `localhost`
- **IP Address**: `127.0.0.1`
- **Port**: `5000`

### Postman Localhost Configuration
1. Create a new Postman Environment
2. Add these variables:
   - `base_url`: `http://localhost:5000`
   - `local_host`: `localhost`
   - `local_port`: `5000`

### Troubleshooting Localhost
- Ensure no other service is using port 5000
- Check network connectivity
- Verify endpoint URL
- Check console logs on server side

## 🛠 Postman Setup Tips

1. Create Environment Variables:
   - `base_url`: Your server URL (e.g., `http://localhost:5000`)
   - `admin_token`: Your admin JWT token
   - `book_id`: ID of a created book

2. Authentication Flow:
   - Register/Login to get JWT token
   - Use token in Authorization header for protected routes

3. Common Headers:
   - `Content-Type`: `application/json`
   - `Authorization`: `Bearer YOUR_JWT_TOKEN`

## 🚨 Error Handling

- Always check status codes
- Review error messages in response body
- Ensure correct authentication for admin routes

## 📝 Testing Checklist

- [ ] Register new user
- [ ] Login and get token
- [ ] Create book as admin
- [ ] Retrieve all books
- [ ] Get specific book by ID
- [ ] Update book details
- [ ] Test error scenarios

Happy Testing! 🎉🚀
