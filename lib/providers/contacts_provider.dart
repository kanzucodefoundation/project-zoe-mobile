import 'package:flutter/material.dart';
import '../models/contacts.dart';
import '../models/contact_form_field.dart';
import '../api/endpoints/contact_endpoints.dart';
import '../api/base_url.dart';

class ContactsProvider with ChangeNotifier {
  List<Contact> _contacts = [];
  ContactDetails? _currentContactDetails;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Contact> get contacts => _contacts;
  ContactDetails? get currentContactDetails => _currentContactDetails;
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
      _error = _getCleanErrorMessage(e, 'Failed to load contacts');
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
      _error = _getCleanErrorMessage(e, 'Failed to load contact details');
      _currentContactDetails = null;
    } finally {
      _setLoading(false);
    }
  }

  /// Clear current contact details
  void clearContactDetails() {
    _currentContactDetails = null;
    _safeNotifyListeners();
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

      _safeNotifyListeners();
      return newContact;
    } catch (e) {
      // Comment out debug print for production
      print('👥 ContactsProvider: Error creating contact: $e');
      _error = _getCleanErrorMessage(e, 'Failed to create contact');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Private helper to set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    _safeNotifyListeners();
  }

  /// Safe notify listeners to avoid build during frame issues
  void _safeNotifyListeners() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  /// Clear error
  void clearError() {
    _error = null;
    _safeNotifyListeners();
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
      _safeNotifyListeners();
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
      _error = _getCleanErrorMessage(e, 'Failed to update contact');
      _setLoading(false);
      return null;
    }
  }

  /// Convert technical error messages to user-friendly ones
  String _getCleanErrorMessage(dynamic error, String defaultMessage) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('connection refused') ||
        errorString.contains('connection error')) {
      return 'Server is unavailable. Please try again later.';
    } else if (errorString.contains('timeout')) {
      return 'Request timed out. Please check your connection and try again.';
    } else if (errorString.contains('host not found') ||
        errorString.contains('network unreachable')) {
      return 'No internet connection. Please check your network settings.';
    } else if (errorString.contains('404') ||
        errorString.contains('not found')) {
      return 'Resource not found. Please contact support.';
    } else if (errorString.contains('500') ||
        errorString.contains('server error')) {
      return 'Server error. Please try again later.';
    } else if (errorString.contains('empty reply') ||
        errorString.contains('connection closed') ||
        errorString.contains('no data received')) {
      return 'Server did not respond. This feature may not be implemented yet.';
    }

    return defaultMessage;
  }
}
