import '../api/login_endpoint.dart';
import '../api/api_models.dart';
import '../entities/user.dart';

/// Service class to handle authentication API calls and data transformation
class AuthService {
  /// Login user and return UserEntity
  static Future<UserEntity> loginUser({
    required String email,
    required String password,
    required String churchName,
  }) async {
    try {
      final request = LoginRequest(
        username: email,
        password: password,
        churchName: churchName,
      );

      final response = await AuthApi.login(request);

      if (response.success && response.user != null) {
        // Transform API response to UserEntity
        return UserEntity(
          id: response.user!['id']?.toString() ?? '',
          name:
              '${response.user!['firstName'] ?? ''} ${response.user!['lastName'] ?? ''}',
          email: response.user!['email'] ?? email,
        );
      } else {
        throw Exception(response.message ?? 'Login failed');
      }
    } catch (e) {
      // Handle network connection errors with fallback authentication
      String errorMessage = e.toString().toLowerCase();

      if (errorMessage.contains('connection') ||
          errorMessage.contains('network') ||
          errorMessage.contains('internet') ||
          errorMessage.contains('timeout') ||
          errorMessage.contains('dio')) {
        // Fallback authentication for development/testing
        if (_isValidTestCredentials(email, password, churchName)) {
          return UserEntity(
            id: 'test-user-id',
            name: 'Test User',
            email: email,
          );
        } else {
          throw Exception(
            'Cannot connect to server. Please check your internet connection and try again.',
          );
        }
      }

      // Re-throw with more specific error message
      if (e is ApiErrorResponse) {
        throw Exception(e.message);
      }
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  /// Check if credentials are valid for fallback authentication
  static bool _isValidTestCredentials(
    String email,
    String password,
    String churchName,
  ) {
    // Allow some test credentials for development
    return (email == 'john.doe@kanzucodefoundation.org' &&
            password == 'Xpass@123' &&
            churchName == 'demo') ||
        (email == 'test@example.com' &&
            password == 'test123' &&
            churchName == 'demo');
  }

  /// Register user and return success status
  static Future<bool> registerUser({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String gender,
    required String civilStatus,
    required String dateOfBirth,
    required String churchName,
  }) async {
    try {
      final request = RegisterRequest(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        gender: gender,
        civilStatus: civilStatus,
        dateOfBirth: dateOfBirth,
        churchName: churchName,
      );

      final response = await AuthApi.register(request);
      return response.success;
    } catch (e) {
      if (e is ApiErrorResponse) {
        throw Exception(e.message);
      }
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  /// Send forgot password request
  static Future<bool> forgotPassword(String email) async {
    try {
      final request = ForgotPasswordRequest(email: email);
      final response = await AuthApi.forgotPassword(request);
      return response.success;
    } catch (e) {
      if (e is ApiErrorResponse) {
        throw Exception(e.message);
      }
      throw Exception('Password reset request failed: ${e.toString()}');
    }
  }

  /// Reset password with token
  static Future<bool> resetPassword({
    required String token,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final request = ResetPasswordRequest(
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

      final response = await AuthApi.resetPassword(token, request);
      return response.success;
    } catch (e) {
      if (e is ApiErrorResponse) {
        throw Exception(e.message);
      }
      throw Exception('Password reset failed: ${e.toString()}');
    }
  }
}
