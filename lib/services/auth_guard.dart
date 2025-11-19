import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../entities/user.dart';

/// Service to handle persistent authentication state
class AuthGuard {
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';

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
  static Future<void> saveUserData(UserEntity user, String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      await prefs.setString(_userIdKey, user.id);
      await prefs.setString(_userNameKey, user.name);
      await prefs.setString(_userEmailKey, user.email);
    } catch (e) {
      debugPrint('Error saving user data: $e');
    }
  }

  /// Get saved user data
  static Future<UserEntity?> getSavedUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString(_userIdKey);
      final userName = prefs.getString(_userNameKey);
      final userEmail = prefs.getString(_userEmailKey);

      if (userId != null && userName != null && userEmail != null) {
        return UserEntity(id: userId, name: userName, email: userEmail);
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
