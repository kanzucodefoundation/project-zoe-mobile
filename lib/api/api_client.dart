import 'package:dio/dio.dart';
import 'base_url.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  late final Dio _dio;

  Dio get dio => _dio;

  void initialize() {
    _dio = Dio(
      BaseOptions(
        baseUrl: BaseUrl.apiUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors for logging and error handling
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        request: true,
        requestHeader: true,
        responseHeader: true,
      ),
    );

    // Add error handling interceptor with detailed logging
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print('API REQUEST: ${options.method} ${options.uri}');
          // print('API HEADERS: ${options.headers}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          // print(
          //   'API RESPONSE: ${response.statusCode} ${response.statusMessage}',
          // );
          handler.next(response);
        },
        onError: (error, handler) {
          print('API ERROR: ${error.message}');
          print('API ERROR TYPE: ${error.type}');
          if (error.response != null) {
            print(
              'API ERROR RESPONSE: ${error.response?.statusCode} ${error.response?.data}',
            );
          }
          handler.next(error);
        },
      ),
    );
  }

  // Add authorization token to headers
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  // Remove authorization token
  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  // Set tenant header for multi-tenant support
  void setTenant(String churchName) {
    _dio.options.headers['X-Church-Name'] = churchName;
  }

  // Remove tenant header
  void clearTenant() {
    _dio.options.headers.remove('X-Church-Name');
  }
}
