import '../api/auth_endpoint.dart';
import '../api/api_models.dart';
import '../models/user.dart';

/// Auth result with user and authentication tokens
class AuthResult {
  final User user;
  final String token;
  final String refreshToken;
  final int expiresIn;

  AuthResult({
    required this.user,
    required this.token,
    required this.refreshToken,
    required this.expiresIn,
  });
}

/// Service class to handle authentication API calls and data transformation
class AuthService {
  /// Login user and return AuthResult with user and tokens
  static Future<AuthResult> loginUser({
    required String email,
    required String password,
    String? churchName,
  }) async {
    try {
      // Use provided credentials for login
      final request = LoginRequest(
        username: email,
        password: password,
        churchName:
            churchName ?? 'worship harvest', // Use default if not provided
      );

      final response = await AuthApi.login(request);

      if (response.success) {
        // Parse the new authentication response structure
        final authResponse = AuthResponse.fromJson(response.data ?? {});

        return AuthResult(
          user: authResponse.user,
          token: authResponse.token,
          refreshToken: authResponse.refreshToken,
          expiresIn: authResponse.expiresIn,
        );
      } else {
        throw Exception(response.message ?? 'Login failed');
      }
    } catch (e) {
      // Re-throw with more context
      if (e is Exception) {
        throw e;
      }
      throw Exception('Authentication failed: $e');
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
    // TODO: Implement registration with new API
    throw Exception('Registration not yet implemented for new API');
  }

  /// Request password reset
  static Future<void> forgotPassword(String email) async {
    // TODO: Implement forgot password with new API
    throw Exception('Password reset not yet implemented for new API');
  }

  /// Reset password with token
  static Future<bool> resetPassword({
    required String token,
    required String newPassword,
    required String confirmPassword,
  }) async {
    // TODO: Implement password reset with new API
    throw Exception('Password reset not yet implemented for new API');
  }
}
