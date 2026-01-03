import 'package:flutter/material.dart';
import 'package:project_zoe/models/report.dart';
import 'package:project_zoe/models/reports_model.dart';
import 'package:project_zoe/providers/auth_provider.dart';
import 'package:project_zoe/services/reports_service.dart';
import 'package:provider/provider.dart';
import '../../components/text_field.dart';
import '../../components/submit_button.dart';
import '../../components/custom_date_picker.dart';
import '../../widgets/custom_toast.dart';
// import '../../components/dropdown.dart';

/// Garage Reports Display Screen - Shows Garage report template and submissions
class GarageReportsScreen extends StatefulWidget {
  final int reportId;
  final Map<String, dynamic>? editingSubmission;

  const GarageReportsScreen({
    super.key,
    required this.reportId,
    this.editingSubmission,
  });

  @override
  State<GarageReportsScreen> createState() => _GarageReportsScreenState();
}

class _GarageReportsScreenState extends State<GarageReportsScreen> {
  Report? _reportTemplate;
  final List<Map<String, dynamic>> _submissions = [];
  bool _isLoading = true;
  String? _error;

  // Form related
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, dynamic> _dynamicSelections = {}; // Store dynamic field selections
  final Map<String, Future<List<Map<String, dynamic>>>> _dynamicOptionsFutures = {}; // Cache futures
  DateTime? _selectedDate;
  bool _isSubmitting = false;

  String? _selectedLocationId;
  String? _selectedServiceType;

  @override
  void initState() {
    super.initState();
    _loadReportData();
  }

  @override
  void dispose() {
    // Dispose all text controllers
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadReportData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load Garage report template (ID: 2)
      final templateData = await ReportsService.getReportById(widget.reportId);

      final template = Report.fromJson(templateData.toJson());
      final submissions = await ReportsService.getReportSubmissions(
        widget.reportId,
      );

      setState(() {
        _reportTemplate = template;
        _submissions.clear();
        _submissions.addAll(submissions);
        _isLoading = false;
      });

      // If we're editing, pre-fill the form with existing data
      if (widget.editingSubmission != null) {
        _preFillFormForEditing();
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading report data: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _preFillFormForEditing() {
    final submission = widget.editingSubmission!;
    final data = submission['data'] as Map<String, dynamic>? ?? {};

    if (submission['groupId'] != null) {
      _selectedLocationId = submission['groupId'].toString();
      // debugPrint('✅ Pre-filled salvation locationId: $_selectedLocationId');
    }

    // Pre-fill text controllers
    data.forEach((key, value) {
      if (key == 'serviceDate' && value != null) {
        try {
          _selectedDate = DateTime.parse(value.toString());
          print('✅ Pre-filled service date: $_selectedDate');
        } catch (e) {
          print('⚠️ Invalid date format: $value');
        }
      } else if (key.toLowerCase().contains('servicetype') ||
          key.toLowerCase().contains('service type')) {
        _selectedServiceType = value?.toString();
        print('✅ Pre-filled service type: $_selectedServiceType');
      } else if (value != null && value.toString().isNotEmpty) {
        // Create controller if doesn't exist and pre-fill
        if (!_controllers.containsKey(key)) {
          _controllers[key] = TextEditingController();
        }
        _controllers[key]!.text = value.toString();
        print('✅ Pre-filled garage field $key with: ${value.toString()}');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              widget.editingSubmission != null
                  ? 'Edit Garage Report'
                  : 'Garage Reports',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? _buildErrorView()
              : _reportTemplate != null
              ? _buildReportView(authProvider)
              : const Center(child: Text('No report data found')),
        );
      },
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
              'Error Loading Report',
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
              onPressed: _loadReportData,
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

  Widget _buildReportView(AuthProvider authProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Report Header Card
          _buildReportHeader(),
          const SizedBox(height: 24),

          // Report Fields with Form
          _buildReportFieldsWithForm(authProvider),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildReportHeader() {
    return Container(
      width: double.infinity,
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
                  color: Colors.orange.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.garage, size: 24, color: Colors.orange),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _reportTemplate!.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _reportTemplate!.description,
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
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildInfoChip('Frequency', _reportTemplate!.submissionFrequency),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, String value, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (color ?? Colors.orange).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: color ?? Colors.orange.shade700,
        ),
      ),
    );
  }

  Widget _buildReportFieldsWithForm(AuthProvider authProvider) {
    final visibleFields = _reportTemplate!.fields!
        .where((field) => !field.hidden)
        .toList();

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
              'Report Fields',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Fill out the fields below to submit your report',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),

            // Location selection with label
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Location',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildLocationPicker(authProvider),
            const SizedBox(height: 20),

            // Generate form fields
            ...visibleFields.map(
              (field) => _buildTemplateFieldWithInput(field),
            ),

            const SizedBox(height: 24),

            // Submit button
            SubmitButton(
              text: _isSubmitting
                  ? 'Submitting...'
                  : widget.editingSubmission != null
                  ? 'Update Report'
                  : 'Submit Report',
              onPressed: _isSubmitting ? () {} : _submitReport,
              backgroundColor: Colors.black,
              textColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateFieldWithInput(ReportField field) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Field info header (without type)
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
          // Dynamic input field based on field type and name
          _buildInputForField(field),
        ],
      ),
    );
  }

  Widget _buildInputForField(ReportField field) {
    final fieldName = field.name.toLowerCase();
    final fieldLabel = field.label.toLowerCase();

    // Check if this is a dynamic group selector field
    if (field.type.toLowerCase() == 'select' && 
        field.options != null && 
        field.options!.isNotEmpty &&
        field.options![0] is Map<String, dynamic> &&
        (field.options![0] as Map<String, dynamic>)['type'] == 'dynamic_group_selector') {
      
      return _buildDynamicGroupSelector(field);
    }

    // Service Type dropdown
    if (fieldLabel.contains('service type') ||
        fieldName.contains('servicetype')) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(25),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,
            value: _selectedServiceType,
            hint: Text(
              'Select ${field.label}',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            items: (field.options ?? []).map((option) {
              return DropdownMenuItem<String>(
                value: option.toString(),
                child: Text(
                  option.toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedServiceType = value;
              });
            },
          ),
        ),
      );
    }

    // Date picker for date fields (but NOT service type)
    if ((fieldName.contains('date') || fieldLabel.contains('date')) &&
        !fieldName.contains('type') &&
        !fieldLabel.contains('type')) {
      return CustomDatePicker(
        hintText: 'Select ${field.label.toLowerCase()}',
        prefixIcon: Icons.calendar_today,
        selectedDate: _selectedDate,
        onDateSelected: (date) {
          setState(() {
            _selectedDate = date;
          });
        },
        validator: field.required
            ? (value) {
                if (value == null) {
                  return '${field.label} is required';
                }
                return null;
              }
            : null,
      );
    }

    // Initialize controller if not exists
    if (!_controllers.containsKey(field.name)) {
      _controllers[field.name] = TextEditingController();
    }

    // Text area for long text fields
    if (field.type.toLowerCase() == 'textarea' ||
        fieldLabel.contains('comment') ||
        fieldLabel.contains('note') ||
        fieldLabel.contains('description') ||
        fieldLabel.contains('summary')) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: TextFormField(
          controller: _controllers[field.name],
          maxLines: 4,
          validator: field.required
              ? (value) {
                  if (value == null || value.isEmpty) {
                    return '${field.label} is required';
                  }
                  return null;
                }
              : null,
          decoration: InputDecoration(
            hintText: 'Enter ${field.label.toLowerCase()}',
            hintStyle: TextStyle(color: Colors.grey[500], fontSize: 16),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
        ),
      );
    }

    // Regular text field
    return CustomTextField(
      hintText: 'Enter ${field.label.toLowerCase()}',
      controller: _controllers[field.name],
      keyboardType: _getKeyboardType(field.type),
      validator: field.required
          ? (value) {
              if (value == null || value.isEmpty) {
                return '${field.label} is required';
              }
              return null;
            }
          : null,
    );
  }

  // Widget _buildSubmitForm() {
  //   if (_reportTemplate?.fields == null) return const SizedBox();

  //   final visibleFields = _reportTemplate!.fields!
  //       .where((field) => !field.hidden)
  //       .toList();

  //   return Container(
  //     padding: const EdgeInsets.all(20),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(12),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.grey.withValues(alpha: 0.1),
  //           blurRadius: 10,
  //           offset: const Offset(0, 2),
  //         ),
  //       ],
  //     ),
  //     child: Form(
  //       key: _formKey,
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           const Text(
  //             'Submit Report',
  //             style: TextStyle(
  //               fontSize: 18,
  //               fontWeight: FontWeight.bold,
  //               color: Colors.black,
  //             ),
  //           ),
  //           const SizedBox(height: 4),
  //           Text(
  //             'Fill out the report fields below',
  //             style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
  //           ),
  //           const SizedBox(height: 20),

  //           // Generate form fields
  //           ...visibleFields.map((field) => _buildFormField(field)),

  //           const SizedBox(height: 20),

  //           // Submit button
  //           SubmitButton(
  //             text: _isSubmitting ? 'Submitting...' : 'Submit Report',
  //             onPressed: _isSubmitting ? () {} : _submitReport,
  //             backgroundColor: Colors.orange,
  //             textColor: Colors.white,
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildFormField(ReportField field) {
  //   // Initialize controller if not exists
  //   if (!_controllers.containsKey(field.name)) {
  //     _controllers[field.name] = TextEditingController();
  //   }

  //   return Padding(
  //     padding: const EdgeInsets.only(bottom: 16),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(
  //           field.label,
  //           style: const TextStyle(
  //             fontSize: 14,
  //             fontWeight: FontWeight.w500,
  //             color: Colors.black87,
  //           ),
  //         ),
  //         const SizedBox(height: 8),
  //         CustomTextField(
  //           hintText: 'Enter ${field.label.toLowerCase()}',
  //           controller: _controllers[field.name],
  //           keyboardType: _getKeyboardType(field.type),
  //           validator: field.required
  //               ? (value) {
  //                   if (value == null || value.isEmpty) {
  //                     return '${field.label} is required';
  //                   }
  //                   return null;
  //                 }
  //               : null,
  //         ),
  //       ],
  //     ),
  //   );
  // }

  /// Build dynamic group selector dropdown
  Widget _buildDynamicGroupSelector(ReportField field) {
    // Cache the future to prevent infinite loops
    if (!_dynamicOptionsFutures.containsKey(field.name)) {
      _dynamicOptionsFutures[field.name] = _resolveDynamicGroupOptions(field);
    }
    
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _dynamicOptionsFutures[field.name]!,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.grey.shade600),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Loading ${field.label.toLowerCase()}...',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          );
        }

        if (snapshot.hasError) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              border: Border.all(color: Colors.red.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red.shade600, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Error loading ${field.label.toLowerCase()}',
                    style: TextStyle(color: Colors.red.shade600, fontSize: 14),
                  ),
                ),
              ],
            ),
          );
        }

        final options = snapshot.data ?? [];
        
        // Get current selection for this field
        final currentSelection = _dynamicSelections[field.name];
        final selectedItem = currentSelection != null 
            ? options.cast<Map<String, dynamic>?>().firstWhere(
                (item) => item != null && item['id'] == currentSelection['id'],
                orElse: () => null,
              )
            : null;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(25),
          ),
          child: DropdownButtonFormField<Map<String, dynamic>>(
            decoration: InputDecoration(
              hintText: options.isEmpty 
                  ? 'No ${field.label.toLowerCase()} available'
                  : 'Select ${field.label.toLowerCase()}',
              hintStyle: TextStyle(
                color: options.isEmpty ? Colors.red : Colors.grey[500], 
                fontSize: 16
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
            value: selectedItem,
            validator: field.required
                ? (value) {
                    if (value == null) {
                      return 'Please select ${field.label}';
                    }
                    return null;
                  }
                : null,
            items: options.map((option) {
              return DropdownMenuItem<Map<String, dynamic>>(
                value: option,
                child: Text(
                  option['name']?.toString() ?? 'Unknown',
                  style: const TextStyle(fontSize: 16),
                ),
              );
            }).toList(),
            onChanged: options.isEmpty ? null : (selected) {
              if (mounted) {
                setState(() {
                  _dynamicSelections[field.name] = selected;
                });
              }
            },
            icon: options.isEmpty 
                ? Icon(Icons.error_outline, color: Colors.red.shade400)
                : const Icon(Icons.arrow_drop_down),
          ),
        );
      },
    );
  }

  /// Resolve dynamic group options from field configuration
  Future<List<Map<String, dynamic>>> _resolveDynamicGroupOptions(ReportField field) async {
    try {
      debugPrint('🔍 Resolving options for field: ${field.name}');
      debugPrint('🔍 Field options: ${field.options}');
      
      if (field.options == null || field.options!.isEmpty) {
        debugPrint('⚠️ Field has no options');
        return [];
      }

      if (field.options![0] is! Map<String, dynamic>) {
        debugPrint('⚠️ First option is not a Map: ${field.options![0].runtimeType}');
        return [];
      }

      final selectorConfig = field.options![0] as Map<String, dynamic>;
      debugPrint('🔍 Selector config: $selectorConfig');
      
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      final result = await ReportsService.resolveDynamicGroupSelector(
        selectorConfig, 
        authProvider,
      );
      
      debugPrint('✅ Resolved ${result.length} options for field ${field.name}');
      return result;
    } catch (e) {
      debugPrint('💀 Error resolving dynamic group options for ${field.name}: $e');
      debugPrint('💀 Stack trace: ${StackTrace.current}');
      return [];
    }
  }

  Widget _buildLocationPicker(AuthProvider authProvider) {
    final List<Map<String, dynamic>> availableLocations = authProvider
        .getGroupsFromHierarchy('location');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(25),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: _selectedLocationId,
          hint: availableLocations.isEmpty
              ? Text(
                  'No location available',
                  style: TextStyle(color: Colors.red),
                )
              : Text(
                  'Select Location',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
          items: availableLocations.map((mc) {
            return DropdownMenuItem<String>(
              value: mc['id']?.toString(),
              child: Text(
                mc['name'] ?? 'Unknown MC',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              if (mounted) {
                setState(() {
                  _selectedLocationId = value;
                });
              }
            }
          },
        ),
      ),
    );
  }

  TextInputType _getKeyboardType(String type) {
    switch (type.toLowerCase()) {
      case 'number':
      case 'integer':
        return TextInputType.number;
      case 'email':
        return TextInputType.emailAddress;
      case 'phone':
        return TextInputType.phone;
      case 'url':
        return TextInputType.url;
      default:
        return TextInputType.text;
    }
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) {
      ToastHelper.showWarning(context, 'Please fill in all required fields');
      return;
    }

    // Check dynamic selections or fallback to legacy location selection
    String? locationId = _selectedLocationId;
    if (_dynamicSelections.isNotEmpty) {
      final selectedGroup = _dynamicSelections.values.first;
      locationId = selectedGroup['id'].toString();
    }
    
    if (locationId == null) {
      ToastHelper.showWarning(context, 'Please select the location');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Collect form data
      final Map<String, dynamic> formData = {};
      for (var entry in _controllers.entries) {
        formData[entry.key] = entry.value.text;
      }

      // Add report metadata
      if (_selectedDate != null) {
        formData['serviceDate'] = _selectedDate!.toIso8601String();
      }

      // Add selected service type
      if (_selectedServiceType != null) {
        formData['serviceType'] = _selectedServiceType;
      }

      // Add dynamic field selections to form data
      for (var entry in _dynamicSelections.entries) {
        final fieldName = entry.key;
        final selection = entry.value;
        
        if (selection != null) {
          // For name fields, store the name; for ID fields, store the ID
          if (fieldName.toLowerCase().contains('name')) {
            formData[fieldName] = selection['name'];
          } else if (fieldName.toLowerCase().contains('id')) {
            formData[fieldName] = selection['id'];
          } else {
            // Default: assume it wants the name
            formData[fieldName] = selection['name'];
          }
        }
      }

      print('🚀 Submitting garage report: $formData');

      await ReportsService.submitReport(
        reportId: widget.reportId,
        groupId: int.parse(locationId!),
        data: formData,
      );

      // Simulate submission delay
      // await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        ToastHelper.showSuccess(context, 'Garage report Report submitted successfully! 🎉');

        // Navigate back to reports screen
        Navigator.pop(context);

        // Clear form
        for (var controller in _controllers.values) {
          controller.clear();
        }
        setState(() {
          _selectedDate = null;
          _selectedServiceType = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ToastHelper.showError(
          context,
          'Error submitting report: ${e.toString()}',
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
}
