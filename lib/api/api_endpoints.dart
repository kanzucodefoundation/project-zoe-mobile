import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiEndpoints {
  // Base URL - platform aware
  static String get baseUrl {
    if (kIsWeb) {
      // For web builds, localhost should work
      return 'http://localhost:4002/api';
    } else if (Platform.isAndroid) {
      // For Android emulator, use 10.0.2.2 to reach host machine
      return 'http://10.0.2.2:4002/api';
    } else if (Platform.isIOS) {
      // For iOS simulator, localhost should work
      return 'http://localhost:4002/api';
    } else {
      // For other platforms, use localhost
      return 'http://localhost:4002/api';
    }
  }

  // Authentication endpoints
  static const String login = '/auth/login';
  static const String register = '/register';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword =
      '/auth/reset-password'; // :token will be appended

  // Helper method to build reset password URL with token
  static String resetPasswordWithToken(String token) => '$resetPassword/$token';
}
