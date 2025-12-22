import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:project_zoe/api/endpoints/user_endpoints.dart';
import 'package:project_zoe/models/people.dart';
import 'package:project_zoe/services/shepherd_service.dart';
import '../models/shepherd.dart';
import '../providers/auth_provider.dart';

class ShepherdsProvider extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();

  // Controllers
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
  // Shepherds list management
  List<People> _shepherds = [];
  List<People> get shepherds => _shepherds;

  final ShepherdService shepherdService = ShepherdService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingShepherds = false;
  bool get isLoadingShepherds => _isLoadingShepherds;

  // Edit mode state
  bool _isEditMode = false;
  bool get isEditMode => _isEditMode;

  int? _editingShepherdId;
  int? get editingShepherdId => _editingShepherdId;

  ShepherdsProvider() {
    _initializeShepherds();
  }

  Future<void> _initializeShepherds() async {
    await loadShepherds();
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Validation methods
  String? validateName(String? value) {
    if (value == null || value.isEmpty) return 'Please enter shepherd name';
    if (value.length < 2) return 'Name must be at least 2 characters';
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Please enter email address';
    // Basic validation: contains '@' and a dot after '@'
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
    if (value == null || value.isEmpty) return 'Please enter shepherd position';
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
    notifyListeners();
  }

  // Load shepherd data for editing
  void loadShepherdForEdit(People person) {
    salutationController.text = person.salutation ?? '';
    firstNameController.text = person.firstName;
    lastNameController.text = person.lastName;
    middleNameController.text = person.middleName ?? '';
    ageGroupController.text = person.ageGroup ?? '';
    placeOfWorkController.text = person.placeOfWork ?? '';
    genderController.text = person.gender;
    civilStatusController.text = person.civilStatus;
    avatarController.text = person.avatar;
    dateOfBirthController.text = person.dateOfBirth;
    contactIdController.text = person.contactId.toString();

    _isEditMode = true;
    _editingShepherdId = person.id;
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

  // Submission logic (simulate or call API) - handles both add and edit
  Future<bool> submit() async {
    if (!formKey.currentState!.validate()) return false;
    setLoading(true);
    try {
      if (_isEditMode) {
        // Update existing shepherd
        return await _updateShepherd();
      } else {
        // Create new shepherd
        return await _createShepherd();
      }
    } catch (_) {
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Create new shepherd
  Future<bool> _createShepherd() async {
    // final newShepherd = Person(
    //   id: DateTime.now().millisecondsSinceEpoch.toString(),
    //   name: nameController.text,
    //   email: emailController.text,
    //   phone: phoneController.text,
    //   address: addressController.text,
    //   churchLocation: churchLocationController.text,
    //   position: positionController.text,
    //   yearsOfService: int.tryParse(yearsOfServiceController.text) ?? 0,
    //   emergencyPhone: emergencyPhoneController.text,
    //   department: departmentController.text,
    // );

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    // Add to list
    // _shepherds.add();
    notifyListeners();

    // On success: clear form
    clear();
    return true;
  }

  // Update existing shepherd
  Future<bool> _updateShepherd() async {
    if (_editingShepherdId == null) return false;

    // final updatedShepherd = Shepherd(
    //   id: _editingShepherdId!,
    //   name: nameController.text,
    //   email: emailController.text,
    //   phone: phoneController.text,
    //   address: addressController.text,
    //   churchLocation: churchLocationController.text,
    //   position: positionController.text,
    //   yearsOfService: int.tryParse(yearsOfServiceController.text) ?? 0,
    //   emergencyPhone: emergencyPhoneController.text,
    //   department: departmentController.text,
    // );

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    // Update in list
    final index = _shepherds.indexWhere((s) => s.id == _editingShepherdId);
    if (index != -1) {
      // _shepherds[index] = updatedShepherd;
      notifyListeners();

      // On success: clear form and exit edit mode
      clear();
      return true;
    }
    return false;
  }

  // Load sample shepherds data
  // void _loadSampleShepherds() {
  //   _shepherds = [
  //     Shepherd(
  //       id: '1',
  //       name: 'Pastor John Smith',
  //       email: 'john.smith@church.com',
  //       phone: '+1 (555) 123-4567',
  //       address: '123 Church Street, City',
  //       churchLocation: 'Central Community Church',
  //       position: 'Senior Pastor',
  //       yearsOfService: 15,
  //       emergencyPhone: '+1 (555) 987-6543',
  //       department: 'Leadership',
  //     ),
  //     Shepherd(
  //       id: '2',
  //       name: 'Pastor Mary Johnson',
  //       email: 'mary.johnson@church.com',
  //       phone: '+1 (555) 234-5678',
  //       address: '456 Oak Avenue, City',
  //       churchLocation: 'Grace Fellowship Church',
  //       position: 'Associate Pastor',
  //       yearsOfService: 8,
  //       emergencyPhone: '+1 (555) 876-5432',
  //       department: 'Youth Ministry',
  //     ),
  //     Shepherd(
  //       id: '3',
  //       name: 'Pastor David Brown',
  //       email: 'david.brown@church.com',
  //       phone: '+1 (555) 345-6789',
  //       address: '789 Maple Drive, City',
  //       churchLocation: 'Faith Baptist Church',
  //       position: 'Youth Pastor',
  //       yearsOfService: 5,
  //       emergencyPhone: '+1 (555) 765-4321',
  //       department: 'Youth Ministry',
  //     ),
  //     Shepherd(
  //       id: '4',
  //       name: 'Pastor Sarah Wilson',
  //       email: 'sarah.wilson@church.com',
  //       phone: '+1 (555) 456-7890',
  //       address: '321 Pine Street, City',
  //       churchLocation: 'Hope Presbyterian Church',
  //       position: 'Worship Pastor',
  //       yearsOfService: 10,
  //       emergencyPhone: '+1 (555) 654-3210',
  //       department: 'Worship',
  //     ),
  //   ];
  // }

  // Get shepherd by ID
  People? getShepherdById(int id) {
    try {
      return _shepherds.firstWhere((shepherd) => shepherd.id == id);
    } catch (e) {
      return null;
    }
  }

  // Load shepherds (simulate API call)
  Future<void> loadShepherds() async {
    _isLoadingShepherds = true;
    notifyListeners();
    try {
      _shepherds = await shepherdService.getPeople();
    } catch (e) {
      throw Exception('Failed to fetch reports: ${e.toString()}');
    } finally {
      _isLoadingShepherds = false;
      notifyListeners();
    }
  }

  // Delete shepherd with permission check
  Future<bool> deleteShepherd(String id, {AuthProvider? authProvider}) async {
    // Check permissions if auth provider is provided
    if (authProvider != null && !authProvider.canManageShepherds) {
      return false; // Permission denied
    }

    try {
      _shepherds.removeWhere((shepherd) => shepherd.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  //! RBAC Permission Checks

  // Check if current user can edit/delete shepherds
  bool canManageShepherds(AuthProvider? authProvider) {
    return authProvider?.canManageShepherds ?? false;
  }

  // Check if current user can view shepherds
  bool canViewShepherds(AuthProvider? authProvider) {
    return authProvider?.canViewShepherds ?? false;
  }
}
