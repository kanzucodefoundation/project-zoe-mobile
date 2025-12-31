import 'package:flutter/material.dart';
import 'package:project_zoe/models/report.dart';
import 'package:project_zoe/providers/auth_provider.dart';
import 'package:project_zoe/services/reports_service.dart';
import 'package:provider/provider.dart';

import '../../components/submit_button.dart';
import '../../components/custom_date_picker.dart';

/// Baptism Reports Display Screen - Shows Baptism report template and submissions
class BaptismReportsScreen extends StatefulWidget {
  final int reportId;
  final Map<String, dynamic>? editingSubmission;

  const BaptismReportsScreen({
    super.key,
    required this.reportId,
    this.editingSubmission,
  });

  @override
  State<BaptismReportsScreen> createState() => _BaptismReportsScreenState();
}

class _BaptismReportsScreenState extends State<BaptismReportsScreen> {
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

    // print('🔍 Pre-fill data: $submission');

    if (submission['groupId'] != null) {
      _selectedLocationId = submission['groupId'].toString();
      print('✅ Pre-filled location ID: $_selectedLocationId');
    }

    // Pre-fill text controllers
    data.forEach((key, value) {
      if (key == 'date' && value != null) {
        try {
          _selectedDate = DateTime.parse(value.toString());
          print('✅ Pre-filled date: $_selectedDate');
        } catch (e) {
          print('⚠️ Invalid date format: $value');
        }
      } else if (value != null && value.toString().isNotEmpty) {
        // Create controller if doesn't exist and pre-fill
        if (!_controllers.containsKey(key)) {
          _controllers[key] = TextEditingController();
        }
        _controllers[key]!.text = value.toString();
        print('✅ Pre-filled field $key with: ${value.toString()}');
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
                  ? 'Edit Baptism Report'
                  : 'Baptism Reports',
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
          _buildReportHeader(),
          const SizedBox(height: 24),
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
                  color: Colors.blue.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.water_drop,
                  size: 24,
                  color: Colors.blue,
                ),
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
        color: (color ?? Colors.blue).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: color ?? Colors.blue.shade700,
        ),
      ),
    );
  }

  Widget _buildReportFieldsWithForm(AuthProvider authProvider) {
    // Add null safety checks
    if (_reportTemplate?.fields == null) {
      return const SizedBox.shrink();
    }

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
            ...visibleFields.map(
              (field) => _buildTemplateFieldWithInput(field),
            ),
            const SizedBox(height: 24),
            SubmitButton(
              text: _isSubmitting
                  ? (widget.editingSubmission != null
                        ? 'Updating...'
                        : 'Submitting...')
                  : (widget.editingSubmission != null
                        ? 'Update Report'
                        : 'Submit Report'),
              onPressed: _isSubmitting ? () {} : _submitReport,
              backgroundColor: Colors.black,
              textColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateFieldWithInput(field) {
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
          _buildInputForField(field),
        ],
      ),
    );
  }

  Widget _buildInputForField(field) {
    final fieldName = field.name.toLowerCase();
    final fieldLabel = field.label.toLowerCase();

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

    if (!_controllers.containsKey(field.name)) {
      _controllers[field.name] = TextEditingController();
    }

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

    // Default single line text input
    return TextFormField(
      controller: _controllers[field.name],
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
        hintStyle: TextStyle(color: Colors.grey[500]),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _buildLocationPicker(AuthProvider authProvider) {
    final List<Map<String, dynamic>> availableLocations = authProvider
        .getGroupsFromHierarchy('location');
    // if (ed) {}

    // When editing, ensure the current location is included
    //- if U don not have access, this will not occur
    /*if (widget.editingSubmission != null &&
        widget.editingSubmission!['groupId'] != null) {
      final editingGroupId = widget.editingSubmission!['groupId'];
      if (!availableLocations.any((mc) => mc['id'] == editingGroupId)) {
        final editingGroup = ReportsService.getGroupDetails(editingGroupId);
        if (editingGroup != null) {
          availableLocations.add();
        }
      }
    }*/

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

  void _submitReport() async {
    // Add null safety check for form state
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) {
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

    final data = <String, dynamic>{};
    for (var entry in _controllers.entries) {
      data[entry.key] = entry.value.text;
    }

    if (_selectedDate != null) {
      data['date'] = _selectedDate!.toIso8601String();
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Using report service to submit
      await ReportsService.submitReport(
        groupId: int.parse(
          _selectedLocationId!,
        ), // Safe to use ! here after null check above
        reportId: widget.reportId,
        data: data,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Baptism report submitted successfully'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back to reports screen
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to submit report: $e')));
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  // Widget _buildSubmissionsSection() {
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
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 const Text(
  //                   'Recent Submissions',
  //                   style: TextStyle(
  //                     fontSize: 18,
  //                     fontWeight: FontWeight.bold,
  //                     color: Colors.black,
  //                   ),
  //                 ),
  //                 const SizedBox(height: 4),
  //                 Text(
  //                   '${_submissions.length} submissions found',
  //                   style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
  //                 ),
  //               ],
  //             ),
  //             IconButton(
  //               onPressed: _loadReportData,
  //               icon: const Icon(Icons.refresh),
  //               tooltip: 'Refresh submissions',
  //             ),
  //           ],
  //         ),
  //         const SizedBox(height: 16),
  //         if (_submissions.isEmpty)
  //           Center(
  //             child: Padding(
  //               padding: const EdgeInsets.symmetric(vertical: 24),
  //               child: Column(
  //                 children: [
  //                   Icon(
  //                     Icons.inbox_outlined,
  //                     size: 48,
  //                     color: Colors.grey.shade400,
  //                   ),
  //                   const SizedBox(height: 16),
  //                   Text(
  //                     'No submissions yet',
  //                     style: TextStyle(
  //                       fontSize: 16,
  //                       fontWeight: FontWeight.w500,
  //                       color: Colors.grey.shade600,
  //                     ),
  //                   ),
  //                   const SizedBox(height: 8),
  //                   Text(
  //                     'Submit your first Baptism report to see it here',
  //                     style: TextStyle(
  //                       fontSize: 14,
  //                       color: Colors.grey.shade500,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           )
  //         else
  //           Column(
  //             children: _submissions
  //                 .take(5)
  //                 .map((submission) => _buildSubmissionItem(submission))
  //                 .toList(),
  //           ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildSubmissionItem(Map<String, dynamic> submission) {
  //   final submissionDate =
  //       submission['date'] ?? submission['submittedAt'] ?? 'Unknown date';
  //   final title = submission['title'] ?? 'Baptism Report';
  //   final count = submission['baptismCount']?.toString() ?? '0';

  //   return Container(
  //     margin: const EdgeInsets.only(bottom: 8),
  //     padding: const EdgeInsets.all(12),
  //     decoration: BoxDecoration(
  //       color: Colors.grey.shade50,
  //       borderRadius: BorderRadius.circular(8),
  //       border: Border.all(color: Colors.grey.shade200),
  //     ),
  //     child: Row(
  //       children: [
  //         Container(
  //           padding: const EdgeInsets.all(8),
  //           decoration: BoxDecoration(
  //             color: Colors.blue.withValues(alpha: 0.1),
  //             borderRadius: BorderRadius.circular(6),
  //           ),
  //           child: const Icon(Icons.water_drop, size: 16, color: Colors.blue),
  //         ),
  //         const SizedBox(width: 12),
  //         Expanded(
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text(
  //                 title,
  //                 style: const TextStyle(
  //                   fontSize: 14,
  //                   fontWeight: FontWeight.w500,
  //                   color: Colors.black87,
  //                 ),
  //               ),
  //               const SizedBox(height: 2),
  //               Text(
  //                 '$submissionDate • $count baptisms',
  //                 style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
  //               ),
  //             ],
  //           ),
  //         ),
  //         Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 16),
  //       ],
  //     ),
  //   );
  // }
}
