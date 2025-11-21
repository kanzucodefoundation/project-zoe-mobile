import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_guard.dart';
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
    _status = AuthStatus.authenticating;
    _error = null;
    notifyListeners();

    try {
      // Demo credentials for development - support both admin and restricted users
      User? demoUser;

      if (email == 'john.doe@kanzucodefoundation.org' &&
          password == 'Xpass@123') {
        // Admin user
        demoUser = User(
          id: 'admin-001',
          name: 'John Doe',
          email: 'john.doe@kanzucodefoundation.org',
          role: UserRole.admin,
          department: 'IT Administration',
        );
      } else if (email == 'jane.doe@kanzucodefoundation.org' &&
          password == 'Password@1') {
        // Restricted user
        demoUser = User(
          id: 'user-001',
          name: 'Jane Doe',
          email: 'jane.doe@kanzucodefoundation.org',
          role: UserRole.restricted,
          department: 'Church Operations',
        );
      }

      if (demoUser != null && (churchName == 'demo' || churchName == null)) {
        _user = demoUser;
        _status = AuthStatus.authenticated;
        _error = null;

        // Generate development auth token
        final token = 'dev-token-${DateTime.now().millisecondsSinceEpoch}';

        // Set auth token for API calls (if needed later)
        ApiClient().setAuthToken(token);

        // Save user data persistently
        await AuthGuard.saveUserData(_user!, token);

        // Notify listeners immediately after successful authentication
        notifyListeners();
      } else {
        throw Exception(
          'Invalid credentials. Use one of:\n\n'
          'Admin User:\n'
          'Email: john.doe@kanzucodefoundation.org\n'
          'Password: Xpass@123\n\n'
          'Restricted User:\n'
          'Email: jane.doe@kanzucodefoundation.org\n'
          'Password: Password@1\n\n'
          'Church: demo',
        );
      }
    } catch (e) {
      _status = AuthStatus.failed;
      _error = e.toString();
    }

    notifyListeners();
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

    // For development - disable signup, show login credentials
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate loading

    _status = AuthStatus.failed;
    _error =
        'Signup disabled for development.\n\n'
        'Use these credentials to login:\n\n'
        'Admin User:\n'
        'Email: john.doe@kanzucodefoundation.org\n'
        'Password: Xpass@123\n\n'
        'Restricted User:\n'
        'Email: jane.doe@kanzucodefoundation.org\n'
        'Password: Password@1\n\n'
        'Church: demo';

    notifyListeners();
  }

  Future<void> forgotPassword(String email) async {
    // For development - disable forgot password, show login credentials
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate loading
    throw Exception(
      'Password reset disabled for development.\n\n'
      'Use these credentials:\n\n'
      'Admin User:\n'
      'Email: john.doe@kanzucodefoundation.org\n'
      'Password: Xpass@123\n\n'
      'Restricted User:\n'
      'Email: jane.doe@kanzucodefoundation.org\n'
      'Password: Password@1\n\n'
      'Church: demo',
    );
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
