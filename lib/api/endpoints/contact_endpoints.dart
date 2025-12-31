import '../api_client.dart';
import '../../models/contacts.dart';
import '../../models/contact_form_field.dart';

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
        // options: Options(
        //   headers: {'X-Church-Name': churchName ?? 'fellowship'},
        // ),
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
        // options: Options(
        //   headers: {'X-Church-Name': churchName ?? 'fellowship'},
        // ),
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

  /// Create a new contact
  /// Endpoint: POST /api/crm/contacts
  static Future<Contact> createContact(
    Map<String, dynamic> contactData, {
    String? churchName,
  }) async {
    try {
      // Comment out debug prints for production
      // print('📞 API: Creating new contact');
      // print('📞 API: Data: $contactData');
      // print('📞 API: Church: ${churchName ?? 'fellowship'}');

      final response = await _apiClient.dio.post(
        '/crm/contacts',
        data: contactData,
        // options: Options(
        //   headers: {'X-Church-Name': churchName ?? 'fellowship'},
        // ),
      );

      // Comment out debug print for production
      // print('📞 API: Create contact response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;
        // Comment out debug print for production
        // print('📞 API: Created contact data: $responseData');
        return Contact.fromJson(responseData);
      } else {
        throw Exception('Failed to create contact: ${response.statusCode}');
      }
    } catch (e) {
      // Comment out debug print for production
      print('📞 API: Error creating contact: $e');

      // Handle specific DioExceptions for better error messages
      if (e.toString().contains(
            'Connection closed before full header was received',
          ) ||
          e.toString().contains('Empty reply from server')) {
        throw Exception(
          'Empty reply from server - The POST /crm/contacts endpoint is not implemented on the mock server',
        );
      }
      rethrow;
    }
  }

  /// Get contact form fields configuration
  /// Endpoint: GET /api/crm/contacts/form-fields
  static Future<List<ContactFormField>> getContactFormFields({
    String? churchName,
  }) async {
    try {
      // Comment out debug prints for production
      // print('📋 API: Fetching contact form fields');
      // print('📋 API: Church: ${churchName ?? 'fellowship'}');

      final response = await _apiClient.dio.get(
        '/crm/contacts/form-fields',
        // options: Options(
        //   headers: {'X-Church-Name': churchName ?? 'fellowship'},
        // ),
      );

      // Comment out debug print for production
      // print('📋 API: Form fields response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = response.data;

        // Handle different response formats
        List<dynamic> fieldsJson;
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('fields')) {
          fieldsJson = responseData['fields'] as List<dynamic>;
        } else if (responseData is List<dynamic>) {
          fieldsJson = responseData;
        } else {
          // Fallback to default fields if server doesn't provide them
          fieldsJson = _getDefaultContactFields();
        }

        // Comment out debug print for production
        // print('📋 API: Found ${fieldsJson.length} form fields');

        return fieldsJson
            .map((json) => ContactFormField.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load form fields: ${response.statusCode}');
      }
    } catch (e) {
      // Comment out debug print for production
      // print('📋 API: Error fetching form fields, using defaults: $e');

      // Return default fields on error
      return _getDefaultContactFields()
          .map((json) => ContactFormField.fromJson(json))
          .toList();
    }
  }

  /// Update an existing contact
  /// Endpoint: PUT /api/crm/contacts/{id}
  static Future<Contact> updateContact(
    int contactId,
    Map<String, dynamic> contactData, {
    String? churchName,
  }) async {
    try {
      // Comment out debug prints for production
      // print('📞 API: Updating contact $contactId');
      // print('📞 API: Data: $contactData');
      // print('📞 API: Church: ${churchName ?? 'fellowship'}');

      final response = await _apiClient.dio.put(
        '/crm/contacts/$contactId',
        data: contactData,
        // options: Options(
        //   headers: {'X-Church-Name': churchName ?? 'fellowship'},
        // ),
      );

      // Comment out debug print for production
      // print('📞 API: Update contact response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = response.data;
        // Comment out debug print for production
        // print('📞 API: Updated contact data: $responseData');
        return Contact.fromJson(responseData);
      } else {
        throw Exception('Failed to update contact: ${response.statusCode}');
      }
    } catch (e) {
      // Comment out debug print for production
      // print('📞 API: Error updating contact: $e');
      rethrow;
    }
  }

  /// Default contact form fields (fallback)
  static List<Map<String, dynamic>> _getDefaultContactFields() {
    return [
      {
        'name': 'firstName',
        'label': 'First Name',
        'type': 'text',
        'required': true,
        'placeholder': 'Enter first name',
      },
      {
        'name': 'lastName',
        'label': 'Last Name',
        'type': 'text',
        'required': true,
        'placeholder': 'Enter last name',
      },
      {
        'name': 'email',
        'label': 'Email Address',
        'type': 'email',
        'required': false,
        'placeholder': 'Enter email address',
      },
      {
        'name': 'phone',
        'label': 'Phone Number',
        'type': 'phone',
        'required': false,
        'placeholder': 'Enter phone number',
      },
      {
        'name': 'gender',
        'label': 'Gender',
        'type': 'dropdown',
        'required': false,
        'options': ['Male', 'Female', 'Other'],
      },
      {
        'name': 'ageGroup',
        'label': 'Age Group',
        'type': 'dropdown',
        'required': false,
        'options': ['Child', 'Youth', 'Young Adult', 'Adult', 'Senior'],
      },
    ];
  }
}
