
import 'base_url.dart';
import 'endpoints/endpoints.dart';



class ApiEndpoints {
  /// Base URL - use BaseUrl.apiUrl instead
  static String get baseUrl => BaseUrl.apiUrl;

  /// Authentication endpoints - use AuthEndpoints instead
  static String get login => AuthEndpoints.login;


  static String get register => AuthEndpoints.register; // Updated to /register


  static String get forgotPassword => AuthEndpoints.forgotPassword;

  @deprecated
  static String get resetPassword => AuthEndpoints.resetPassword;

  static String get profile => AuthEndpoints.profile;

  /// Helper method - use AuthEndpoints.resetPasswordWithToken instead
  static String resetPasswordWithToken(String token) =>
      AuthEndpoints.resetPasswordWithToken(token);
}
