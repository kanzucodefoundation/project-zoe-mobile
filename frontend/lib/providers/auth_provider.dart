import 'package:flutter/material.dart';
import '../entities/user.dart';
import '../services/auth_service.dart';
import '../services/auth_guard.dart';
import '../api/api_client.dart';

enum AuthStatus { unauthenticated, authenticating, authenticated, failed }

class AuthProvider extends ChangeNotifier {
  AuthProvider();

  AuthStatus _status = AuthStatus.unauthenticated;
  AuthStatus get status => _status;

  UserEntity? _user;
  UserEntity? get user => _user;

  String? _error;
  String? get error => _error;

  Future<void> login(
    String email,
    String password, {
    String? churchName,
  }) async {
    _status = AuthStatus.authenticating;
    _error = null;
    notifyListeners();

    try {
      _user = await AuthService.loginUser(
        email: email,
        password: password,
        churchName: churchName ?? 'demo', // Default to 'demo' if not provided
      );
      _status = AuthStatus.authenticated;
      _error = null; // Clear any previous errors

      // Generate or get auth token (in real app, this comes from login response)
      final token =
          'auth-token-${_user!.id}-${DateTime.now().millisecondsSinceEpoch}';

      // Set auth token for API calls
      ApiClient().setAuthToken(token);

      // Save user data persistently
      await AuthGuard.saveUserData(_user!, token);
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

    try {
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
        // After successful registration, you might want to automatically log in
        // or just show a success message and redirect to login
        _status = AuthStatus.unauthenticated;
      } else {
        throw Exception('Registration failed');
      }
    } catch (e) {
      _status = AuthStatus.failed;
      _error = e.toString();
    }

    notifyListeners();
  }

  Future<void> forgotPassword(String email) async {
    try {
      final success = await AuthService.forgotPassword(email);
      if (!success) {
        throw Exception('Failed to send password reset email');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// Restore user session from saved data
  Future<void> restoreSession(UserEntity user, String token) async {
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
}
