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
      final userEntity = await AuthService.loginUser(
        email: email,
        password: password,
        churchName: churchName ?? 'default',
      );

      // Convert UserEntity to User model
      final user = User(
        id: userEntity.id,
        name: userEntity.name,
        email: userEntity.email,
        role: UserRole.admin, // Default to admin for now
        department: 'Church Operations',
        churchName: churchName ?? 'demo',
      );

      debugPrint(
        'AuthProvider: Valid credentials found, setting authenticated status',
      );
      _user = user;
      _status = AuthStatus.authenticated;
      _error = null;

      // Generate auth token (this should come from API response)
      final token = 'api-token-${DateTime.now().millisecondsSinceEpoch}';

      // Set auth token for API calls
      ApiClient().setAuthToken(token);

      // Save user data persistently
      await AuthGuard.saveUserData(_user!, token);

      // Notify listeners immediately after successful authentication
      debugPrint(
        'AuthProvider: About to notify listeners with authenticated status',
      );
      notifyListeners();
      debugPrint('AuthProvider: Login successful, status = $_status');
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

    debugPrint('AuthProvider: Final login status = $_status');
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

  /// Restore user session from saved data
  Future<void> restoreSession(User user, String token) async {
    try {
      _user = user;
      _status = AuthStatus.authenticated;
      _error = null;

      // Set auth token for API calls
      ApiClient().setAuthToken(token);

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
