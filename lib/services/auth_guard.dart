import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

/// Service to handle persistent authentication state
class AuthGuard {
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';
  static const String _userRoleKey = 'user_role';
  static const String _userDepartmentKey = 'user_department';

  /// Check if user is currently logged in
  static Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      return token != null && token.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking login status: $e');
      return false;
    }
  }

  /// Save user authentication data
  static Future<void> saveUserData(User user, String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      await prefs.setString(_userIdKey, user.id);
      await prefs.setString(_userNameKey, user.name);
      await prefs.setString(_userEmailKey, user.email);
      await prefs.setString(_userRoleKey, user.role.name);
      await prefs.setString(_userDepartmentKey, user.department);
    } catch (e) {
      debugPrint('Error saving user data: $e');
    }
  }

  /// Get saved user data
  static Future<User?> getSavedUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString(_userIdKey);
      final userName = prefs.getString(_userNameKey);
      final userEmail = prefs.getString(_userEmailKey);
      final userRoleString = prefs.getString(_userRoleKey);
      final userDepartment = prefs.getString(_userDepartmentKey);

      if (userId != null &&
          userName != null &&
          userEmail != null &&
          userRoleString != null &&
          userDepartment != null) {
        final userRole = UserRole.values.firstWhere(
          (role) => role.name == userRoleString,
          orElse: () => UserRole.restricted,
        );

        return User(
          id: userId,
          name: userName,
          email: userEmail,
          role: userRole,
          department: userDepartment,
        );
      }
      return null;
    } catch (e) {
      debugPrint('Error getting saved user: $e');
      return null;
    }
  }

  /// Get saved auth token
  static Future<String?> getSavedToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      debugPrint('Error getting saved token: $e');
      return null;
    }
  }

  /// Clear all saved authentication data
  static Future<void> clearUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userIdKey);
      await prefs.remove(_userNameKey);
      await prefs.remove(_userEmailKey);
      await prefs.remove(_userRoleKey);
      await prefs.remove(_userDepartmentKey);
    } catch (e) {
      debugPrint('Error clearing user data: $e');
    }
  }

  /// Validate if saved token is still valid (basic check)
  static Future<bool> isTokenValid() async {
    try {
      final token = await getSavedToken();
      if (token == null || token.isEmpty) return false;

      // Basic token expiration check (if JWT)
      if (token.startsWith('eyJ')) {
        // For now, assume token is valid if it exists
        // In production, you'd decode JWT and check expiration
        return true;
      }

      return true;
    } catch (e) {
      debugPrint('Error validating token: $e');
      return false;
    }
  }
}
