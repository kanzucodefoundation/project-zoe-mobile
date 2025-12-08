/// Base URL configuration for the Project Zoe API
class BaseUrl {
  /// Base URL for the Project Zoe server
  static const String baseUrl = 'https://ee3fef7b4a08.ngrok-free.app';
  // 'https://staging-projectzoe.kanzucodefoundation.org/server';
  // 'https://9cc46cd9f851.ngrok-free.app';

  /// Get base URL for API endpoints
  static String get apiUrl => '$baseUrl/api';
}
