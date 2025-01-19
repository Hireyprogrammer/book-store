# Book Store REST API Guide

## Base URL
When deployed, replace `localhost:5000` with your actual deployed domain.
Base URL: `https://your-deployed-domain.com/api`

## Authentication Endpoints
### User Registration
- **URL**: `/auth/register`
- **Method**: `POST`
- **Request Body**:
```json
{
  "username": "johndoe",
  "email": "john@example.com",
  "password": "securepassword123",
  "role": "user"
}
```
- **Success Response**: 
  - **Code**: 201 Created
  - **Content**: User details without password

### User Login
- **URL**: `/auth/login`
- **Method**: `POST`
- **Request Body**:
```json
{
  "email": "john@example.com",
  "password": "securepassword123"
}
```
- **Success Response**:
  - **Code**: 200 OK
  - **Content**: 
    ```json
    {
      "token": "jwt_token_here",
      "user": {
        "id": "user_id",
        "username": "johndoe",
        "email": "john@example.com"
      }
    }
    ```

## Book Endpoints
### Get All Books
- **URL**: `/books`
- **Method**: `GET`
- **Query Parameters**:
  - `page`: Page number (default: 1)
  - `limit`: Number of books per page (default: 10)
  - `genre`: Filter by book genre
- **Success Response**:
  - **Code**: 200 OK
  - **Content**: 
    ```json
    {
      "books": [...],
      "total": 100,
      "page": 1,
      "totalPages": 10
    }
    ```

### Create a Book
- **URL**: `/books`
- **Method**: `POST`
- **Authorization**: Required (Admin role)
- **Request Body**:
```json
{
  "title": "Sample Book",
  "author": "John Author",
  "genre": "Fiction",
  "price": 19.99,
  "description": "A great book"
}
```

### Get Book by ID
- **URL**: `/books/:id`
- **Method**: `GET`
- **Success Response**:
  - **Code**: 200 OK
  - **Content**: Book details

## User Profile Endpoints
### Get User Profile
- **URL**: `/auth/profile/:username`
- **Method**: `GET`
- **Success Response**:
  - **Code**: 200 OK
  - **Content**: User profile details

## Error Handling
Standard Error Response Format:
```json
{
  "error": "Error message",
  "code": "ERROR_CODE"
}
```

## Best Practices
1. Always use HTTPS
2. Include Authorization header for protected routes
3. Handle errors gracefully
4. Use proper status codes

## Security
- Use JWT for authentication
- Implement role-based access control
- Validate and sanitize all input
- Use HTTPS
- Implement rate limiting
