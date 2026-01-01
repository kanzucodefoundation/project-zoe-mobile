import 'package:flutter/material.dart';
import '../../widgets/custom_toast.dart';
import 'package:provider/provider.dart';
import '../../components/text_field.dart';
import '../../components/submit_button.dart';
import '../../providers/auth_provider.dart';
import '../../providers/contacts_provider.dart';
import '../../models/contacts.dart';
import '../../models/group.dart';
import '../../services/reports_service.dart';
import '../../api/base_url.dart';

/// Contact Form Screen - Allows users to add new contacts
class AddContactScreen extends StatefulWidget {
  final Contact? editingContact;

  const AddContactScreen({super.key, this.editingContact});

  @override
  State<AddContactScreen> createState() => _AddContactScreenState();
}

class _AddContactScreenState extends State<AddContactScreen> {
  // Form related
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  bool _isSubmitting = false;
  bool _isLoading = true;
  String? _error;

  // Dropdown values
  String? _selectedGender;
  String? _selectedAgeGroup;
  String? _selectedCivilStatus;
  Group? _selectedGroup;
  DateTime? _selectedDateOfBirth;

  // Available groups from API
  List<Group> _availableGroups = [];

  // Dropdown options
  final List<String> _genderOptions = ['Male', 'Female'];
  final List<String> _ageGroupOptions = [
    '0-5',
    '6-9',
    '10-12',
    '13-19',
    '20-30',
    '31-40',
    '41-50',
    '50+',
  ];
  final List<String> _civilStatusOptions = [
    'Married',
    'Single',
    'Dating',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  @override
  void dispose() {
    // Dispose all text controllers
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _initializeForm() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Initialize text controllers
      _controllers['firstName'] = TextEditingController();
      _controllers['lastName'] = TextEditingController();
      _controllers['email'] = TextEditingController();
      _controllers['phone'] = TextEditingController();
      _controllers['address'] = TextEditingController();
      _controllers['placeOfWork'] = TextEditingController();

      // Load available groups from API (filtered for Missional Communities only)
      final groupsResponse = await ReportsService.getUserGroups();
      _availableGroups = groupsResponse.groups
          .where((group) => group.categoryName == 'Missional Community')
          .toList();

      // If we're editing, pre-fill the form
      if (widget.editingContact != null) {
        _preFillFormForEditing();
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error loading form data: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _preFillFormForEditing() {
    final contact = widget.editingContact!;

    // Pre-fill text controllers
    _controllers['firstName']?.text = contact.firstName;
    _controllers['lastName']?.text = contact.lastName;

    // Handle email - get primary email from emails array if available
    _controllers['email']?.text = contact.email ?? '';

    // Handle phone - get primary phone from phones array if available
    _controllers['phone']?.text = contact.phone ?? '';

    // Handle address - for now use empty since we don't have address in Contact model
    _controllers['address']?.text = '';

    // Handle place of work and date of birth
    _controllers['placeOfWork']?.text = '';

    // Parse date of birth if available
    if (contact.dateOfBirth != null && contact.dateOfBirth!.isNotEmpty) {
      try {
        _selectedDateOfBirth = DateTime.parse(contact.dateOfBirth!);
      } catch (e) {
        _selectedDateOfBirth = null;
      }
    }

    // Pre-fill dropdown values
    setState(() {
      _selectedGender = contact.gender;
      _selectedAgeGroup = contact.ageGroup;
      _selectedCivilStatus = null; // Civil status not in current Contact model

      // Find group by name if available
      try {
        _selectedGroup = _availableGroups.firstWhere(
          (group) => group.name == contact.primaryGroup?.name,
        );
      } catch (e) {
        _selectedGroup = null;
      }
    });
  }

  Future<void> _submitContact() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final contactsProvider = Provider.of<ContactsProvider>(
        context,
        listen: false,
      );

      // Prepare contact data in the API's expected format
      final contactData = <String, dynamic>{
        'category': 'Person',
        'person': {
          'firstName': _controllers['firstName']!.text.trim(),
          'lastName': _controllers['lastName']!.text.trim(),
          'gender': _selectedGender,
          'ageGroup': _selectedAgeGroup,
        },
      };

      // Add civil status if selected
      if (_selectedCivilStatus != null) {
        contactData['person']['civilStatus'] = _selectedCivilStatus;
      }

      // Add place of work if provided
      if (_controllers['placeOfWork']!.text.trim().isNotEmpty) {
        contactData['person']['placeOfWork'] = _controllers['placeOfWork']!.text
            .trim();
      }

      // Add date of birth if provided
      if (_selectedDateOfBirth != null) {
        // Format date as YYYY-MM-DD for API
        final formattedDate =
            '${_selectedDateOfBirth!.year}-${_selectedDateOfBirth!.month.toString().padLeft(2, '0')}-${_selectedDateOfBirth!.day.toString().padLeft(2, '0')}';
        contactData['person']['dateOfBirth'] = formattedDate;
      }

      // Add email array if provided
      if (_controllers['email']!.text.trim().isNotEmpty) {
        contactData['emails'] = [
          {
            'category': 'Personal',
            'value': _controllers['email']!.text.trim(),
            'isPrimary': true,
          },
        ];
      }

      // Add phone array if provided
      if (_controllers['phone']!.text.trim().isNotEmpty) {
        contactData['phones'] = [
          {
            'category': 'Mobile',
            'value': _controllers['phone']!.text.trim(),
            'isPrimary': true,
          },
        ];
      }

      // Add address array if provided
      if (_controllers['address']!.text.trim().isNotEmpty) {
        // For simplicity, treat the address as district in Uganda
        contactData['addresses'] = [
          {
            'category': 'Home',
            'country': 'Uganda',
            'district': _controllers['address']!.text.trim(),
            'isPrimary': true,
          },
        ];
      }

      // Add group membership if selected
      if (_selectedGroup != null) {
        contactData['groupMemberships'] = [
          {'groupId': _selectedGroup!.id, 'role': 'Member'},
        ];
      }

      final churchName = authProvider.user?.churchName ?? 'fellowship';

      Contact? result;
      if (widget.editingContact != null) {
        // Update existing contact
        result = await contactsProvider.updateContact(
          widget.editingContact!.id,
          contactData,
          churchName: churchName,
        );
      } else {
        // Create new contact
        print('🔄 Creating contact with data: $contactData');
        print('🔄 Using church name: $churchName');
        result = await contactsProvider.createContact(
          contactData,
          churchName: churchName,
        );
      }

      if (result != null) {
        // Show success message
        if (mounted) {
          ToastHelper.showSuccess(
            context,
            widget.editingContact != null
                ? 'Contact updated successfully!'
                : 'Contact created successfully!',
          );

          // Navigate back to contacts list with success result
          Navigator.of(context).pop(true);
        }
      } else {
        // Show specific error message from provider
        if (mounted) {
          final errorMessage =
              contactsProvider.error ?? 'Failed to save contact';
          print('❌ Contact creation failed: $errorMessage');
          ToastHelper.showError(context, errorMessage);
        }
      }
    } catch (e) {
      // Show error message
      print('❌ Exception during contact creation: $e');
      if (mounted) {
        String errorMessage = 'Failed to create contact';

        if (e.toString().contains('Failed to create contact')) {
          errorMessage =
              'Server error: Unable to create contact. Please check if the server is running.';
        } else if (e.toString().contains('SocketException') ||
            e.toString().contains('Connection refused')) {
          errorMessage =
              'Connection error: Cannot reach the server at ${BaseUrl.baseUrl}';
        } else {
          errorMessage = 'Error: ${e.toString()}';
        }

        ToastHelper.showError(context, errorMessage);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.editingContact != null ? 'Edit Contact' : 'Add Contact',
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? _buildLoadingView()
          : _error != null
          ? _buildErrorView()
          : _buildFormView(),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.black),
          SizedBox(height: 16),
          Text(
            'Loading form fields...',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(
              'Error Loading Form',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _initializeForm,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Form Header Card
          _buildFormHeader(),
          const SizedBox(height: 24),

          // Form Fields Card
          _buildFormFieldsCard(),
        ],
      ),
    );
  }

  Widget _buildFormHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.person_add_outlined,
                  color: Colors.blue.shade600,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.editingContact != null
                          ? 'Edit Contact'
                          : 'New Contact',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.editingContact != null
                          ? 'Update the contact information below'
                          : 'Fill out the fields below to add a new contact',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormFieldsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Contact Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Please provide the contact details',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),

            // Personal Information Section
            _buildSectionHeader('Personal Information'),
            const SizedBox(height: 16),

            // First Name (Required)
            _buildFormField(
              label: 'First Name *',
              child: CustomTextField(
                controller: _controllers['firstName']!,
                hintText: 'Enter first name',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'First name is required';
                  }
                  return null;
                },
              ),
            ),

            // Last Name (Required)
            _buildFormField(
              label: 'Last Name *',
              child: CustomTextField(
                controller: _controllers['lastName']!,
                hintText: 'Enter last name',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Last name is required';
                  }
                  return null;
                },
              ),
            ),

            // Gender (Required)
            _buildFormField(
              label: 'Gender *',
              child: _buildDropdown(
                value: _selectedGender,
                items: _genderOptions,
                hint: 'Select gender',
                onChanged: (value) => setState(() => _selectedGender = value),
                validator: (value) {
                  if (value == null) return 'Gender is required';
                  return null;
                },
              ),
            ),

            // Age Group (Required)
            _buildFormField(
              label: 'Age Group *',
              child: _buildDropdown(
                value: _selectedAgeGroup,
                items: _ageGroupOptions,
                hint: 'Select age group',
                onChanged: (value) => setState(() => _selectedAgeGroup = value),
                validator: (value) {
                  if (value == null) return 'Age group is required';
                  return null;
                },
              ),
            ),

            // Civil Status
            _buildFormField(
              label: 'Civil Status',
              child: _buildDropdown(
                value: _selectedCivilStatus,
                items: _civilStatusOptions,
                hint: 'Select civil status',
                onChanged: (value) =>
                    setState(() => _selectedCivilStatus = value),
              ),
            ),

            const SizedBox(height: 24),
            _buildSectionHeader('Contact Information'),
            const SizedBox(height: 16),

            // Email
            _buildFormField(
              label: 'Email',
              child: CustomTextField(
                controller: _controllers['email']!,
                hintText: 'Enter email address',
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (!RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    ).hasMatch(value)) {
                      return 'Enter a valid email address';
                    }
                  }
                  return null;
                },
              ),
            ),

            // Phone
            _buildFormField(
              label: 'Phone',
              child: CustomTextField(
                controller: _controllers['phone']!,
                hintText: 'Enter phone number',
                keyboardType: TextInputType.phone,
              ),
            ),

            // Address
            _buildFormField(
              label: 'Address',
              child: CustomTextField(
                controller: _controllers['address']!,
                hintText: 'Enter address',
                maxLines: 2,
              ),
            ),

            // Place of Work
            _buildFormField(
              label: 'Place of Work',
              child: CustomTextField(
                controller: _controllers['placeOfWork']!,
                hintText: 'Enter place of work',
              ),
            ),

            // Date of Birth
            _buildFormField(
              label: 'Date of Birth',
              child: _buildDatePickerField(),
            ),

            const SizedBox(height: 24),
            _buildSectionHeader('Group Membership'),
            const SizedBox(height: 16),

            // Group Membership
            _buildFormField(
              label: 'Primary Group',
              child: _buildGroupDropdown(),
            ),

            const SizedBox(height: 32),

            // Submit button
            SubmitButton(
              text: _isSubmitting
                  ? (widget.editingContact != null
                        ? 'Updating...'
                        : 'Creating...')
                  : (widget.editingContact != null
                        ? 'Update Contact'
                        : 'Create Contact'),
              onPressed: _isSubmitting ? () {} : _submitContact,
              backgroundColor: Colors.black,
              textColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.blue.shade600,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormField({required String label, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: label.contains('*') ? Colors.red : Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required String hint,
    required ValueChanged<String?> onChanged,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 16),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
        items: items.map((String option) {
          return DropdownMenuItem<String>(value: option, child: Text(option));
        }).toList(),
        onChanged: onChanged,
        validator: validator,
      ),
    );
  }

  Widget _buildGroupDropdown() {
    if (_availableGroups.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: const Color(0xFFE0E0E0)),
          color: Colors.grey.shade50,
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.grey.shade500, size: 20),
            const SizedBox(width: 12),
            Text(
              'No groups available',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: DropdownButtonFormField<Group>(
        initialValue: _selectedGroup,
        decoration: InputDecoration(
          hintText: 'Select primary group (optional)',
          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 16),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
        items: _availableGroups.map((Group group) {
          return DropdownMenuItem<Group>(
            value: group,
            child: Text(group.name, overflow: TextOverflow.ellipsis),
          );
        }).toList(),
        onChanged: (Group? newValue) {
          setState(() {
            _selectedGroup = newValue;
          });
        },
      ),
    );
  }

  Widget _buildDatePickerField() {
    return GestureDetector(
      onTap: _selectDateOfBirth,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Text(
          _selectedDateOfBirth != null
              ? '${_selectedDateOfBirth!.day}/${_selectedDateOfBirth!.month}/${_selectedDateOfBirth!.year}'
              : 'Select date of birth',
          style: TextStyle(
            fontSize: 16,
            color: _selectedDateOfBirth != null
                ? Colors.black87
                : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Future<void> _selectDateOfBirth() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.black,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && pickedDate != _selectedDateOfBirth) {
      setState(() {
        _selectedDateOfBirth = pickedDate;
      });
    }
  }
}
