import 'package:flutter/material.dart';
import 'package:project_zoe/models/report.dart';
import 'package:project_zoe/models/reports_model.dart';
import 'package:project_zoe/services/reports_service.dart';
import '../../components/text_field.dart';
import '../../components/submit_button.dart';
import '../../components/dropdown.dart';
import '../../components/custom_date_picker.dart';
import '../details_screens/mc_report_detail_screen.dart';

/// MC Attendance Report Screen - Shows MC report template and submissions
class McAttendanceReportScreen extends StatefulWidget {
  final int? reportId;
  const McAttendanceReportScreen({super.key, this.reportId});

  @override
  State<McAttendanceReportScreen> createState() =>
      _McAttendanceReportScreenState();
}

class _McAttendanceReportScreenState extends State<McAttendanceReportScreen> {
  Report? _reportTemplate;
  List<Map<String, dynamic>> _availableMcs = [];
  final Map<int, List<Map<String, dynamic>>> _mcReports = {};
  bool _isLoading = true;
  String? _error;

  // Form related
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  Map<String, dynamic>? _selectedMc;
  DateTime? _selectedDate;
  String? _selectedStreamOption; // For mcStreamPlatform dropdown
  bool _isSubmitting = false;
  bool _isLoadingMcs = false;

  @override
  void initState() {
    super.initState();
    _loadMcData();
  }

  @override
  void dispose() {
    // Dispose all text controllers
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  /// Load MC report template and data
  Future<void> _loadMcData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load MC report template
      if (widget.reportId != null) {
        final templateData = await ReportsService.getReportById(
          widget.reportId!,
        );
        _reportTemplate = Report.fromJson(templateData.toJson());
      }

      // Load available MCs with proper loading state
      setState(() {
        _isLoadingMcs = true;
      });

      try {
        _availableMcs = await ReportsService.getMyAvailableGroups();

        // setState(() {
        //   _isLoadingMcs = false;
        // });
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }

        // Load reports for each MC
        await _loadReportsForAllMcs();
      } catch (e) {
        setState(() {
          _isLoadingMcs = false;
          _availableMcs = [];
        });
        // Don't fail the entire screen, just continue without MC data
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load report template: ${e.toString()}';
        _isLoadingMcs = false;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Load reports for all available MCs
  Future<void> _loadReportsForAllMcs() async {
    for (final mc in _availableMcs) {
      try {} catch (e) {
        _mcReports[mc['id']] = [];
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'MC Attendance Reports',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.refresh, color: Colors.black),
        //     onPressed: _loadMcData,
        //   ),
        // ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading MC reports...', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.red),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadMcData,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    // If we have no template and no data, show empty state
    if (_reportTemplate == null && _availableMcs.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.groups_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No data available',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Could not load report data at this time',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMcData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Report Template Section (if available)
            if (_reportTemplate != null) ...[
              _buildReportHeader(),
              const SizedBox(height: 24),
              _buildReportFieldsWithForm(),
              const SizedBox(height: 24),
            ],
          ],
        ),
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
                  color: Colors.purple.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.church, size: 24, color: Colors.purple),
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
        color: (color ?? Colors.purple).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: color ?? Colors.purple.shade700,
        ),
      ),
    );
  }

  Widget _buildReportFieldsWithForm() {
    if (_reportTemplate?.fields == null) return const SizedBox();

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
              'Fill out the fields below to submit your MC report',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
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

    // Stream field dropdown - check for streaming platform fields
    if (field.name == 'mcStreamPlatform' ||
        fieldName.contains('stream') ||
        fieldLabel.contains('stream') ||
        fieldLabel.contains('how did you stream')) {
      // Convert string options to Map format for Dropdown component
      final dropdownItems = (field.options ?? [])
          .map((option) => {'id': option.toString(), 'name': option.toString()})
          .toList();

      return Dropdown(
        hintText: 'Select ${field.label}',
        items: dropdownItems,
        getDisplayText: (item) => item['name'] ?? 'Unknown Option',
        value: _selectedStreamOption != null
            ? dropdownItems.cast<Map<String, dynamic>?>().firstWhere(
                (item) => item?['name'] == _selectedStreamOption,
                orElse: () => null,
              )
            : null,
        onChanged: (selectedOption) {
          setState(() {
            _selectedStreamOption = selectedOption?['name'];
          });
        },
        validator: field.required
            ? (value) {
                if (value == null) {
                  return 'Please select ${field.label}';
                }
                return null;
              }
            : null,
      );
    }

    // Date picker for date fields
    if (fieldName.contains('date') ||
        fieldLabel.contains('date') ||
        fieldName.contains('gathering') ||
        fieldLabel.contains('gathering')) {
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

    // ONLY MC Name field gets the dropdown - very specific check
    if ((fieldName == 'mcname' ||
            fieldName == 'mc_name' ||
            fieldName.contains('mcname') ||
            fieldLabel == 'mc name' ||
            fieldLabel.contains('mc name')) &&
        !fieldLabel.contains('attended') &&
        !fieldLabel.contains('visit')) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Dropdown(
            hintText: 'Select ${field.label}',
            prefixIcon: Icons.church,
            items: _availableMcs,
            getDisplayText: (mc) => mc['name'] ?? 'Unknown MC',
            value: _selectedMc,
            onChanged: (selectedMc) {
              setState(() {
                _selectedMc = selectedMc;
              });
            },
            validator: field.required
                ? (value) {
                    if (value == null) {
                      return 'Please select ${field.label}';
                    }
                    return null;
                  }
                : null,
            isLoading: _isLoadingMcs,
          ),
          // Debug info
          if (_isLoadingMcs)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Loading MCs from server...',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ),
          if (!_isLoadingMcs && _availableMcs.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'No MCs loaded. Check server connection.',
                style: TextStyle(fontSize: 12, color: Colors.red[600]),
              ),
            ),
          // if (!_isLoadingMcs && _availableMcs.isNotEmpty)
          //   Padding(
          //     padding: const EdgeInsets.only(top: 4),
          //     child: Text(
          //       '${_availableMcs.length} MCs loaded from server',
          //       style: TextStyle(fontSize: 12, color: Colors.green[600]),
          //     ),
          //   ),
        ],
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

    // Regular text field for everything else (including members attended, who visited, etc.)
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

      // Add stream platform selection
      if (_selectedStreamOption != null) {
        formData['mcStreamPlatform'] = _selectedStreamOption;
      }

      // Add MC and report metadata
      if (_selectedMc != null) {
        formData['mcId'] = _selectedMc!['id'];
        formData['mcName'] = _selectedMc!['name'];
      }
      if (_selectedDate != null) {
        formData['gatheringDate'] = _selectedDate!.toIso8601String();
      }
      formData['reportId'] = widget.reportId;
      formData['submittedAt'] = DateTime.now().toIso8601String();

      // TODO: Implement actual submission logic
      // await ReportsService.submitMcReport(formData);

      // Simulate submission delay
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('MC report submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Clear form
        for (var controller in _controllers.values) {
          controller.clear();
        }
        setState(() {
          _selectedMc = null;
          _selectedDate = null;
          _selectedStreamOption = null; // Clear stream selection
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

  void _navigateToMcReportDetail(Map<String, dynamic> mc) {
    final mcId = mc['id'] as int;
    final reports = _mcReports[mcId] ?? [];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => McReportDetailScreen(mc: mc, reports: reports),
      ),
    );
  }
}
