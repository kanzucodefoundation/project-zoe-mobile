import '../base_url.dart';

/// Authentication related API endpoints
class AuthEndpoints {
  /// Base URL for auth endpoints
  static String get _baseUrl => BaseUrl.apiUrl;

  /// Login endpoint - POST /auth/login
  static String get login => '$_baseUrl/auth/login';

  /// Register/Signup endpoint - POST /register
  static String get register => '$_baseUrl/register';

  /// Forgot password endpoint
  static String get forgotPassword => '$_baseUrl/auth/forgot-password';

  /// Reset password endpoint base
  static String get resetPassword => '$_baseUrl/auth/reset-password';

  /// User profile endpoint - GET /auth/profile
  static String get profile => '$_baseUrl/auth/profile';

  /// Logout endpoint
  static String get logout => '$_baseUrl/auth/logout';

  /// Refresh token endpoint
  static String get refreshToken => '$_baseUrl/auth/refresh-token';

  /// Verify email endpoint
  static String get verifyEmail => '$_baseUrl/auth/verify-email';

  /// Resend verification email endpoint
  static String get resendVerification => '$_baseUrl/auth/resend-verification';

  /// Helper method to build reset password URL with token
  static String resetPasswordWithToken(String token) => '$resetPassword/$token';

  /// Helper method to build verify email URL with token
  static String verifyEmailWithToken(String token) => '$verifyEmail/$token';
}
