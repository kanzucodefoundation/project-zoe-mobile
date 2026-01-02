import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_guard.dart';
import '../services/auth_service.dart';
import '../api/api_client.dart';
import '../helpers/app_permissions.dart';

enum AuthStatus { unauthenticated, authenticating, authenticated, failed }

class AuthProvider extends ChangeNotifier {
  AuthProvider() {
    checkExistingSession();
  }

  AuthStatus _status = AuthStatus.unauthenticated;
  AuthStatus get status => _status;

  List<String> _permissions = [];
  List<String> get permissions => _permissions;

  List<String> _roles = [];
  List<String> get roles => _roles;

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
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
  Future<void> checkExistingSession() async {
    _status = AuthStatus.authenticating;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      final isLoggedIn = await AuthGuard.isLoggedIn();
      if (isLoggedIn) {
        final user = await AuthGuard.getSavedUser();
        final token = await AuthGuard.getSavedToken();
        debugPrint(
          '🧡🧡🧡 AuthProvider: Loaded saved user: ${user?.toJson()}, token length: ${token?.length}',
        );

        if (user != null && token != null) {
          await restoreSession(user, token);
          return;
        }
      }

      // No valid session found
      _status = AuthStatus.unauthenticated;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } catch (e) {
      debugPrint('Error checking existing session: $e');
      _status = AuthStatus.unauthenticated;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
    debugPrint('AuthProvider: Status set to authenticating');

    try {
      // Use new API authentication
      final authResult = await AuthService.loginUser(
        email: email,
        password: password,
        churchName: churchName,
      );

      // Store the user from the new structure
      // _user = authResult.user;
      _user ??= User.fromJson(
        authResult.user.toJson(),
        authResult.user.hierarchy,
      );

      debugPrint(
        'AuthProvider: User loaded: ${_user?.email} (Hierarchy: ${_user?.hierarchy.toString()})',
      );
      // Use the token from the authentication result
      final token = authResult.token;
      // debugPrint(
      //   'AuthProvider: Setting auth token: ${token.substring(0, 20)}...',
      // );

      // Set auth token for API calls
      ApiClient().setAuthToken(token);

      // Extract permissions and roles directly from user object
      _permissions = List<String>.from(_user!.permissions);
      _roles = List<String>.from(_user!.roles);
      debugPrint(
        'AuthProvider: Permissions loaded: ${_permissions.join(', ')}',
      );
      debugPrint('AuthProvider: Roles loaded: ${_roles.join(', ')}');

      // Set tenant/church name for CRM API calls
      String tenantName = '';
      if (_user?.hierarchy.myGroups.isNotEmpty == true) {
        tenantName = _user!.hierarchy.myGroups.first.name;
      }
      ApiClient().setTenant(tenantName);

      // Save user data persistently with token and refresh token
      await AuthGuard.saveUserData(_user!, token);
      // TODO: Also save refresh token when AuthGuard supports it
      // debugPrint(
      //   '💜💙💙 AuthProvider: Save user: ${user?.toJson()}, token length: ${token?.length}',
      // );

      // Verify token was saved correctly
      final savedToken = await AuthGuard.getSavedToken();
      // debugPrint(
      //   'AuthProvider: Token saved and verified: ${savedToken != null ? "✓" : "✗"}',
      // );
      if (savedToken != null) {
        debugPrint(
          'AuthProvider: Saved token starts with: ${savedToken.substring(0, 20)}...',
        );
      }

      // Set status based on user active state and token validity
      _status = _user!.isActive
          ? AuthStatus.authenticated
          : AuthStatus.unauthenticated;
      _error = null;

      debugPrint('AuthProvider: Login successful, status = $_status');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } catch (e) {
      debugPrint('AuthProvider: Login failed with error: $e');
      _status = AuthStatus.failed;

      // Handle specific error cases for better user experience
      String errorString = e.toString().toLowerCase();

      if (errorString.contains('user not found') ||
          errorString.contains('user does not exist') ||
          errorString.contains('404')) {
        _error = 'User not found. Please check your email address.';
      } else if (errorString.contains('invalid password') ||
          errorString.contains('incorrect password') ||
          errorString.contains('wrong password') ||
          errorString.contains('401') ||
          errorString.contains('unauthorized') ||
          errorString.contains('invalid credentials')) {
        _error = 'Invalid credentials. Please check your email and password.';
      } else if (errorString.contains('invalid church') ||
          errorString.contains('church not found')) {
        _error = 'Invalid church name. Please verify the church name.';
      } else if (errorString.contains('network') ||
          errorString.contains('connection') ||
          errorString.contains('timeout')) {
        _error = e.toString();
      } else if (errorString.contains('server error') ||
          errorString.contains('500')) {
        _error = 'Server error. Please try again later.';
      } else {
        // For any other errors, show a clean message but log the full error
        _error = 'Login failed. Please check your credentials and try again.';
        debugPrint('AuthProvider: Unhandled error details: $e');
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  // function to get group name and id from user hierarchy object
  List<Map<String, dynamic>> getGroupsFromHierarchy(String type) {
    if (_user == null || _user!.hierarchy.myGroups.isEmpty) {
      //  get from shared preferences

      // final groupsString = _prefs.getString('user_hierarchy_canmanage_groups');
      // if (groupsString != null) {
      //   final groupIds = groupsString
      //       .split(',')
      //       .map((id) => int.parse(id))
      //       .toList();

      //   return _user!.hierarchy.myGroups
      //       .where((group) => group.type == type && groupIds.contains(group.id))
      //       .map((group) => {'id': group.id, 'name': group.name})
      //       .toList();
      // }
      return [];
    }

    final canManageIds = _user!.hierarchy.canManageGroupIds ?? [];

    final groups = _user!.hierarchy.myGroups
        .where((group) => group.type == type && canManageIds.contains(group.id))
        .map((group) => {'id': group.id, 'name': group.name})
        .toList();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
    return groups;
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

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
        _error = null;
      } else {
        _status = AuthStatus.failed;
        _error = 'Registration failed. Please try again.';
      }
    } catch (e) {
      _status = AuthStatus.failed;
      _error = e.toString();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  Future<bool> forgotPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      await AuthService.forgotPassword(email);
      _isLoading = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      return false;
    }
  }

  /// Restore user session from saved data
  Future<void> restoreSession(User user, String token) async {
    try {
      _user = user;
      _status = AuthStatus.authenticated; // Assume valid if saved
      _error = null;

      // Restore permissions and roles from user data
      _permissions = List<String>.from(_user!.permissions);
      _roles = List<String>.from(_user!.roles);
      debugPrint(
        'AuthProvider: Restored permissions: ${_permissions.join(', ')}',
      );
      debugPrint('AuthProvider: Restored roles: ${_roles.join(', ')}');

      // Set auth token for API calls
      ApiClient().setAuthToken(token);

      // Set tenant/church name for CRM API calls
      String tenantName = '';
      if (_user?.hierarchy.myGroups.isNotEmpty == true) {
        tenantName = _user!.hierarchy.myGroups.first.name;
      }
      ApiClient().setTenant(tenantName);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } catch (e) {
      debugPrint('Error restoring session: $e');
      _status = AuthStatus.unauthenticated;
      _error = 'Failed to restore session';
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  /// Logout and clear all user data
  Future<void> logout() async {
    _status = AuthStatus.unauthenticated;
    _user = null;
    _error = null;

    // Clear persistent data
    await AuthGuard.clearUserData();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  /// Check if current user has admin privileges
  bool get isAdmin =>
      (_user?.hasRole('Movement Leader') ?? false) ||
      (_user?.hasRole('Location Pastor') ?? false);

  /// Check if current user has restricted access
  bool get isRestricted => !(_user?.hasPermission('CRM_EDIT') ?? false);

  /// Check if current user can perform admin actions (edit/delete shepherds)
  bool get canManageShepherds => isAdmin;

  /// Check if current user can view shepherd details
  bool get canViewShepherds => true;

  /// Check if current user is MC Shepherd
  bool get isMcShepherdRole => _user?.hasRole('MC Shepherd') ?? false;

  /// Check if user has a specific role
  bool hasRole(String role) => _user?.hasRole(role) ?? false;

  /// Check if user has a specific permission
  bool hasPermission(String permission) => _permissions.contains(permission);

  /// Check if current user is web admin
  bool get isWebAdmin => _user?.hasRole('System Admin') ?? false;

  /// Clear saved data and reset to initial state
  Future<void> clearUserData() async {
    _user = null;
    _permissions = [];
    _roles = [];
    _status = AuthStatus.unauthenticated;

    // Clear persistent data
    await AuthGuard.clearUserData();

    notifyListeners();
  }

  Future<bool> resetPassword({
    required String token,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      return await AuthService.resetPassword(
        token: token,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
    } catch (e) {
      throw Exception('Password reset failed: $e');
    }
  }

  bool get isMcShepherdPermissions {
    return _permissions.contains(AppPermissions.roleCrmView) &&
        _permissions.contains(AppPermissions.roleCrmEdit) &&
        _permissions.contains(AppPermissions.roleReportSubmit) &&
        _permissions.contains(AppPermissions.roleReportView);
  }

  bool get canSubmitReport =>
      !(_user?.hasPermission(AppPermissions.roleReportSubmit) ?? false);
}
