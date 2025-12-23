// Login Models
class LoginRequest {
  final String username;
  final String password;
  final String churchName; // Required for server

  LoginRequest({
    required this.username,
    required this.password,
    this.churchName = 'worship harvest', // Default value from server docs
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'churchName': churchName,
    };
  }
}

class LoginResponse {
  final String? token;
  final String? message;
  final Map<String, dynamic>?
  data; // Changed from 'user' to 'data' to hold full response
  final bool success;

  LoginResponse({this.token, this.message, this.data, required this.success});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    // Check if we have the new response structure with token, user, hierarchy
    final hasToken = json['token'] != null;
    final hasUser = json['user'] != null;
    final hasHierarchy = json['hierarchy'] != null;

    // For new API structure, success means we have all required fields
    final isNewStructure = hasToken && hasUser && hasHierarchy;

    if (isNewStructure) {
      return LoginResponse(
        token: json['token'],
        message: null, // Success responses typically don't have error messages
        data: json, // Store entire response for AuthResponse parsing
        success: true,
      );
    }

    // Fallback to old structure or error handling
    return LoginResponse(
      token: json['token'],
      message: json['message'],
      data: json['user'] != null ? {'user': json['user']} : null,
      success: hasToken && json['user'] != null,
    );
  }
}

// Registration Models
class RegisterRequest {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String gender;
  final String civilStatus;
  final String dateOfBirth;
  final String churchName;

  RegisterRequest({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.gender,
    required this.civilStatus,
    required this.dateOfBirth,
    required this.churchName,
  });

  Map<String, dynamic> toJson() => {
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'phone': phone,
    'gender': gender,
    'civilStatus': civilStatus,
    'dateOfBirth': dateOfBirth,
    'churchName': churchName,
  };
}

class RegisterResponse {
  final String? message;
  final Map<String, dynamic>? user;
  final bool success;

  RegisterResponse({this.message, this.user, required this.success});

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    // Check for successful registration indicators
    final hasUser = json['user'] != null;
    final hasSuccessMessage =
        json['message'] != null &&
        !json['message'].toString().toLowerCase().contains('error');
    final hasExplicitSuccess = json['success'] == true;

    return RegisterResponse(
      message: json['message'],
      user: json['user'],
      success:
          hasExplicitSuccess ||
          hasUser ||
          (hasSuccessMessage &&
              json['statusCode'] != 400 &&
              json['statusCode'] != 500),
    );
  }
}

// Forgot Password Models
class ForgotPasswordRequest {
  final String email;

  ForgotPasswordRequest({required this.email});

  Map<String, dynamic> toJson() => {'email': email};
}

class ForgotPasswordResponse {
  final String message;
  final bool success;

  ForgotPasswordResponse({required this.message, required this.success});

  factory ForgotPasswordResponse.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordResponse(
      message: json['message'] ?? '',
      success: json['success'] ?? false,
    );
  }
}

// Reset Password Models
class ResetPasswordRequest {
  final String newPassword;
  final String confirmPassword;

  ResetPasswordRequest({
    required this.newPassword,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() => {
    'newPassword': newPassword,
    'confirmPassword': confirmPassword,
  };
}

class ResetPasswordResponse {
  final String message;
  final bool success;

  ResetPasswordResponse({required this.message, required this.success});

  factory ResetPasswordResponse.fromJson(Map<String, dynamic> json) {
    return ResetPasswordResponse(
      message: json['message'] ?? '',
      success: json['success'] ?? false,
    );
  }
}

// Generic API Error Response
class ApiErrorResponse {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? details;

  ApiErrorResponse({required this.message, this.statusCode, this.details});

  factory ApiErrorResponse.fromJson(Map<String, dynamic> json) {
    return ApiErrorResponse(
      message: json['message'] ?? 'An error occurred',
      statusCode: json['statusCode'],
      details: json['details'],
    );
  }
}
