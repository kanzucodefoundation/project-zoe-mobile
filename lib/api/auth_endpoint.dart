import 'package:dio/dio.dart';
import 'api_client.dart';
import 'endpoints/auth_endpoints.dart';
import 'api_models.dart';

class AuthApi {
  static final ApiClient _apiClient = ApiClient();
  static Dio get _dio => _apiClient.dio;

  /// Login user
  ///
  /// Takes [LoginRequest] and returns [LoginResponse]
  /// Throws [DioException] on network or server errors
  static Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await _dio.post(
        AuthEndpoints.login,
        data: request.toJson(),
      );

      return LoginResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ApiErrorResponse(
        message: 'Unexpected error occurred during login',
        details: {'error': e.toString()},
      );
    }
  }

  /// Register new user
  ///
  /// Takes [RegisterRequest] and returns [RegisterResponse]
  /// Throws [DioException] on network or server errors
  static Future<RegisterResponse> register(RegisterRequest request) async {
    try {
      final response = await _dio.post(
        AuthEndpoints.register,
        data: request.toJson(),
      );

      return RegisterResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ApiErrorResponse(
        message: 'Unexpected error occurred during registration',
        details: {'error': e.toString()},
      );
    }
  }

  /// Request password reset
  ///
  /// Takes [ForgotPasswordRequest] and returns [ForgotPasswordResponse]
  /// Throws [DioException] on network or server errors
  static Future<ForgotPasswordResponse> forgotPassword(
    ForgotPasswordRequest request,
  ) async {
    try {
      final response = await _dio.post(
        AuthEndpoints.forgotPassword,
        data: request.toJson(),
      );

      return ForgotPasswordResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ApiErrorResponse(
        message: 'Unexpected error occurred during password reset request',
        details: {'error': e.toString()},
      );
    }
  }

  /// Reset password with token
  ///
  /// Takes [ResetPasswordRequest] and [token] returns [ResetPasswordResponse]
  /// Throws [DioException] on network or server errors
  static Future<ResetPasswordResponse> resetPassword(
    String token,
    ResetPasswordRequest request,
  ) async {
    try {
      final response = await _dio.put(
        AuthEndpoints.resetPasswordWithToken(token),
        data: request.toJson(),
      );

      return ResetPasswordResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ApiErrorResponse(
        message: 'Unexpected error occurred during password reset',
        details: {'error': e.toString()},
      );
    }
  }

  /// Handle Dio exceptions and convert to ApiErrorResponse
  static ApiErrorResponse _handleDioException(DioException e) {
    String message;
    int? statusCode = e.response?.statusCode;
    Map<String, dynamic>? details = e.response?.data;

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        message = 'Connection timeout - server is not responding.';
        break;
      case DioExceptionType.sendTimeout:
        message = 'Request timeout. Please try again.';
        break;
      case DioExceptionType.receiveTimeout:
        message = 'Response timeout. Please try again.';
        break;
      case DioExceptionType.badResponse:
        message = e.response?.data['message'] ?? 'Server error occurred';
        break;
      case DioExceptionType.cancel:
        message = 'Request was cancelled';
        break;
      case DioExceptionType.connectionError:
        message = 'Server unavailable - unable to connect.';
        break;
      default:
        message = 'Network error occurred';
    }

    return ApiErrorResponse(
      message: message,
      statusCode: statusCode,
      details: details,
    );
  }
}
