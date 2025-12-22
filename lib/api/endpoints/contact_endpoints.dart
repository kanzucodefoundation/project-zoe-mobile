import 'package:dio/dio.dart';
import '../api_client.dart';
import '../../models/people.dart';

class ContactEndpoints {
  static final ApiClient _apiClient = ApiClient();

  // Make the API client accessible for debugging
  static ApiClient get apiClient => _apiClient;

  /// Get all contacts from CRM
  /// Endpoint: GET /api/crm/contacts
  static Future<List<Contact>> getAllContacts() async {
    try {
      print('API: Fetching all contacts from /api/crm/contacts');

      final response = await _apiClient.dio.get(
        '/crm/contacts',
        options: Options(
          headers: {
            'X-Church-Name': 'demo', // Temporarily hard-code church name
          },
        ),
      );

      if (response.statusCode == 200) {
        print('API: Successfully fetched ${response.data.length} contacts');
        print(
          'API: First contact structure: ${response.data.isNotEmpty ? response.data[0] : "No contacts"}',
        );
        final List<dynamic> contactsJson = response.data;
        return contactsJson.map((json) => Contact.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load contacts: ${response.statusCode}');
      }
    } catch (e) {
      print('API ERROR: Error fetching contacts - $e');
      rethrow;
    }
  }

  /// Get contact details by ID
  /// Endpoint: GET /api/crm/contacts/{id}
  static Future<ContactDetails> getContactDetails(int contactId) async {
    try {
      print('API: Fetching contact details for ID: $contactId');

      final response = await _apiClient.dio.get(
        '/crm/contacts/$contactId',
        options: Options(
          headers: {
            'X-Church-Name': 'demo', // Temporarily hard-code church name
          },
        ),
      );

      if (response.statusCode == 200) {
        print('API: Successfully fetched contact details for ID: $contactId');
        print('API: Contact details structure: ${response.data}');
        return ContactDetails.fromJson(response.data);
      } else {
        throw Exception(
          'Failed to load contact details: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('API ERROR: Error fetching contact details for ID $contactId - $e');
      rethrow;
    }
  }

  /// Create a new contact
  /// Endpoint: POST /api/crm/contacts
  static Future<Contact> createContact(Map<String, dynamic> contactData) async {
    try {
      print('API: Creating new contact');

      final response = await _apiClient.dio.post(
        '/crm/contacts',
        data: contactData,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('API: Successfully created new contact');
        return Contact.fromJson(response.data);
      } else {
        throw Exception('Failed to create contact: ${response.statusCode}');
      }
    } catch (e) {
      print('API ERROR: Error creating contact - $e');
      rethrow;
    }
  }

  /// Update a contact
  /// Endpoint: PUT /api/crm/contacts/{id}
  static Future<Contact> updateContact(
    int contactId,
    Map<String, dynamic> contactData,
  ) async {
    try {
      print('API: Updating contact with ID: $contactId');

      final response = await _apiClient.dio.put(
        '/crm/contacts/$contactId',
        data: contactData,
      );

      if (response.statusCode == 200) {
        print('API: Successfully updated contact with ID: $contactId');
        return Contact.fromJson(response.data);
      } else {
        throw Exception('Failed to update contact: ${response.statusCode}');
      }
    } catch (e) {
      print('API ERROR: Error updating contact ID $contactId - $e');
      rethrow;
    }
  }

  /// Delete a contact
  /// Endpoint: DELETE /api/crm/contacts/{id}
  static Future<void> deleteContact(int contactId) async {
    try {
      print('API: Deleting contact with ID: $contactId');

      final response = await _apiClient.dio.delete('/crm/contacts/$contactId');

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('API: Successfully deleted contact with ID: $contactId');
      } else {
        throw Exception('Failed to delete contact: ${response.statusCode}');
      }
    } catch (e) {
      print('API ERROR: Error deleting contact ID $contactId - $e');
      rethrow;
    }
  }
}
