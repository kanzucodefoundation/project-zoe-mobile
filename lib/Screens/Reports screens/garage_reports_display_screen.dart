import 'package:flutter/material.dart';
import 'package:project_zoe/models/report.dart';
import 'package:project_zoe/models/reports_model.dart';
import 'package:project_zoe/providers/auth_provider.dart';
import 'package:project_zoe/services/reports_service.dart';
import 'package:provider/provider.dart';
import '../../components/text_field.dart';
import '../../components/submit_button.dart';
import '../../components/custom_date_picker.dart';
import '../../tiles/report_submission_card_tile.dart';

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
  DateTime? _selectedDate;
  bool _isSubmitting = false;

  String? _selectedLocationId;

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

    print('🔍 Garage pre-fill data: $data');

    // Pre-fill text controllers
    data.forEach((key, value) {
      if (key == 'serviceDate' && value != null) {
        try {
          _selectedDate = DateTime.parse(value.toString());
          print('✅ Pre-filled service date: $_selectedDate');
        } catch (e) {
          print('⚠️ Invalid date format: $value');
        }
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
          backgroundColor: Colors.grey.shade50,
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

            _buildLocationPicker(authProvider),
            const SizedBox(height: 20),

            // Generate form fields
            ...visibleFields.map(
              (field) => _buildTemplateFieldWithInput(field),
            ),

            const SizedBox(height: 24),

            // Submit button
            SubmitButton(
              text: _isSubmitting ? 'Submitting...' : 'Submit Report',
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

  Widget _buildLocationPicker(AuthProvider authProvider) {
    final List<Map<String, dynamic>> availableLocations = authProvider
        .getGroupsFromHierarchy('location');

    if (availableLocations.isEmpty) {
      return const Text(
        'No locations available',
        style: TextStyle(color: Colors.red),
      );
    }
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
          hint: Text(
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_selectedLocationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select the location'),
          backgroundColor: Colors.orange,
        ),
      );
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

      print('🚀 Submitting garage report: $formData');

      // TODO: Implement actual submission logic
      // await ReportsService.submitReport(formData);
      await ReportsService.submitReport(
        reportId: widget.reportId,
        groupId: _selectedLocationId != null
            ? int.parse(_selectedLocationId!)
            : 0,
        data: formData,
      );

      // Simulate submission delay
      // await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back to reports screen
        Navigator.pop(context);

        // Clear form
        for (var controller in _controllers.values) {
          controller.clear();
        }
        setState(() {
          _selectedDate = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting report: ${e.toString()}'),
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
}
