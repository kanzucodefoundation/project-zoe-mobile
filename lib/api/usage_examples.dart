// // Example usage of the API endpoints
// // This file demonstrates how to use the AuthApi and AuthService

// import 'package:frontend/api/api_client.dart';
// import 'package:frontend/api/login_endpoint.dart';
// import 'package:frontend/api/api_models.dart';
// import 'package:frontend/services/auth_service.dart';

// class ApiUsageExamples {
//   /// Example: How to initialize the API client (usually done in main.dart)
//   static void initializeApi() {
//     ApiClient().initialize();
//   }

//   /// Example: Login using AuthService (recommended approach)
//   static Future<void> loginExample() async {
//     try {
//       final user = await AuthService.loginUser(
//         email: 'john.doe@kanzucodefoundation.org',
//         password: 'Xpass@123',
//         churchName: 'demo',
//       );

//       print('Login successful: ${user.name}');
//     } catch (e) {
//       print('Login failed: $e');
//     }
//   }

//   /// Example: Register using AuthService
//   static Future<void> registerExample() async {
//     try {
//       final success = await AuthService.registerUser(
//         firstName: 'John',
//         lastName: 'Doe',
//         email: 'john.new@example.com',
//         phone: '+256701234567',
//         gender: 'Male',
//         civilStatus: 'Single',
//         dateOfBirth: '1990-01-15',
//       );

//       if (success) {
//         print('Registration successful');
//       } else {
//         print('Registration failed');
//       }
//     } catch (e) {
//       print('Registration error: $e');
//     }
//   }

//   /// Example: Forgot password using AuthService
//   static Future<void> forgotPasswordExample() async {
//     try {
//       final success = await AuthService.forgotPassword('user@example.com');

//       if (success) {
//         print('Password reset email sent');
//       } else {
//         print('Failed to send password reset email');
//       }
//     } catch (e) {
//       print('Forgot password error: $e');
//     }
//   }

//   /// Example: Reset password using AuthService
//   static Future<void> resetPasswordExample() async {
//     try {
//       final success = await AuthService.resetPassword(
//         token: 'reset-token-from-email',
//         newPassword: 'NewPassword123!',
//         confirmPassword: 'NewPassword123!',
//       );

//       if (success) {
//         print('Password reset successful');
//       } else {
//         print('Password reset failed');
//       }
//     } catch (e) {
//       print('Password reset error: $e');
//     }
//   }

//   /// Example: Direct API usage (for advanced use cases)
//   static Future<void> directApiExample() async {
//     try {
//       final loginRequest = LoginRequest(
//         username: 'john.doe@kanzucodefoundation.org',
//         password: 'Xpass@123',
//         churchName: 'demo',
//       );

//       final response = await AuthApi.login(loginRequest);

//       if (response.success) {
//         print('Direct API login successful');
//         print('Token: ${response.token}');
//         print('User: ${response.user}');

//         // Set auth token for future requests
//         ApiClient().setAuthToken(response.token!);
//       }
//     } catch (e) {
//       if (e is ApiErrorResponse) {
//         print('API Error: ${e.message}');
//         print('Status Code: ${e.statusCode}');
//       } else {
//         print('Unexpected error: $e');
//       }
//     }
//   }

//   /// Example: Error handling patterns
//   static Future<void> errorHandlingExample() async {
//     try {
//       await AuthService.loginUser(
//         email: 'invalid@email.com',
//         password: 'wrongpassword',
//         churchName: 'demo',
//       );
//     } catch (e) {
//       // Handle different types of errors
//       if (e.toString().contains('Connection')) {
//         print('Network connection problem');
//       } else if (e.toString().contains('timeout')) {
//         print('Request timed out');
//       } else if (e.toString().contains('401')) {
//         print('Invalid credentials');
//       } else {
//         print('General error: $e');
//       }
//     }
//   }
// }

// /* 
// === USAGE IN YOUR PROVIDERS ===

// // In your AuthProvider, you can now use:

// import 'package:frontend/services/auth_service.dart';

// class AuthProvider extends ChangeNotifier {
//   Future<void> login(String email, String password, String churchName) async {
//     _status = AuthStatus.authenticating;
//     notifyListeners();

//     try {
//       _user = await AuthService.loginUser(
//         email: email,
//         password: password,
//         churchName: churchName,
//       );
//       _status = AuthStatus.authenticated;
//     } catch (e) {
//       _status = AuthStatus.failed;
//       _error = e.toString();
//     }
//     notifyListeners();
//   }

//   Future<void> register({
//     required String firstName,
//     required String lastName,
//     required String email,
//     required String phone,
//     required String gender,
//     required String civilStatus,
//     required String dateOfBirth,
//   }) async {
//     try {
//       final success = await AuthService.registerUser(
//         firstName: firstName,
//         lastName: lastName,
//         email: email,
//         phone: phone,
//         gender: gender,
//         civilStatus: civilStatus,
//         dateOfBirth: dateOfBirth,
//       );
      
//       if (!success) {
//         throw Exception('Registration failed');
//       }
//     } catch (e) {
//       throw Exception('Registration error: ${e.toString()}');
//     }
//   }
// }

// */
