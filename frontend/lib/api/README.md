# API Documentation

This folder contains a clean, organized API structure for the Project Zoe mobile app.

## File Structure

```
lib/api/
├── api_client.dart      # HTTP client configuration with Dio
├── api_endpoints.dart   # URL constants and endpoint definitions
├── api_models.dart      # Request/response models with JSON serialization
├── login_endpoint.dart  # AuthApi class with all authentication endpoints
├── signup_endpoint.dart # Legacy file (consolidated into AuthApi)
└── usage_examples.dart  # Comprehensive usage examples and patterns

lib/services/
└── auth_service.dart    # High-level service layer for auth operations
```

## Quick Start

### 1. Initialize API Client (in main.dart)

```dart
import 'package:frontend/api/api_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ApiClient().initialize(); // Initialize API client
  runApp(const MyApp());
}
```

### 2. Use AuthService in your Provider

```dart
import 'package:frontend/services/auth_service.dart';

// Login
final user = await AuthService.loginUser(
  email: 'user@example.com',
  password: 'password',
  churchName: 'demo',
);

// Register
final success = await AuthService.registerUser(
  firstName: 'John',
  lastName: 'Doe',
  email: 'john@example.com',
  phone: '+256701234567',
  gender: 'Male',
  civilStatus: 'Single',
  dateOfBirth: '1990-01-15',
);
```

## API Endpoints

### Base URL

```
http://localhost:4002/api
```

### Available Endpoints

1. **Login**

   - URL: `POST /auth/login`
   - Method: `AuthService.loginUser()` or `AuthApi.login()`

2. **Register**

   - URL: `POST /register`
   - Method: `AuthService.registerUser()` or `AuthApi.register()`

3. **Forgot Password**

   - URL: `POST /auth/forgot-password`
   - Method: `AuthService.forgotPassword()` or `AuthApi.forgotPassword()`

4. **Reset Password**
   - URL: `PUT /auth/reset-password/:token`
   - Method: `AuthService.resetPassword()` or `AuthApi.resetPassword()`

## Error Handling

All methods throw descriptive exceptions that can be caught and handled:

```dart
try {
  final user = await AuthService.loginUser(...);
} catch (e) {
  // Handle error with user-friendly message
  print('Login failed: $e');
}
```

## Security Features

- **Request/Response Logging**: For debugging (can be disabled in production)
- **Timeout Configuration**: 30 seconds for all requests
- **Error Interceptors**: Automatic error handling and formatting
- **Token Management**: Automatic bearer token handling

## For Contributors

### Adding New Endpoints

1. Add URL constant to `api_endpoints.dart`
2. Create request/response models in `api_models.dart`
3. Add API method to `AuthApi` class in `login_endpoint.dart`
4. Add service method to `AuthService` class
5. Update this documentation

### Code Standards

- Use descriptive error messages
- Include JSDoc-style comments for all public methods
- Follow the established patterns for request/response handling
- Add usage examples for new functionality

### Testing

- Test with actual backend endpoints
- Verify error handling for network issues
- Test timeout scenarios
- Validate request/response data structures

## Environment Configuration

To change the base URL for different environments, update `ApiEndpoints.baseUrl`:

```dart
// For development
static const String baseUrl = 'http://localhost:4002/api';

// For staging
static const String baseUrl = 'https://staging-api.projectzoe.com/api';

// For production
static const String baseUrl = 'https://api.projectzoe.com/api';
```

## Dependencies

This API setup uses:

- `dio: ^5.7.0` - HTTP client
- `provider: ^6.1.2` - State management (for integration)

Make sure these are included in your `pubspec.yaml`.
