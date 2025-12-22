// import 'package:flutter/material.dart';
// import '../models/user.dart';
// import '../services/auth_guard.dart';
// import '../services/auth_service.dart';
// import '../api/api_client.dart';

// enum AuthStatus { unauthenticated, authenticating, authenticated, failed }

// class AuthProvider extends ChangeNotifier {
//   AuthProvider() {
//     _checkExistingSession();
//   }

//   AuthStatus _status = AuthStatus.unauthenticated;
//   AuthStatus get status => _status;

//   User? _user;
//   User? get user => _user;

//   String? _error;
//   String? get error => _error;

//   /// Clear the current error message
//   void clearError() {
//     _error = null;
//     notifyListeners();
//   }

//   /// Get current API connection status
//   Future<Map<String, dynamic>> getConnectionStatus() async {
//     final savedToken = await AuthGuard.getSavedToken();
//     final apiClient = ApiClient();

//     return {
//       'hasToken': savedToken != null,
//       'tokenLength': savedToken?.length ?? 0,
//       'tokenPreview': savedToken != null
//           ? '${savedToken.substring(0, 20)}...'
//           : null,
//       'apiBaseUrl': apiClient.dio.options.baseUrl,
//       'hasAuthHeader': apiClient.dio.options.headers.containsKey(
//         'Authorization',
//       ),
//     };
//   }

//   /// Check for existing session when app starts
//   Future<void> _checkExistingSession() async {
//     _status = AuthStatus.authenticating;
//     notifyListeners();

//     try {
//       final isLoggedIn = await AuthGuard.isLoggedIn();
//       if (isLoggedIn) {
//         final user = await AuthGuard.getSavedUser();
//         final token = await AuthGuard.getSavedToken();
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_guard.dart';
import '../services/auth_service.dart';
import '../api/api_client.dart';

enum AuthStatus { unauthenticated, authenticating, authenticated, failed }

class AuthProvider extends ChangeNotifier {
  AuthProvider() {
    _checkExistingSession();
  }

  AuthStatus _status = AuthStatus.unauthenticated;
  AuthStatus get status => _status;

  User? _user;
  User? get user => _user;

  String? _error;
  String? get error => _error;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Clear the current error message
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Get current API connection status
  Future<Map<String, dynamic>> getConnectionStatus() async {
    final savedToken = await AuthGuard.getSavedToken();
    final apiClient = ApiClient();

    return {
      'hasToken': savedToken != null,
      'tokenLength': savedToken?.length ?? 0,
      'tokenPreview': savedToken != null
          ? '${savedToken.substring(0, 20)}...'
          : null,
      'apiBaseUrl': apiClient.dio.options.baseUrl,
      'hasAuthHeader': apiClient.dio.options.headers.containsKey(
        'Authorization',
      ),
    };
  }

  /// Check for existing session when app starts
  Future<void> _checkExistingSession() async {
    _status = AuthStatus.authenticating;
    notifyListeners();

    try {
      final isLoggedIn = await AuthGuard.isLoggedIn();
      if (isLoggedIn) {
        final user = await AuthGuard.getSavedUser();
        final token = await AuthGuard.getSavedToken();

        if (user != null && token != null) {
          await restoreSession(user, token);
          return;
        }
      }

      // No valid session found
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    } catch (e) {
      debugPrint('Error checking existing session: $e');
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    }
  }

  Future<void> login(
    String email,
    String password, {
    String? churchName,
  }) async {
    debugPrint('AuthProvider: Starting login for $email');
    _status = AuthStatus.authenticating;
    _error = null;
    notifyListeners();
    debugPrint('AuthProvider: Status set to authenticating');

    try {
      // Use real API authentication
      final authResult = await AuthService.loginUser(
        email: email,
        password: password,
        churchName: churchName ?? 'demo',
      );

      // Convert UserEntity to User model
      _user = User(
        id: authResult.user.id,
        name: authResult.user.name,
        email: authResult.user.email,
        role: UserRole.admin, // Default to admin for demo user
        department: 'IT',
        churchName: churchName ?? 'demo',
      );

      // Use the REAL token from server!
      final token = authResult.token;
      debugPrint(
        'AuthProvider: Setting auth token: ${token.substring(0, 20)}...',
      );

      // Set auth token for API calls
      ApiClient().setAuthToken(token);

      // Set tenant/church name for CRM API calls
      ApiClient().setTenant(_user!.churchName);

      // Save user data persistently
      await AuthGuard.saveUserData(_user!, token);

      // Verify token was saved correctly
      final savedToken = await AuthGuard.getSavedToken();
      debugPrint(
        'AuthProvider: Token saved and verified: ${savedToken != null ? "✓" : "✗"}',
      );
      if (savedToken != null) {
        debugPrint(
          'AuthProvider: Saved token starts with: ${savedToken.substring(0, 20)}...',
        );
      }

      _status = AuthStatus.authenticated;
      _error = null;

      debugPrint('AuthProvider: Login successful, status = $_status');
      notifyListeners();
    } catch (e) {
      debugPrint('AuthProvider: Login failed with error: $e');
      _status = AuthStatus.failed;

      // Handle specific error cases for better user experience
      if (e.toString().contains('user not found') ||
          e.toString().contains('User does not exist') ||
          e.toString().contains('404')) {
        _error =
            'User not found. Please check your credentials or register first.';
      } else if (e.toString().contains('invalid password') ||
          e.toString().contains('incorrect password') ||
          e.toString().contains('401')) {
        _error = 'Invalid password. Please try again.';
      } else if (e.toString().contains('network') ||
          e.toString().contains('connection')) {
        _error = 'Network error. Please check your internet connection.';
      } else {
        _error = e.toString();
      }

      notifyListeners();
    }
  }

  Future<void> signup({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String gender,
    required String civilStatus,
    required String dateOfBirth,
    required String churchName,
  }) async {
    _status = AuthStatus.authenticating;
    _error = null;
    notifyListeners();

    try {
      // Use real API registration
      final success = await AuthService.registerUser(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        gender: gender,
        civilStatus: civilStatus,
        dateOfBirth: dateOfBirth,
        churchName: churchName,
      );

      if (success) {
        _status = AuthStatus.unauthenticated;
        _error =
            'Registration successful! Please log in with your credentials.';
      } else {
        _status = AuthStatus.failed;
        _error = 'Registration failed. Please try again.';
      }
    } catch (e) {
      _status = AuthStatus.failed;
      _error = e.toString();
    }

    notifyListeners();
  }

  Future<void> forgotPassword(String email) async {
    try {
      // Use real API for forgot password
      await AuthService.forgotPassword(email);
      // Success - this will be handled by the calling widget
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// Reset password with token
  Future<bool> resetPassword({
    required String token,
    required String email,
    required String newPassword,
    required String confirmPassword,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await AuthService.resetPassword(
        token: token,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Restore user session from saved data
  Future<void> restoreSession(User user, String token) async {
    try {
      _user = user;
      _status = AuthStatus.authenticated;
      _error = null;

      // Set auth token for API calls
      ApiClient().setAuthToken(token);

      // Set tenant/church name for CRM API calls
      ApiClient().setTenant(_user!.churchName);

      notifyListeners();
    } catch (e) {
      debugPrint('Error restoring session: $e');
      _status = AuthStatus.unauthenticated;
      _error = 'Failed to restore session';
      notifyListeners();
    }
  }

  /// Set auth status to unauthenticated
  void setUnauthenticated() {
    _status = AuthStatus.unauthenticated;
    _user = null;
    _error = null;
    notifyListeners();
  }

  /// Manually check for existing session (useful for testing)
  Future<void> checkSession() async {
    await _checkExistingSession();
  }

  /// Logout and clear all persistent data
  Future<void> logout() async {
    _user = null;
    _status = AuthStatus.unauthenticated;

    // Clear auth token
    ApiClient().clearAuthToken();

    // Clear tenant/church name
    ApiClient().clearTenant();

    // Clear persistent data
    await AuthGuard.clearUserData();

    notifyListeners();
  }

  /// Check if current user has admin privileges
  bool get isAdmin => _user?.isAdmin ?? false;

  /// Check if current user has restricted access
  bool get isRestricted => _user?.isRestricted ?? true;

  /// Check if current user can perform admin actions (edit/delete shepherds)
  bool get canManageShepherds => isAdmin;

  /// Check if current user can view shepherd details
  bool get canViewShepherds => _status == AuthStatus.authenticated;

  /// Get current user's role display name
  String get userRoleDisplayName => _user?.roleDisplayName ?? 'Guest';

  /// Get current user's department
  String get userDepartment => _user?.department ?? 'Unknown';
}
