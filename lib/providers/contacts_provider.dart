import 'package:flutter/material.dart';
import '../models/people.dart';
import '../api/endpoints/contact_endpoints.dart';
import '../providers/auth_provider.dart';

class ContactsProvider extends ChangeNotifier {
  // Form management
  final formKey = GlobalKey<FormState>();

  // Form controllers
  final salutationController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final middleNameController = TextEditingController();
  final ageGroupController = TextEditingController();
  final placeOfWorkController = TextEditingController();
  final genderController = TextEditingController();
  final civilStatusController = TextEditingController();
  final avatarController = TextEditingController();
  final dateOfBirthController = TextEditingController();
  final contactIdController = TextEditingController();

  // Contact list management
  List<Contact> _contacts = [];
  List<Contact> get contacts => _contacts;

  // For backward compatibility with shepherds naming
  List<Contact> get shepherds => _contacts;

  // Contact details for individual contact view
  ContactDetails? _currentContactDetails;
  ContactDetails? get currentContactDetails => _currentContactDetails;

  // Loading states
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingShepherds = false;
  bool get isLoadingShepherds => _isLoadingShepherds;

  // Edit mode state
  bool _isEditMode = false;
  bool get isEditMode => _isEditMode;

  int? _editingShepherdId;
  int? get editingShepherdId => _editingShepherdId;

  // Initialize and load contacts
  ContactsProvider() {
    _initializeContacts();
  }

  Future<void> _initializeContacts() async {
    await loadContacts();
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Validation methods
  String? validateName(String? value) {
    if (value == null || value.isEmpty) return 'Please enter name';
    if (value.length < 2) return 'Name must be at least 2 characters';
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Please enter email address';
    if (!value.contains('@') || !value.contains('.')) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'Please enter phone number';
    if (value.length < 10) return 'Please enter a valid phone number';
    return null;
  }

  String? validateChurchLocation(String? value) {
    if (value == null || value.isEmpty) return 'Please enter church location';
    return null;
  }

  String? validatePosition(String? value) {
    if (value == null || value.isEmpty) return 'Please enter position';
    return null;
  }

  String? validateYearsOfService(String? value) {
    if (value == null || value.isEmpty) return 'Please enter years of service';
    final years = int.tryParse(value);
    if (years == null || years < 0) {
      return 'Please enter a valid number of years';
    }
    return null;
  }

  String? validateEmergencyPhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter emergency contact phone';
    }
    if (value.length < 10) return 'Please enter a valid emergency phone number';
    return null;
  }

  // Clear all fields
  void clear() {
    salutationController.clear();
    firstNameController.clear();
    lastNameController.clear();
    middleNameController.clear();
    ageGroupController.clear();
    placeOfWorkController.clear();
    genderController.clear();
    civilStatusController.clear();
    avatarController.clear();
    dateOfBirthController.clear();
    contactIdController.clear();

    _isEditMode = false;
    _editingShepherdId = null;
    _currentContactDetails = null;
    notifyListeners();
  }

  // Load shepherd data for editing (backward compatibility)
  void loadShepherdForEdit(Contact contact) {
    firstNameController.text = contact.name; // Using name as firstName for now
    lastNameController.text =
        ''; // We'll need to parse this from name or get from API
    ageGroupController.text = contact.ageGroup ?? '';
    avatarController.text = contact.avatar;
    dateOfBirthController.text = contact.dateOfBirth;

    _isEditMode = true;
    _editingShepherdId = contact.id;
    notifyListeners();
  }

  // Dispose controllers
  @override
  void dispose() {
    salutationController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    middleNameController.dispose();
    ageGroupController.dispose();
    placeOfWorkController.dispose();
    genderController.dispose();
    civilStatusController.dispose();
    avatarController.dispose();
    dateOfBirthController.dispose();
    contactIdController.dispose();
    super.dispose();
  }

  // Form submission logic
  Future<bool> submit() async {
    if (!formKey.currentState!.validate()) return false;

    setLoading(true);
    try {
      if (_isEditMode) {
        return await _updateContact();
      } else {
        return await _createContact();
      }
    } catch (e) {
      print('PeopleProvider ERROR: Form submission failed - $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Create new contact from form
  Future<bool> _createContact() async {
    final contactData = {
      'name': '${firstNameController.text} ${lastNameController.text}'.trim(),
      'email':
          lastNameController.text, // Using last name field as email for now
      'phone':
          ageGroupController.text, // Using age group field as phone for now
      'avatar': avatarController.text.isEmpty
          ? 'https://gravatar.com/avatar/default?s=200&d=retro'
          : avatarController.text,
      'dateOfBirth': dateOfBirthController.text,
      'ageGroup': null,
      'cellGroup': null,
      'location': placeOfWorkController.text,
    };

    try {
      final success = await createContact(contactData);
      if (success) {
        clear();
        await loadContacts(); // Refresh the list
      }
      return success;
    } catch (e) {
      print('PeopleProvider ERROR: Create contact failed - $e');
      return false;
    }
  }

  // Update existing contact from form
  Future<bool> _updateContact() async {
    if (_editingShepherdId == null) return false;

    final contactData = {
      'name': '${firstNameController.text} ${lastNameController.text}'.trim(),
      'email': lastNameController.text,
      'phone': ageGroupController.text,
      'avatar': avatarController.text.isEmpty
          ? 'https://gravatar.com/avatar/default?s=200&d=retro'
          : avatarController.text,
      'dateOfBirth': dateOfBirthController.text,
      'ageGroup': null,
      'cellGroup': null,
      'location': placeOfWorkController.text,
    };

    try {
      final success = await updateContact(_editingShepherdId!, contactData);
      if (success) {
        clear();
        await loadContacts(); // Refresh the list
      }
      return success;
    } catch (e) {
      print('PeopleProvider ERROR: Update contact failed - $e');
      return false;
    }
  }

  /// Load all contacts from CRM API
  Future<void> loadContacts({String? churchName}) async {
    _isLoadingShepherds = true;
    notifyListeners();

    try {
      print('PeopleProvider: Loading contacts from API');
      print('PeopleProvider: Using church name: ${churchName ?? 'fellowship'}');
      print(
        'PeopleProvider: API Base URL: ${ContactEndpoints.apiClient.dio.options.baseUrl}',
      );
      print(
        'PeopleProvider: API Headers: ${ContactEndpoints.apiClient.dio.options.headers}',
      );

      _contacts = await ContactEndpoints.getAllContacts(churchName: churchName);
      print('PeopleProvider: Successfully loaded ${_contacts.length} contacts');
    } catch (e) {
      print('PeopleProvider ERROR: Failed to load contacts - $e');
      print('PeopleProvider ERROR: Error type: ${e.runtimeType}');

      // Handle error - you could show a snackbar or set an error state
      _contacts = [];
    } finally {
      _isLoadingShepherds = false;
      notifyListeners();
    }
  }

  /// For backward compatibility with the existing loadShepherds method
  Future<void> loadShepherds() async {
    await loadContacts();
  }

  /// Load detailed information for a specific contact
  Future<ContactDetails?> loadContactDetails(int contactId) async {
    setLoading(true);

    try {
      print('PeopleProvider: Loading contact details for ID: $contactId');
      _currentContactDetails = await ContactEndpoints.getContactDetails(
        contactId,
      );
      print('PeopleProvider: Successfully loaded contact details');
      return _currentContactDetails;
    } catch (e) {
      print('PeopleProvider ERROR: Failed to load contact details - $e');
      _currentContactDetails = null;
      return null;
    } finally {
      setLoading(false);
      notifyListeners();
    }
  }

  /// Get contact by ID (for backward compatibility)
  Contact? getShepherdById(int id) {
    try {
      return _contacts.firstWhere((contact) => contact.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get contact by ID
  Contact? getContactById(int id) {
    return getShepherdById(id);
  }

  /// Create a new contact
  Future<bool> createContact(Map<String, dynamic> contactData) async {
    setLoading(true);

    try {
      print('PeopleProvider: Creating new contact');
      final newContact = await ContactEndpoints.createContact(contactData);
      _contacts.add(newContact);
      notifyListeners();
      print('PeopleProvider: Successfully created new contact');
      return true;
    } catch (e) {
      print('PeopleProvider ERROR: Failed to create contact - $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  /// Update a contact
  Future<bool> updateContact(
    int contactId,
    Map<String, dynamic> contactData,
  ) async {
    setLoading(true);

    try {
      print('PeopleProvider: Updating contact with ID: $contactId');
      final updatedContact = await ContactEndpoints.updateContact(
        contactId,
        contactData,
      );

      final index = _contacts.indexWhere((contact) => contact.id == contactId);
      if (index != -1) {
        _contacts[index] = updatedContact;
        notifyListeners();
      }

      print('PeopleProvider: Successfully updated contact');
      return true;
    } catch (e) {
      print('PeopleProvider ERROR: Failed to update contact - $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  /// Delete a contact
  Future<bool> deleteContact(
    int contactId, {
    AuthProvider? authProvider,
  }) async {
    // Check permissions if auth provider is provided
    if (authProvider != null && !canManageShepherds(authProvider)) {
      return false; // Permission denied
    }

    setLoading(true);

    try {
      print('PeopleProvider: Deleting contact with ID: $contactId');
      await ContactEndpoints.deleteContact(contactId);
      _contacts.removeWhere((contact) => contact.id == contactId);
      notifyListeners();
      print('PeopleProvider: Successfully deleted contact');
      return true;
    } catch (e) {
      print('PeopleProvider ERROR: Failed to delete contact - $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  /// Delete shepherd (for backward compatibility)
  Future<bool> deleteShepherd(String id, {AuthProvider? authProvider}) async {
    final contactId = int.tryParse(id);
    if (contactId == null) return false;
    return await deleteContact(contactId, authProvider: authProvider);
  }

  /// Clear current contact details
  void clearContactDetails() {
    _currentContactDetails = null;
    notifyListeners();
  }

  /// Clear provider state - updated version
  void clearAll() {
    salutationController.clear();
    firstNameController.clear();
    lastNameController.clear();
    middleNameController.clear();
    ageGroupController.clear();
    placeOfWorkController.clear();
    genderController.clear();
    civilStatusController.clear();
    avatarController.clear();
    dateOfBirthController.clear();
    contactIdController.clear();

    _isEditMode = false;
    _editingShepherdId = null;
    clearContactDetails();
    notifyListeners();
  }

  // ===== RBAC Permission Checks =====

  /// Check if current user can edit/delete contacts
  bool canManageShepherds(AuthProvider? authProvider) {
    return authProvider?.canManageShepherds ?? false;
  }

  /// Check if current user can view contacts
  bool canViewShepherds(AuthProvider? authProvider) {
    return authProvider?.canViewShepherds ?? false;
  }

  /// Check if current user can manage contacts
  bool canManageContacts(AuthProvider? authProvider) {
    return canManageShepherds(authProvider);
  }

  /// Check if current user can view contacts
  bool canViewContacts(AuthProvider? authProvider) {
    return canViewShepherds(authProvider);
  }

  /// Search contacts by name or email
  List<Contact> searchContacts(String query) {
    if (query.isEmpty) return _contacts;

    final lowercaseQuery = query.toLowerCase();
    return _contacts.where((contact) {
      return contact.name.toLowerCase().contains(lowercaseQuery) ||
          contact.email.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  /// Filter contacts by age group
  List<Contact> filterByAgeGroup(String? ageGroup) {
    if (ageGroup == null || ageGroup.isEmpty) return _contacts;
    return _contacts.where((contact) => contact.ageGroup == ageGroup).toList();
  }

  /// Get all unique age groups
  List<String> getAgeGroups() {
    return _contacts
        .where((contact) => contact.ageGroup != null)
        .map((contact) => contact.ageGroup!)
        .toSet()
        .toList()
      ..sort();
  }

  /// Refresh contacts (same as loadContacts but with different name for clarity)
  Future<void> refreshContacts() async {
    await loadContacts();
  }
}
