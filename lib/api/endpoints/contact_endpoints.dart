import 'package:dio/dio.dart';
import '../api_client.dart';
import '../../models/contacts.dart';

class ContactEndpoints {
  static final ApiClient _apiClient = ApiClient();

  /// Get all contacts from CRM
  /// Endpoint: GET /api/crm/contacts
  static Future<List<Contact>> getAllContacts({String? churchName}) async {
    try {
      // Comment out debug prints for production
      // print('📞 API: Fetching contacts from /crm/contacts');
      // print('📞 API: Church: ${churchName ?? 'fellowship'}');

      final response = await _apiClient.dio.get(
        '/crm/contacts',
        options: Options(
          headers: {'X-Church-Name': churchName ?? 'fellowship'},
        ),
      );

      // Comment out debug print for production
      // print('📞 API: Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = response.data;
        // Comment out debug print for production
        // print('📞 API: Response data type: ${responseData.runtimeType}');

        List<dynamic> contactsJson;

        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('contacts')) {
          contactsJson = responseData['contacts'] as List<dynamic>;
          // Comment out debug print for production
          // print('📞 API: Found ${contactsJson.length} contacts in response');
        } else if (responseData is List<dynamic>) {
          contactsJson = responseData;
          // Comment out debug print for production
          // print(
          //   '📞 API: Direct array response with ${contactsJson.length} contacts',
          // );
        } else {
          throw Exception('Unexpected response format: $responseData');
        }

        return contactsJson.map((json) {
          // Comment out debug print for production
          // print(
          //   '📞 API: Processing contact ${json['id']} with avatar: ${json['avatar']}',
          // );
          return Contact.fromJson(json);
        }).toList();
      } else {
        throw Exception('Failed to load contacts: ${response.statusCode}');
      }
    } catch (e) {
      // Comment out debug print for production
      // print('📞 API: Error fetching contacts: $e');
      rethrow;
    }
  }

  /// Get contact details by ID
  /// Endpoint: GET /api/crm/contacts/{id}
  static Future<ContactDetails> getContactDetails(
    int contactId, {
    String? churchName,
  }) async {
    try {
      // Comment out debug prints for production
      // print('📞 API: Fetching contact details for ID: $contactId');
      // print('📞 API: Church: ${churchName ?? 'fellowship'}');

      final response = await _apiClient.dio.get(
        '/crm/contacts/$contactId',
        options: Options(
          headers: {'X-Church-Name': churchName ?? 'fellowship'},
        ),
      );

      // Comment out debug print for production
      // print('📞 API: Contact details response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = response.data;
        // Comment out debug print for production
        // print('📞 API: Contact details data: $responseData');
        return ContactDetails.fromJson(responseData);
      } else {
        throw Exception(
          'Failed to load contact details: ${response.statusCode}',
        );
      }
    } catch (e) {
      // Comment out debug print for production
      // print('📞 API: Error fetching contact details: $e');
      rethrow;
    }
  }
}
