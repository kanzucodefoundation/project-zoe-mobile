import 'package:flutter/material.dart';
import 'package:project_zoe/models/user.dart';
import 'package:project_zoe/models/user_details.dart';
import '../models/contacts.dart';
import '../models/contact_form_field.dart';
import '../api/endpoints/contact_endpoints.dart';

class ContactsProvider with ChangeNotifier {
  List<Contact> _contacts = [];
  List<User> _users = [];
  ContactDetails? _currentContactDetails;
  UserDetails? _currentUserDetails;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Contact> get contacts => _contacts;
  List<User> get users => _users;
  ContactDetails? get currentContactDetails => _currentContactDetails;
  UserDetails? get currentUserDetails => _currentUserDetails;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load all contacts from the API
  Future<void> loadContacts({String? churchName}) async {
    // Comment out debug print for production
    // print('👥 ContactsProvider: Loading contacts...');
    _setLoading(true);
    _error = null;

    try {
      final fetchedContacts = await ContactEndpoints.getAllContacts(
        churchName: churchName ?? 'fellowship',
      );

      _contacts = fetchedContacts;
      // Comment out debug print for production
      // print('👥 ContactsProvider: Loaded ${_contacts.length} contacts');

      // Comment out debug prints for production
      // if (_contacts.isNotEmpty) {
      //   print(
      //     '👥 ContactsProvider: First contact avatar: ${_contacts.first.avatar}',
      //   );
      // }
    } catch (e) {
      // Comment out debug print for production
      // print('👥 ContactsProvider: Error loading contacts: $e');
      
      // Provide better error messages for common issues
      if (e.toString().contains('401')) {
        _error = 'Access Denied: You need CRM_VIEW permission to view contacts. Please contact your administrator to grant you access to the member directory.';
      } else if (e.toString().contains('403')) {
        _error = 'Forbidden: You do not have permission to view the member directory.';
      } else if (e.toString().contains('404')) {
        _error = 'Member directory not found. Please check your connection.';
      } else {
        _error = 'Failed to load contacts: $e';
      }
      _contacts = [];
    } finally {
      _setLoading(false);
    }
  }

  /// Load all contacts from the API
  Future<void> loadUsers() async {
    // Comment out debug print for production
    _setLoading(true);
    _error = null;

    try {
      final fetched = await ContactEndpoints.getAllUsers();

      // Comment out debug prints for production
      if (fetched.isNotEmpty) {
        _users = fetched;
        // Comment out debug print for production
        // print('👥 ContactsProvider: Loaded ${_users.length} contacts');
      }
    } catch (e) {
      // Comment out debug print for production
      // print('👥 ContactsProvider: Error loading contacts: $e');
      _error = 'Failed to load users: $e';
      _contacts = [];
    } finally {
      _setLoading(false);
    }
  }

  /// Load specific contact details
  Future<void> loadContactDetails(int contactId, {String? churchName}) async {
    // Comment out debug print for production
    // print('👤 ContactsProvider: Loading details for contact $contactId');
    _setLoading(true);
    _error = null;

    try {
      final details = await ContactEndpoints.getContactDetails(
        contactId,
        churchName: churchName ?? 'fellowship',
      );

      _currentContactDetails = details;
      // Comment out debug prints for production
      // print(
      //   '👤 ContactsProvider: Loaded details for ${details.person.firstName} ${details.person.lastName}',
      // );
      // print('👤 ContactsProvider: Avatar: ${details.person.avatar}');
    } catch (e) {
      // Comment out debug print for production
      // print('👤 ContactsProvider: Error loading contact details: $e');
      _error = 'Failed to load contact details: $e';
      _currentContactDetails = null;
    } finally {
      _setLoading(false);
    }
  }

  /// Load specific contact details
  Future<void> loadUserDetails(int contactId, {String? churchName}) async {
    // Comment out debug print for production
    // print('👤 ContactsProvider: Loading details for contact $contactId');
    _setLoading(true);
    _error = null;

    try {
      final details = await ContactEndpoints.getUserDetails(contactId);

      _currentUserDetails = details;
    } catch (e) {
      _error = 'Failed to load user details: $e';
      _currentContactDetails = null;
    } finally {
      _setLoading(false);
    }
  }

  /// Clear current contact details
  void clearContactDetails() {
    _currentContactDetails = null;
    notifyListeners();
  }

  /// Refresh contacts list
  Future<void> refreshContacts({String? churchName}) async {
    await loadContacts(churchName: churchName);
  }

  /// Create a new contact
  Future<Contact?> createContact(
    Map<String, dynamic> contactData, {
    String? churchName,
  }) async {
    // Comment out debug print for production
    // print('👥 ContactsProvider: Creating new contact...');
    _setLoading(true);
    _error = null;

    try {
      final newContact = await ContactEndpoints.createContact(
        contactData,
        churchName: churchName ?? 'fellowship',
      );

      // Add the new contact to the list
      _contacts.add(newContact);
      // Comment out debug print for production
      // print('👥 ContactsProvider: Successfully created contact ${newContact.firstName} ${newContact.lastName}');

      notifyListeners();
      return newContact;
    } catch (e) {
      // Comment out debug print for production
      // print('👥 ContactsProvider: Error creating contact: $e');
      _error = 'Failed to create contact: $e';
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Private helper to set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Get contact form fields from server
  Future<List<ContactFormField>> getContactFormFields({
    String? churchName,
  }) async {
    // Comment out debug print for production
    // print('👥 ContactsProvider: Loading contact form fields...');

    try {
      final fields = await ContactEndpoints.getContactFormFields(
        churchName: churchName ?? 'fellowship',
      );

      // Comment out debug print for production
      // print('👥 ContactsProvider: Loaded ${fields.length} form fields');
      return fields;
    } catch (e) {
      // Comment out debug print for production
      // print('👥 ContactsProvider: Error loading form fields: $e');
      _error = 'Failed to load form fields: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// Update an existing contact
  Future<Contact?> updateContact(
    int contactId,
    Map<String, dynamic> contactData, {
    String? churchName,
  }) async {
    // Comment out debug print for production
    // print('👥 ContactsProvider: Updating contact $contactId...');
    _setLoading(true);
    _error = null;

    try {
      final updatedContact = await ContactEndpoints.updateContact(
        contactId,
        contactData,
        churchName: churchName ?? 'fellowship',
      );

      // Update local list
      final index = _contacts.indexWhere((c) => c.id == contactId);
      if (index != -1) {
        _contacts[index] = updatedContact;
      }

      // Comment out debug print for production
      // print('👥 ContactsProvider: Contact updated successfully: ${updatedContact.firstName} ${updatedContact.lastName}');

      _setLoading(false);
      return updatedContact;
    } catch (e) {
      // Comment out debug print for production
      // print('👥 ContactsProvider: Error updating contact: $e');
      _error = 'Failed to update contact: $e';
      _setLoading(false);
      return null;
    }
  }
}
