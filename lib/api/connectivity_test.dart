import 'package:dio/dio.dart';
import 'base_url.dart';

/// Test connectivity to the API server
/// This is a utility class to verify that the staging server is accessible
class ConnectivityTest {
  static final Dio _dio = Dio();

  /// Test basic connectivity to the API server
  /// Returns true if server is accessible, false otherwise
  static Future<bool> testServerConnectivity() async {
    try {
      print('Testing connectivity to: ${BaseUrl.baseUrl}');

      final response = await _dio.get(
        '${BaseUrl.baseUrl}/health',
        options: Options(
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      print('Server responded with status: ${response.statusCode}');
      return response.statusCode == 200;
    } on DioException catch (e) {
      print('Connectivity test failed: ${e.message}');
      print('Error type: ${e.type}');

      if (e.response != null) {
        print('Response status: ${e.response?.statusCode}');
        print('Response data: ${e.response?.data}');
      }

      return false;
    } catch (e) {
      print('Unexpected error during connectivity test: $e');
      return false;
    }
  }

  /// Test API base URL connectivity
  /// Returns true if API endpoints are accessible, false otherwise
  static Future<bool> testApiConnectivity() async {
    try {
      print('Testing API connectivity to: ${BaseUrl.apiUrl}');

      final response = await _dio.get(
        '${BaseUrl.apiUrl}/health',
        options: Options(
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      print('API responded with status: ${response.statusCode}');
      return response.statusCode == 200;
    } on DioException catch (e) {
      print('API connectivity test failed: ${e.message}');
      print('Error type: ${e.type}');

      if (e.response != null) {
        print('Response status: ${e.response?.statusCode}');
        print('Response data: ${e.response?.data}');
      }

      return false;
    } catch (e) {
      print('Unexpected error during API connectivity test: $e');
      return false;
    }
  }

  /// Run all connectivity tests
  /// Prints results and returns overall connectivity status
  static Future<bool> runAllTests() async {
    print('=== API Connectivity Tests ===');
    print('Environment: Production (staging server)');
    print('Base URL: ${BaseUrl.baseUrl}');
    print('API URL: ${BaseUrl.apiUrl}');
    print('');

    bool serverConnected = await testServerConnectivity();
    print('Server connectivity: ${serverConnected ? "✓ PASS" : "✗ FAIL"}');

    bool apiConnected = await testApiConnectivity();
    print('API connectivity: ${apiConnected ? "✓ PASS" : "✗ FAIL"}');

    bool overallSuccess = serverConnected && apiConnected;
    print('');
    print(
      'Overall result: ${overallSuccess ? "✓ ALL TESTS PASSED" : "✗ SOME TESTS FAILED"}',
    );

    return overallSuccess;
  }
}
