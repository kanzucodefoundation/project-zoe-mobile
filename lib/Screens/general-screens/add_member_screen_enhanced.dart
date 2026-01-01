import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/widgets.dart';
import '../../widgets/custom_toast.dart';
import '../../providers/auth_provider.dart';
import '../../providers/contacts_provider.dart';
import '../../models/contacts.dart';
import '../../models/group.dart';
import '../../services/reports_service.dart';
import '../../api/endpoints/contact_endpoints.dart';

/// Enhanced Add Member Form using Project Zoe Design System
class EnhancedAddMemberScreen extends StatefulWidget {
  final Contact? editingContact;

  const EnhancedAddMemberScreen({super.key, this.editingContact});

  @override
  State<EnhancedAddMemberScreen> createState() => _EnhancedAddMemberScreenState();
}

class _EnhancedAddMemberScreenState extends State<EnhancedAddMemberScreen> {
  // Form state
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  bool _isSubmitting = false;
  bool _isLoading = true;
  String? _error;

  // Form field values
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
    '0-5', '6-9', '10-12', '13-19', '20-30', '31-40', '41-50', '50+'
  ];
  final List<String> _civilStatusOptions = [
    'Married', 'Single', 'Dating', 'Other'
  ];

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  @override
  void dispose() {
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

      // Load available groups from API
      final groupsResponse = await ReportsService.getUserGroups();
      _availableGroups = groupsResponse.groups
          .where((group) => group.categoryName == 'Missional Community')
          .toList();

      // If editing, pre-fill the form
      if (widget.editingContact != null) {
        _preFillFormForEditing();
      }

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _error = 'Error loading form data: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _preFillFormForEditing() {
    final contact = widget.editingContact!;
    
    _controllers['firstName']?.text = contact.firstName;
    _controllers['lastName']?.text = contact.lastName;
    _controllers['email']?.text = contact.email ?? '';
    _controllers['phone']?.text = contact.phone ?? '';
    _controllers['address']?.text = '';
    _controllers['placeOfWork']?.text = '';

    if (contact.dateOfBirth != null && contact.dateOfBirth!.isNotEmpty) {
      try {
        _selectedDateOfBirth = DateTime.parse(contact.dateOfBirth!);
      } catch (e) {
        _selectedDateOfBirth = null;
      }
    }

    setState(() {
      _selectedGender = contact.gender;
      _selectedAgeGroup = contact.ageGroup;
      _selectedCivilStatus = null;

      try {
        _selectedGroup = _availableGroups.firstWhere(
          (group) => group.name == contact.primaryGroup?.name,
        );
      } catch (e) {
        _selectedGroup = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.editingContact != null;
    
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBackground,
        elevation: 0,
        title: Text(
          isEditing ? 'Edit Member' : 'Add New Member',
          style: AppTextStyles.h2,
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.primaryText,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _buildBody(isEditing),
    );
  }

  Widget _buildBody(bool isEditing) {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_error != null) {
      return _buildErrorState();
    }

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card with icon
            _buildHeaderCard(isEditing),
            
            const SizedBox(height: AppSpacing.sectionSpacing),

            // Personal Information Section
            _buildPersonalInfoSection(),
            
            const SizedBox(height: AppSpacing.sectionSpacing),

            // Contact Information Section
            _buildContactInfoSection(),
            
            const SizedBox(height: AppSpacing.sectionSpacing),

            // Additional Information Section
            _buildAdditionalInfoSection(),
            
            const SizedBox(height: AppSpacing.xxxl),

            // Submit Button
            _buildSubmitButton(isEditing),
            
            const SizedBox(height: AppSpacing.xxxl),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Loading form...',
            style: AppTextStyles.body.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: ZoeCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: AppSpacing.iconXxl,
                color: AppColors.error,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Failed to load form',
                style: AppTextStyles.h3.copyWith(color: AppColors.error),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                _error!,
                style: AppTextStyles.body,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              ZoeButton.secondary(
                label: 'Retry',
                onPressed: _initializeForm,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(bool isEditing) {
    return ZoeCard(
      backgroundColor: AppColors.primaryGreen,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.pureWhite.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppSpacing.md),
            ),
            child: Icon(
              isEditing ? Icons.edit : Icons.person_add,
              color: AppColors.pureWhite,
              size: AppSpacing.iconLg,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditing ? 'Update Member Info' : 'Add New Member',
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.pureWhite,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  isEditing
                      ? 'Update the member information below'
                      : 'Fill in the details to add a new member to your fellowship',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.pureWhite.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Personal Information',
          style: AppTextStyles.h3,
        ),
        const SizedBox(height: AppSpacing.md),
        ZoeCard(
          child: Column(
            children: [
              ZoeInput(
                label: 'First Name *',
                controller: _controllers['firstName'],
                validator: (value) => value?.isEmpty == true
                    ? 'First name is required'
                    : null,
                prefixIcon: Icon(Icons.person, color: AppColors.secondaryText),
              ),
              const SizedBox(height: AppSpacing.lg),
              ZoeInput(
                label: 'Last Name *',
                controller: _controllers['lastName'],
                validator: (value) => value?.isEmpty == true
                    ? 'Last name is required'
                    : null,
              ),
              const SizedBox(height: AppSpacing.lg),
              ZoeDropdown<String>(
                label: 'Gender',
                value: _selectedGender,
                hint: 'Select gender',
                items: _genderOptions.map((gender) => 
                  DropdownMenuItem(value: gender, child: Text(gender))
                ).toList(),
                onChanged: (value) => setState(() => _selectedGender = value),
              ),
              const SizedBox(height: AppSpacing.lg),
              ZoeDropdown<String>(
                label: 'Age Group',
                value: _selectedAgeGroup,
                hint: 'Select age group',
                items: _ageGroupOptions.map((age) => 
                  DropdownMenuItem(value: age, child: Text(age))
                ).toList(),
                onChanged: (value) => setState(() => _selectedAgeGroup = value),
              ),
              const SizedBox(height: AppSpacing.lg),
              _buildDatePicker(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contact Information',
          style: AppTextStyles.h3,
        ),
        const SizedBox(height: AppSpacing.md),
        ZoeCard(
          child: Column(
            children: [
              ZoeInput(
                label: 'Phone Number',
                controller: _controllers['phone'],
                keyboardType: TextInputType.phone,
                prefixIcon: Icon(Icons.phone, color: AppColors.secondaryText),
              ),
              const SizedBox(height: AppSpacing.lg),
              ZoeInput(
                label: 'Email Address',
                controller: _controllers['email'],
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icon(Icons.email, color: AppColors.secondaryText),
                validator: (value) {
                  if (value?.isNotEmpty == true && !value!.contains('@')) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              ZoeInput(
                label: 'Address',
                controller: _controllers['address'],
                maxLines: 2,
                prefixIcon: Icon(Icons.location_on, color: AppColors.secondaryText),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAdditionalInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Additional Information',
          style: AppTextStyles.h3,
        ),
        const SizedBox(height: AppSpacing.md),
        ZoeCard(
          child: Column(
            children: [
              ZoeDropdown<String>(
                label: 'Civil Status',
                value: _selectedCivilStatus,
                hint: 'Select civil status',
                items: _civilStatusOptions.map((status) => 
                  DropdownMenuItem(value: status, child: Text(status))
                ).toList(),
                onChanged: (value) => setState(() => _selectedCivilStatus = value),
              ),
              const SizedBox(height: AppSpacing.lg),
              ZoeInput(
                label: 'Place of Work',
                controller: _controllers['placeOfWork'],
                prefixIcon: Icon(Icons.work, color: AppColors.secondaryText),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (_availableGroups.isNotEmpty)
                ZoeDropdown<Group>(
                  label: 'Fellowship Group',
                  value: _selectedGroup,
                  hint: 'Select fellowship',
                  items: _availableGroups.map((group) => 
                    DropdownMenuItem(value: group, child: Text(group.name))
                  ).toList(),
                  onChanged: (value) => setState(() => _selectedGroup = value),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date of Birth',
          style: AppTextStyles.label.copyWith(color: AppColors.primaryText),
        ),
        const SizedBox(height: AppSpacing.xs),
        ZoeCard(
          onTap: () => _selectDateOfBirth(),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: AppColors.secondaryText),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    _selectedDateOfBirth != null
                        ? '${_selectedDateOfBirth!.day}/${_selectedDateOfBirth!.month}/${_selectedDateOfBirth!.year}'
                        : 'Select date of birth',
                    style: AppTextStyles.body.copyWith(
                      color: _selectedDateOfBirth != null
                          ? AppColors.primaryText
                          : AppColors.secondaryText,
                    ),
                  ),
                ),
                Icon(Icons.arrow_forward_ios, 
                     size: AppSpacing.iconSm, 
                     color: AppColors.secondaryText),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(bool isEditing) {
    return ZoeButton.primary(
      label: isEditing ? 'Update Member' : 'Add Member',
      isLoading: _isSubmitting,
      onPressed: _isSubmitting ? null : _submitContact,
      width: double.infinity,
    );
  }

  Future<void> _selectDateOfBirth() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 100);
    final lastDate = now;

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth ?? DateTime(now.year - 25),
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryGreen,
              onPrimary: AppColors.pureWhite,
              surface: AppColors.pureWhite,
              onSurface: AppColors.primaryText,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDateOfBirth) {
      setState(() => _selectedDateOfBirth = picked);
    }
  }

  Future<void> _submitContact() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      // Prepare contact data
      final contactData = <String, dynamic>{
        'category': 'Person',
        'person': {
          'firstName': _controllers['firstName']!.text.trim(),
          'lastName': _controllers['lastName']!.text.trim(),
          'gender': _selectedGender,
          'ageGroup': _selectedAgeGroup,
        },
      };

      // Add optional fields
      if (_selectedCivilStatus != null) {
        contactData['person']['civilStatus'] = _selectedCivilStatus;
      }
      if (_controllers['placeOfWork']!.text.trim().isNotEmpty) {
        contactData['person']['placeOfWork'] = _controllers['placeOfWork']!.text.trim();
      }
      if (_selectedDateOfBirth != null) {
        final formattedDate = '${_selectedDateOfBirth!.year}-${_selectedDateOfBirth!.month.toString().padLeft(2, '0')}-${_selectedDateOfBirth!.day.toString().padLeft(2, '0')}';
        contactData['person']['dateOfBirth'] = formattedDate;
      }

      // Add contact info arrays
      final phoneText = _controllers['phone']!.text.trim();
      final emailText = _controllers['email']!.text.trim();
      final addressText = _controllers['address']!.text.trim();

      if (phoneText.isNotEmpty) {
        contactData['phones'] = [{'phone': phoneText}];
      }
      if (emailText.isNotEmpty) {
        contactData['emails'] = [{'email': emailText}];
      }
      if (addressText.isNotEmpty) {
        contactData['addresses'] = [{'address': addressText}];
      }
      if (_selectedGroup != null) {
        contactData['groups'] = [_selectedGroup!.id];
      }

      // Submit to API
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final churchName = authProvider.user?.churchName ?? 'fellowship';

      if (widget.editingContact != null) {
        // Update existing contact
        await ContactEndpoints.updateContact(
          widget.editingContact!.id,
          contactData,
          churchName: churchName,
        );
        if (mounted) {
          ToastHelper.showInfo(context, 'Member updated successfully!');
        }
      } else {
        // Create new contact
        await ContactEndpoints.createContact(contactData, churchName: churchName);
        if (mounted) {
          ToastHelper.showInfo(context, 'Member added successfully!');
        }
      }

      // Return success to calling screen
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ToastHelper.showError(context, 'Failed to save member: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}