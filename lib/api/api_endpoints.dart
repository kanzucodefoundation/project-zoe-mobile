/// DEPRECATED: This file is deprecated. Use the new organized endpoint structure instead.
///
/// Import endpoints like this:
/// ```dart
/// import 'package:frontend/api/endpoints/endpoints.dart';
///
/// // Then use:
/// AuthEndpoints.login
/// AuthEndpoints.profile
/// ReportEndpoints.reports
/// ReportEndpoints.reportsSubmit
/// ```
///
/// Or import specific endpoint classes:
/// ```dart
/// import 'package:frontend/api/endpoints/auth_endpoints.dart';
/// import 'package:frontend/api/endpoints/user_endpoints.dart';
/// ```

import 'base_url.dart';
import 'endpoints/endpoints.dart';

/// Legacy ApiEndpoints class - Deprecated
/// Use the new organized endpoint classes instead
@deprecated
class ApiEndpoints {
  /// Base URL - use BaseUrl.apiUrl instead
  @deprecated
  static String get baseUrl => BaseUrl.apiUrl;

  /// Authentication endpoints - use AuthEndpoints instead
  @deprecated
  static String get login => AuthEndpoints.login;

  @deprecated
  static String get register => AuthEndpoints.register; // Updated to /register

  @deprecated
  static String get forgotPassword => AuthEndpoints.forgotPassword;

  @deprecated
  static String get resetPassword => AuthEndpoints.resetPassword;

  @deprecated
  static String get profile => AuthEndpoints.profile;

  /// Helper method - use AuthEndpoints.resetPasswordWithToken instead
  @deprecated
  static String resetPasswordWithToken(String token) =>
      AuthEndpoints.resetPasswordWithToken(token);
}
