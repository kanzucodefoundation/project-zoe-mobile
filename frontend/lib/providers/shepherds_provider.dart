import 'package:flutter/material.dart';
import '../models/shepherd.dart';
import '../providers/auth_provider.dart';

class ShepherdsProvider extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();

  // Controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final churchLocationController = TextEditingController();
  final positionController = TextEditingController();
  final yearsOfServiceController = TextEditingController();
  final emergencyPhoneController = TextEditingController();
  final departmentController = TextEditingController();

  // Shepherds list management
  List<Shepherd> _shepherds = [];
  List<Shepherd> get shepherds => _shepherds;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingShepherds = false;
  bool get isLoadingShepherds => _isLoadingShepherds;

  // Edit mode state
  bool _isEditMode = false;
  bool get isEditMode => _isEditMode;

  String? _editingShepherdId;
  String? get editingShepherdId => _editingShepherdId;

  ShepherdsProvider() {
    _loadSampleShepherds();
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
    nameController.clear();
    emailController.clear();
    phoneController.clear();
    addressController.clear();
    churchLocationController.clear();
    positionController.clear();
    yearsOfServiceController.clear();
    emergencyPhoneController.clear();
    departmentController.clear();
    _isEditMode = false;
    _editingShepherdId = null;
    notifyListeners();
  }

  // Load shepherd data for editing
  void loadShepherdForEdit(Shepherd shepherd) {
    nameController.text = shepherd.name;
    emailController.text = shepherd.email;
    phoneController.text = shepherd.phone;
    addressController.text = shepherd.address;
    churchLocationController.text = shepherd.churchLocation;
    positionController.text = shepherd.position;
    yearsOfServiceController.text = shepherd.yearsOfService.toString();
    emergencyPhoneController.text = shepherd.emergencyPhone;
    departmentController.text = shepherd.department;

    _isEditMode = true;
    _editingShepherdId = shepherd.id;
    notifyListeners();
  }

  // Dispose controllers
  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    churchLocationController.dispose();
    positionController.dispose();
    yearsOfServiceController.dispose();
    emergencyPhoneController.dispose();
    departmentController.dispose();
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
    final newShepherd = Shepherd(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: nameController.text,
      email: emailController.text,
      phone: phoneController.text,
      address: addressController.text,
      churchLocation: churchLocationController.text,
      position: positionController.text,
      yearsOfService: int.tryParse(yearsOfServiceController.text) ?? 0,
      emergencyPhone: emergencyPhoneController.text,
      department: departmentController.text,
    );

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    // Add to list
    _shepherds.add(newShepherd);
    notifyListeners();

    // On success: clear form
    clear();
    return true;
  }

  // Update existing shepherd
  Future<bool> _updateShepherd() async {
    if (_editingShepherdId == null) return false;

    final updatedShepherd = Shepherd(
      id: _editingShepherdId!,
      name: nameController.text,
      email: emailController.text,
      phone: phoneController.text,
      address: addressController.text,
      churchLocation: churchLocationController.text,
      position: positionController.text,
      yearsOfService: int.tryParse(yearsOfServiceController.text) ?? 0,
      emergencyPhone: emergencyPhoneController.text,
      department: departmentController.text,
    );

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    // Update in list
    final index = _shepherds.indexWhere((s) => s.id == _editingShepherdId);
    if (index != -1) {
      _shepherds[index] = updatedShepherd;
      notifyListeners();

      // On success: clear form and exit edit mode
      clear();
      return true;
    }
    return false;
  }

  // Load sample shepherds data
  void _loadSampleShepherds() {
    _shepherds = [
      Shepherd(
        id: '1',
        name: 'Pastor John Smith',
        email: 'john.smith@church.com',
        phone: '+1 (555) 123-4567',
        address: '123 Church Street, City',
        churchLocation: 'Central Community Church',
        position: 'Senior Pastor',
        yearsOfService: 15,
        emergencyPhone: '+1 (555) 987-6543',
        department: 'Leadership',
      ),
      Shepherd(
        id: '2',
        name: 'Pastor Mary Johnson',
        email: 'mary.johnson@church.com',
        phone: '+1 (555) 234-5678',
        address: '456 Oak Avenue, City',
        churchLocation: 'Grace Fellowship Church',
        position: 'Associate Pastor',
        yearsOfService: 8,
        emergencyPhone: '+1 (555) 876-5432',
        department: 'Youth Ministry',
      ),
      Shepherd(
        id: '3',
        name: 'Pastor David Brown',
        email: 'david.brown@church.com',
        phone: '+1 (555) 345-6789',
        address: '789 Maple Drive, City',
        churchLocation: 'Faith Baptist Church',
        position: 'Youth Pastor',
        yearsOfService: 5,
        emergencyPhone: '+1 (555) 765-4321',
        department: 'Youth Ministry',
      ),
      Shepherd(
        id: '4',
        name: 'Pastor Sarah Wilson',
        email: 'sarah.wilson@church.com',
        phone: '+1 (555) 456-7890',
        address: '321 Pine Street, City',
        churchLocation: 'Hope Presbyterian Church',
        position: 'Worship Pastor',
        yearsOfService: 10,
        emergencyPhone: '+1 (555) 654-3210',
        department: 'Worship',
      ),
    ];
  }

  // Get shepherd by ID
  Shepherd? getShepherdById(String id) {
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
      // Simulate API delay
      await Future.delayed(const Duration(seconds: 1));
      // In real app, this would fetch from API
      // _shepherds = await apiService.getShepherds();
      notifyListeners();
    } catch (e) {
      // Handle error
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

  // Check if current user can edit/delete shepherds
  bool canManageShepherds(AuthProvider? authProvider) {
    return authProvider?.canManageShepherds ?? false;
  }

  // Check if current user can view shepherds
  bool canViewShepherds(AuthProvider? authProvider) {
    return authProvider?.canViewShepherds ?? false;
  }
}
