import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../components/text_field.dart';
import '../../components/submit_button.dart';
import '../../providers/auth_provider.dart';
import '../../providers/contacts_provider.dart';
import '../../models/contacts.dart';
import '../../models/contact_form_field.dart';

/// Contact Form Screen - Allows users to add new contacts
class AddPeopleScreen extends StatefulWidget {
  final Contact? editingContact;

  const AddPeopleScreen({super.key, this.editingContact});

  @override
  State<AddPeopleScreen> createState() => _AddPeopleScreenState();
}

class _AddPeopleScreenState extends State<AddPeopleScreen> {
  List<ContactFormField>? _formFields;
  bool _isLoading = true;
  String? _error;

  // Form related
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  bool _isSubmitting = false;

  // Dropdown values
  String? _selectedGender;
  String? _selectedAgeGroup;

  @override
  void initState() {
    super.initState();
    _loadFormFields();
  }

  @override
  void dispose() {
    // Dispose all text controllers
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadFormFields() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final contactsProvider = Provider.of<ContactsProvider>(
        context,
        listen: false,
      );

      // Load contact form fields from server
      final fields = await contactsProvider.getContactFormFields(
        churchName: authProvider.user?.churchName ?? 'fellowship',
      );

      setState(() {
        _formFields = fields;
        _isLoading = false;
      });

      // Initialize controllers for each field
      for (var field in fields) {
        if (field.type != 'dropdown') {
          _controllers[field.name] = TextEditingController();
        }
      }

      // If we're editing, pre-fill the form
      if (widget.editingContact != null) {
        _preFillFormForEditing();
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading form fields: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _preFillFormForEditing() {
    final contact = widget.editingContact!;

    // Pre-fill text controllers
    if (_controllers['firstName'] != null) {
      _controllers['firstName']!.text = contact.firstName;
    }
    if (_controllers['lastName'] != null) {
      _controllers['lastName']!.text = contact.lastName;
    }
    if (_controllers['email'] != null) {
      _controllers['email']!.text = contact.email ?? '';
    }
    if (_controllers['phone'] != null) {
      _controllers['phone']!.text = contact.phone ?? '';
    }

    // Pre-fill dropdown values
    setState(() {
      _selectedGender = contact.gender;
      _selectedAgeGroup = contact.ageGroup;
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

      // Prepare contact data
      final contactData = <String, dynamic>{};

      // Add text field values
      _controllers.forEach((key, controller) {
        if (controller.text.trim().isNotEmpty) {
          contactData[key] = controller.text.trim();
        }
      });

      // Add dropdown values
      if (_selectedGender != null) contactData['gender'] = _selectedGender;
      if (_selectedAgeGroup != null)
        contactData['ageGroup'] = _selectedAgeGroup;
      contactData['isActive'] = true;

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
        result = await contactsProvider.createContact(
          contactData,
          churchName: churchName,
        );
      }

      if (result != null) {
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.editingContact != null
                    ? 'Contact updated successfully!'
                    : 'Contact created successfully!',
              ),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate back to contacts list
          Navigator.of(context).pop();
        }
      } else {
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(contactsProvider.error ?? 'Failed to save contact'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
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
              onPressed: _loadFormFields,
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

            // Generate form fields from server data
            if (_formFields != null)
              ...(_formFields!.map((field) => _buildFormFieldWidget(field))),

            const SizedBox(height: 24),

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

  Widget _buildFormFieldWidget(ContactFormField field) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Field label (consistent with report forms)
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: field.required ? Colors.red : Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  field.label,
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

          // Input field based on type
          _buildInputForField(field),
        ],
      ),
    );
  }

  Widget _buildInputForField(ContactFormField field) {
    switch (field.type) {
      case 'email':
        return CustomTextField(
          controller: _controllers[field.name]!,
          hintText: field.placeholder ?? 'Enter ${field.label.toLowerCase()}',
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (field.required && (value == null || value.isEmpty)) {
              return '${field.label} is required';
            }
            if (value != null && value.isNotEmpty) {
              if (!RegExp(
                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
              ).hasMatch(value)) {
                return 'Enter a valid email address';
              }
            }
            return null;
          },
        );
      case 'phone':
        return CustomTextField(
          controller: _controllers[field.name]!,
          hintText: field.placeholder ?? 'Enter ${field.label.toLowerCase()}',
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (field.required && (value == null || value.isEmpty)) {
              return '${field.label} is required';
            }
            return null;
          },
        );
      case 'dropdown':
        if (field.name == 'gender') {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: DropdownButtonFormField<String>(
              value: _selectedGender,
              decoration: InputDecoration(
                hintText:
                    field.placeholder ?? 'Select ${field.label.toLowerCase()}',
                hintStyle: TextStyle(color: Colors.grey[500], fontSize: 16),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
              items: (field.options ?? ['Male', 'Female', 'Other']).map((
                String value,
              ) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedGender = newValue;
                });
              },
              validator: (value) {
                if (field.required && value == null) {
                  return '${field.label} is required';
                }
                return null;
              },
            ),
          );
        } else if (field.name == 'ageGroup') {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: DropdownButtonFormField<String>(
              value: _selectedAgeGroup,
              decoration: InputDecoration(
                hintText:
                    field.placeholder ?? 'Select ${field.label.toLowerCase()}',
                hintStyle: TextStyle(color: Colors.grey[500], fontSize: 16),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
              items:
                  (field.options ??
                          ['Child', 'Youth', 'Young Adult', 'Adult', 'Senior'])
                      .map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      })
                      .toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedAgeGroup = newValue;
                });
              },
              validator: (value) {
                if (field.required && value == null) {
                  return '${field.label} is required';
                }
                return null;
              },
            ),
          );
        }
        return const SizedBox.shrink();
      default:
        return CustomTextField(
          controller: _controllers[field.name]!,
          hintText: field.placeholder ?? 'Enter ${field.label.toLowerCase()}',
          validator: (value) {
            if (field.required && (value == null || value.isEmpty)) {
              return '${field.label} is required';
            }
            return null;
          },
        );
    }
  }
}
