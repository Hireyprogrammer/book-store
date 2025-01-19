# Book Store Backend Deployment Guide

## Prerequisites
1. GitHub Account
2. Render Account
3. MongoDB Atlas Account

## Deployment Steps

### 1. Prepare Repository
- Ensure all code is committed to GitHub
- Create `.gitignore` file (if not exists)
```
node_modules/
.env
```

### 2. MongoDB Atlas Setup
1. Create a free cluster at [MongoDB Atlas](https://www.mongodb.com/cloud/atlas)
2. Create a database user
3. Whitelist all IP addresses (0.0.0.0/0) for development
4. Get connection string

### 3. Render Deployment
1. Go to [Render](https://render.com/)
2. Click "New Web Service"
3. Connect your GitHub repository
4. Configure Build Settings:
   - Build Command: `npm install`
   - Start Command: `npm start`

### 4. Environment Variables
Set these in Render's dashboard:
- `MONGODB_URI`: Your MongoDB Atlas connection string
- `JWT_SECRET`: Long random string (e.g., `openssl rand -hex 32`)
- `JWT_EXPIRATION`: Token expiration time (e.g., 3600)
- `SALT_ROUNDS`: 10

### 5. Deployment Verification
- Check Render logs
- Test API endpoints
- Monitor performance

## Troubleshooting
- Ensure all dependencies are in `package.json`
- Check environment variable configurations
- Verify network access in MongoDB Atlas

## Recommended Next Steps
1. Set up CORS for frontend
2. Implement proper error handling
3. Add logging
