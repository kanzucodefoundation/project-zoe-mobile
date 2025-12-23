/// Base URL configuration for the Project Zoe API
class BaseUrl {
  /// Base URL for the Project Zoe server
  static const String baseUrl =
      // 'https://staging-projectzoe.kanzucodefoundation.org/server';
      // Alternative URLs for development:
      'http://localhost:3001';

  /// Get base URL for API endpoints
  static String get apiUrl => '$baseUrl/api';
}
