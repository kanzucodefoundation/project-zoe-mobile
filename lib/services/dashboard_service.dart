import 'package:dio/dio.dart';
import '../api/api_client.dart';
import '../models/dashboard_summary.dart';

class DashboardService {
  static final ApiClient _apiClient = ApiClient();
  static Dio get _dio => _apiClient.dio;

  /// Get dashboard summary from /dashboard/summary endpoint
  static Future<DashboardSummary> getDashboardSummary() async {
    try {
      final response = await _dio.get('/dashboard/summary');

      return DashboardSummary.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Failed to fetch dashboard summary: ${e.toString()}');
    }
  }

  static Exception _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Connection timeout - server is not responding.');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = e.response?.data?['message'] ?? 'Server error';
        return Exception('Server error ($statusCode): $message');
      case DioExceptionType.connectionError:
        return Exception('Server unavailable - unable to connect.');
      case DioExceptionType.cancel:
        return Exception('Request was cancelled');
      default:
        return Exception('An unexpected error occurred: ${e.message}');
    }
  }
}
