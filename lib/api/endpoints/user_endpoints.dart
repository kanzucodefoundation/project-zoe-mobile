import '../base_url.dart';

/// User management related API endpoints
class UserEndpoints {
  /// Base URL for user endpoints
  static String get _baseUrl => BaseUrl.apiUrl;

  /// Get user profile endpoint
  static String get profile => '$_baseUrl/users/profile';

  /// Update user profile endpoint
  static String get updateProfile => '$_baseUrl/users/profile';

  /// Get all users endpoint (admin only)
  static String get allUsers => '$_baseUrl/users';

  /// Delete user endpoint
  static String get deleteUser => '$_baseUrl/users';

  /// Update user role endpoint (admin only)
  static String get updateUserRole => '$_baseUrl/users/role';

  /// Get user by ID endpoint
  static String getUserById(String userId) => '$_baseUrl/users/$userId';

  /// Delete specific user endpoint
  static String deleteUserById(String userId) => '$deleteUser/$userId';

  /// Get users by role endpoint
  static String getUsersByRole(String role) => '$_baseUrl/users/role/$role';

  /// Search users endpoint
  static String get searchUsers => '$_baseUrl/users/search';
}
