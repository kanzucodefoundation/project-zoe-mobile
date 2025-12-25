import 'package:flutter/material.dart';
import '../models/contacts.dart';
import '../api/endpoints/contact_endpoints.dart';

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
      _error = 'Failed to load contacts: $e';
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

  /// Clear current contact details
  void clearContactDetails() {
    _currentContactDetails = null;
    notifyListeners();
  }

  /// Refresh contacts list
  Future<void> refreshContacts({String? churchName}) async {
    await loadContacts(churchName: churchName);
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
}
