import 'dart:convert';

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
  static const String _churchNameKey = 'church_name';
  static const String _userHierarchyKey = 'user_hierarchy';
  static const String _userAvaratKey = 'user_avatar';

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
      // await prefs.setString(
      //   _userHierarchyGroups,
      //   user.hierarchy.myGroups.join(','),
      // );
      // await prefs.setString(
      //   _userHierarchyCanManageGroups,
      //   user.hierarchy.canManageGroupIds.join(','),
      // );
      // await prefs.setString(
      //   _userHierarchyCanViewGroups,
      //   user.hierarchy.canViewGroupIds.join(','),
      // );
      await prefs.setString(_userIdKey, user.id.toString());
      await prefs.setString(_userNameKey, user.fullName);
      await prefs.setString(_userEmailKey, user.email);
      await prefs.setString(_userRoleKey, user.primaryRole);
      await prefs.setString(_userAvaratKey, user.avatar);
      await prefs.setString(_churchNameKey, user.churchName);
      // Save additional user data as JSON for complex structures
      await prefs.setString('user_roles', user.roles.join(','));
      await prefs.setString('user_permissions', user.permissions.join(','));
      await prefs.setString(
        _userHierarchyKey,
        jsonEncode(user.hierarchy.toJson()),
      );
    } catch (e) {
      debugPrint('Error saving user data: $e');
    }
  }

  static Future<UserHierarchy?> getSavedHierarchy() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hierarchyJson = prefs.getString(_userHierarchyKey);

      if (hierarchyJson == null) {
        return null;
      }

      final hierarchyMap = jsonDecode(hierarchyJson) as Map<String, dynamic>;
      return UserHierarchy.fromJson(hierarchyMap);
    } catch (e) {
      debugPrint('Error loading hierarchy: $e');
      return null;
    }
  }

  /// Get saved user data (simplified for new model)
  static Future<User?> getSavedUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userIdString = prefs.getString(_userIdKey);
      final userName = prefs.getString(_userNameKey);
      final userAvatar = prefs.getString(_userAvaratKey);
      final userEmail = prefs.getString(_userEmailKey);
      final userRoleString = prefs.getString(_userRoleKey);
      final userRolesString = prefs.getString('user_roles');
      final userPermissionsString = prefs.getString('user_permissions');
      // final userHierarchyGroups = prefs.getString(_userHierarchyGroups);
      // final userHierarchyCanManageGroups = prefs.getString(
      //   _userHierarchyCanManageGroups,
      // );
      // final userHierarchyCanViewGroups = prefs.getString(
      //   _userHierarchyCanViewGroups,
      // );
      debugPrint('✅ ✅✅ ✅ avatar: $userAvatar');
      final hierarchyJson = prefs.getString(_userHierarchyKey);
      if (hierarchyJson == null) {
        return null;
      }

      final hierarchy = UserHierarchy.fromJson(
        jsonDecode(hierarchyJson) as Map<String, dynamic>,
      );
      debugPrint(
        '✅ ✅ Loaded hierarchy: ${hierarchy.toJson()}',
      ); // Debug print to verify loading

      if (userIdString != null && userName != null && userEmail != null) {
        // Parse saved data
        final userId = int.tryParse(userIdString) ?? 0;
        final roles =
            userRolesString?.split(',') ?? [userRoleString ?? 'Unknown'];
        final permissions = userPermissionsString?.split(',') ?? [];
        print('✅ ✅ Loaded permissions: $permissions');

        return User(
          id: userId,
          contactId: 1, // Default for saved user
          username: userEmail,
          email: userEmail,
          fullName: userName,
          avatar: userAvatar ?? 'https://i.pravatar.cc/200?img=$userId',
          isActive: true,
          roles: roles,
          permissions: permissions,
          hierarchy: hierarchy,
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

  /// Get saved church name
  static Future<String> getSavedChurchName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_churchNameKey) ?? 'demo';
    } catch (e) {
      debugPrint('Error getting saved church name: $e');
      return 'demo';
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
      await prefs.remove(_churchNameKey);
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
