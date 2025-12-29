/// Base URL configuration for the Project Zoe API
class BaseUrl {
  /// Base URL for the Project Zoe server
  static const String baseUrl =
      // 'https://staging-projectzoe.kanzucodefoundation.org/server';
      // Alternative URLs for development:
      // 'http://localhost:3001';
      // 'http://10.110.34.203:3001';
      // 'http://10.254.115.203:3001';
      // 'http://192.168.100.84:3001';
      'http://10.201.189.98:3001';

  /// Get base URL for API endpoints
  static String get apiUrl => '$baseUrl/api';
}
