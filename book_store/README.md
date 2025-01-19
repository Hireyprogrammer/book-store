# Book Store Flutter App

## Prerequisites
- Flutter SDK (3.10+ recommended)
- Dart SDK
- Android Studio or VS Code
- Backend server running

## Setup Instructions

1. Clone the repository
```bash
git clone https://github.com/yourusername/book-store-flutter.git
cd book-store-flutter
```

2. Install Dependencies
```bash
flutter pub get
```

3. Configure Backend Connection
- Open `lib/app/services/api_service.dart`
- Update `_baseUrl` to match your backend server
  - Default: `http://localhost:3000/api`

4. Run the Application
```bash
# Development mode
flutter run

# Specific platform
flutter run -d chrome  # Web
flutter run -d windows # Windows
flutter run -d android # Android
```

## Project Structure
```
book_store/
│
├── lib/
│   ├── app/
│   │   ├── controllers/     # Business logic
│   │   ├── services/        # API interactions
│   │   ├── routes/          # Navigation
│   │   └── ui/              # Screens and widgets
│   └── main.dart            # App entry point
│
├── assets/                  # Static resources
├── test/                    # Unit and widget tests
└── pubspec.yaml             # Project dependencies
```

## Key Features
- User Authentication
- Book Browsing
- Responsive Design
- Cross-Platform Support

## Environment Configuration
- Ensure backend server is running
- Check CORS settings in backend
- Verify network connectivity

## Troubleshooting
- Verify backend server URL
- Check network permissions
- Ensure all dependencies are installed
- Run `flutter doctor` for system checks

## Deployment
- Build for specific platforms
```bash
# Android
flutter build apk

# iOS
flutter build ios

# Web
flutter build web
```

## Testing
```bash
# Run tests
flutter test

# Widget tests
flutter test test/widget_test.dart
```

## State Management
- Using GetX for reactive state management
- Centralized controllers
- Dependency injection

## API Integration
- Custom `ApiService` for backend communication
- Handles authentication
- Error and connection management

## Security Considerations
- Token-based authentication
- Secure storage of credentials
- HTTPS recommended for production

## Contributing
1. Fork the repository
2. Create feature branch
3. Commit changes
4. Push to branch
5. Create Pull Request

## License
MIT License

## Support
For issues or questions, open a GitHub issue.

## Future Roadmap
- [ ] Implement offline mode
- [ ] Add more comprehensive testing
- [ ] Enhance UI/UX
- [ ] Implement advanced search
