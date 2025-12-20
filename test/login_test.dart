import 'package:flutter_test/flutter_test.dart';
import 'package:project_zoe/api/api_client.dart';
import 'package:project_zoe/api/login_endpoint.dart';
import 'package:project_zoe/api/api_models.dart';

void main() {
  group('Login API Tests', () {
    setUpAll(() {
      ApiClient().initialize();
    });

    test('Test login API call', () async {
      final request = LoginRequest(
        username: 'jane.doe@kanzucodefoundation.org',
        password: 'Password@1',
        churchName: 'demo',
      );

      try {
        final response = await AuthApi.login(request);
        print('Login successful: ${response.success}');
        print('Token received: ${response.token != null}');
        print('User data: ${response.user}');
        expect(response.success, isTrue);
        expect(response.token, isNotNull);
      } catch (e) {
        print('Login error: $e');
        print('Error type: ${e.runtimeType}');
        rethrow;
      }
    });
  });
}
