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
      // Re-throw with more specific error message
      if (e is ApiErrorResponse) {
        throw Exception(e.message);
      }
      throw Exception('Login failed: ${e.toString()}');
    }
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
