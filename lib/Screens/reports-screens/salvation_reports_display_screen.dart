import 'package:flutter/material.dart';
import 'package:project_zoe/providers/auth_provider.dart';
import 'package:provider/provider.dart';

import '../../components/submit_button.dart';
import '../../components/custom_date_picker.dart';
import '../../providers/salvation_reports_provider.dart';
import '../../widgets/custom_toast.dart';

/// Salvation Reports Display Screen - Shows Salvation report template and submissions
class SalvationReportsScreen extends StatefulWidget {
  final int reportId;
  final Map<String, dynamic>? editingSubmission;

  const SalvationReportsScreen({
    super.key,
    required this.reportId,
    this.editingSubmission,
  });

  @override
  State<SalvationReportsScreen> createState() => _SalvationReportsScreenState();
}

class _SalvationReportsScreenState extends State<SalvationReportsScreen> {
  // Form related
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  DateTime? _selectedDate;
  String? _selectedLocationId;
  String? _selectedContextOption;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<SalvationReportsProvider>();
      provider.loadReportData(widget.reportId);

      // If we're editing, pre-fill the form with existing data
      if (widget.editingSubmission != null) {
        _preFillFormForEditing();
      }
    });
  }

  void _preFillFormForEditing() {
    final submission = widget.editingSubmission!;
    final data = submission['data'] as Map<String, dynamic>? ?? {};

    debugPrint('🔍 Salvation pre-fill data: $data');

    if (submission['groupId'] != null) {
      _selectedLocationId = submission['groupId'].toString();
      debugPrint('✅ Pre-filled salvation locationId: $_selectedLocationId');
    }
    // Pre-fill text controllers
    data.forEach((key, value) {
      if (key == 'salvationDate' && value != null) {
        try {
          _selectedDate = DateTime.parse(value.toString());
          debugPrint('✅ Pre-filled salvation date: $_selectedDate');
        } catch (e) {
          debugPrint('⚠️ Invalid date format: $value');
        }
      } else if (key == 'salvationContext' && value != null) {
        _selectedContextOption = value.toString();
        debugPrint(
          '✅ Pre-filled salvation context option: $_selectedContextOption',
        );
      } else if (value != null && value.toString().isNotEmpty) {
        // Create controller if doesn't exist and pre-fill
        if (!_controllers.containsKey(key)) {
          _controllers[key] = TextEditingController();
        }
        final controller = _controllers[key];
        if (controller != null) {
          controller.text = value.toString();
        }
        debugPrint(
          '✅ Pre-filled salvation field $key with: ${value.toString()}',
        );
      }
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<SalvationReportsProvider, AuthProvider>(
      builder: (context, provider, authProvider, child) {
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
                  ? 'Edit Salvation Report'
                  : 'Salvation Reports',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : provider.error != null
              ? _buildErrorView(provider)
              : provider.reportTemplate != null
              ? _buildReportView(provider, authProvider)
              : const Center(child: Text('No report data found')),
        );
      },
    );
  }

  Widget _buildErrorView(SalvationReportsProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(
              'Unable to load report',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              provider.error!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.red.shade600,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => provider.loadReportData(widget.reportId),
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

  Widget _buildReportView(
    SalvationReportsProvider provider,
    AuthProvider authProvider,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildReportHeader(provider),
          const SizedBox(height: 24),
          _buildReportFieldsWithForm(provider, authProvider),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildReportHeader(SalvationReportsProvider provider) {
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
                  color: Colors.green.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.emoji_events,
                  size: 24,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      provider.reportTemplate!.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      provider.reportTemplate!.description,
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
              _buildInfoChip(
                'Frequency',
                provider.reportTemplate!.submissionFrequency,
              ),
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
        color: (color ?? Colors.green).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: color ?? Colors.green.shade700,
        ),
      ),
    );
  }

  Widget _buildReportFieldsWithForm(
    SalvationReportsProvider provider,
    AuthProvider authProvider,
  ) {
    // Add null safety check
    if (provider.reportTemplate?.fields == null) {
      return const SizedBox.shrink();
    }

    final visibleFields = provider.reportTemplate!.fields!
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

            // Missional Community selection with label
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
                    'Missional Community',
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
              text: provider.isSubmitting ? 'Submitting...' : 'Submit Report',
              onPressed: provider.isSubmitting ? () {} : _submitReport,
              backgroundColor: Colors.black,
              textColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationPicker(AuthProvider authProvider) {
    final List<Map<String, dynamic>> availableLocations = authProvider
        .getGroupsFromHierarchy('fellowship');

    // if (availableLocations.isEmpty) {
    //   return const Text(
    //     'No Missional Community available',
    //     style: TextStyle(color: Colors.red),
    //   );
    // }
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
                  'No Missional Community available',
                  style: TextStyle(color: Colors.red),
                )
              : Text(
                  'Select Missional Community',
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
    final fieldLabel = field.label.toLowerCase();

    if (field.type == 'date') {
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

    if (field.type == 'select') {
      final availableOptions = field.options as List<dynamic>? ?? [];

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(25),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,
            value: _selectedContextOption,
            hint: Text(
              'Select $fieldLabel option',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            items: availableOptions.map((option) {
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
              if (value != null) {
                if (mounted) {
                  setState(() {
                    _selectedContextOption = value;
                  });
                }
              }
            },
          ),
        ),
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

    return TextFormField(
      controller:
          _controllers[field.name], // Changed from field.label to field.name
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

  void _submitReport() async {
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) {
      ToastHelper.showWarning(context, 'Please fill in all required fields');
      return;
    }

    if (_selectedLocationId == null) {
      ToastHelper.showWarning(context, 'Please select the Missonal Community');
      return;
    }

    if (_selectedContextOption == null) {
      ToastHelper.showWarning(context, 'Please select the Context option');
      return;
    }

    final data = <String, dynamic>{};
    for (var entry in _controllers.entries) {
      data[entry.key] = entry.value.text;
    }

    // Add date if selected
    if (_selectedDate != null) {
      data['salvationDate'] = _selectedDate!.toIso8601String();
    }

    // Add context option if selected
    if (_selectedContextOption != null) {
      data['salvationContext'] = _selectedContextOption;
    }

    final provider = Provider.of<SalvationReportsProvider>(
      context,
      listen: false,
    );

    // Parse location ID safely
    int? groupId;
    try {
      groupId = int.parse(_selectedLocationId ?? '');
    } catch (e) {
      ToastHelper.showError(context, 'Invalid Missional Community selected');
      return;
    }

    final success = await provider.submitReport(
      groupId: groupId,
      reportId: widget.reportId,
      data: data,
    );

    if (success) {
      if (mounted) {
        ToastHelper.showSuccess(context, 'Report submitted successfully! ✨');
        // Navigate back to reports screen
        Navigator.pop(context);
      }
      // Clear form after successful submission
      _formKey.currentState?.reset();
      for (var controller in _controllers.values) {
        controller.clear();
      }
      setState(() {
        _selectedDate = null;
      });
    } else {
      if (mounted) {
        ToastHelper.showError(
          context,
          'Failed to submit report: ${provider.error ?? 'Unknown error'}',
        );
      }
    }
  }
}
