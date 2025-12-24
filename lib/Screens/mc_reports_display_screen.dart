import 'package:flutter/material.dart';
import 'package:project_zoe/models/report.dart';
import 'package:project_zoe/models/reports_model.dart';
import 'package:project_zoe/services/reports_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../components/long_button.dart';

/// MC Reports Display Screen - Shows MC report template and submissions
class McReportsScreen extends StatefulWidget {
  final int reportId;
  const McReportsScreen({super.key, required this.reportId});

  @override
  State<McReportsScreen> createState() => _McReportsScreenState();
}

class _McReportsScreenState extends State<McReportsScreen> {
  Report? _report;
  bool _isLoading = true;
  String? _error;
  final Map<int, TextEditingController> _controllers = {};
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  // MC dropdown data
  List<Map<String, dynamic>> _availableMcs = [];
  String? _selectedMcId;
  String? _selectedMcName;
  bool _isLoadingMcs = true;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _loadReportData();
    _loadAvailableMcs();
  }

  /// Load available MCs from server
  Future<void> _loadAvailableMcs() async {
    try {
      final groups = await ReportsService.getMyGroups();
      if (mounted) {
        setState(() {
          _availableMcs = groups;
          _isLoadingMcs = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingMcs = false;
        });
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load MCs: ${e.toString()}'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      if (mounted) {
        setState(() {
          _selectedDate = picked;
        });
      }
    }
  }

  Future<void> _loadReportData() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      // Load MC report template with provided ID
      final templateData = await ReportsService.getReportById(widget.reportId);

      final template = Report.fromJson(templateData.toJson());

      if (mounted) {
        setState(() {
          _report = template;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading report data: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'MC Reports',
          style: TextStyle(
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
          : _report != null
          ? _buildReportView()
          : const Center(child: Text('No report data found')),
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

  Widget _buildReportView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Report Header Card
          _buildReportHeader(),
          const SizedBox(height: 24),

          // Report Fields
          _buildReportFields(),
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
                child: const Icon(Icons.church, size: 24, color: Colors.blue),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _report!.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _report!.description,
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
              _buildInfoChip('Frequency', _report!.submissionFrequency),
              // _buildInfoChip('View Type', _report!.viewType),
              // _buildInfoChip(
              //   'Status',
              //   _report!.status.toUpperCase(),
              //   color: _report!.active ? Colors.green : Colors.orange,
              // ),
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

  Widget _buildReportFields() {
    final visibleFields = _report!.fields!
        .where((field) => !field.hidden)
        .toList();

    return Form(
      key: _formKey,
      child: Container(
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
            const Text(
              'Fill in all the required fields',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Complete the form below to submit your MC report',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),
            ...visibleFields.map((field) => _buildFieldItem(field)),
            const SizedBox(height: 24),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldItem(ReportField field) {
    // Ensure a controller exists for this field
    final controller = _controllers.putIfAbsent(
      field.id,
      () => TextEditingController(),
    );

    Widget input;
    final fieldType = field.type.toLowerCase();

    // Build different input types based on field type
    if (fieldType == 'date') {
      input = GestureDetector(
        onTap: () => _selectDate(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_today, color: Colors.grey.shade600, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _selectedDate == null
                      ? 'Select date'
                      : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                  style: TextStyle(
                    fontSize: 16,
                    color: _selectedDate == null
                        ? Colors.grey.shade600
                        : Colors.black87,
                  ),
                ),
              ),
              Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
            ],
          ),
        ),
      );
    } else if (fieldType == 'number' || fieldType == 'numeric') {
      input = TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          labelText: field.label,
          labelStyle: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.black, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        validator: (v) {
          if (field.required && (v == null || v.isEmpty)) return 'Required';
          if (v != null && v.isNotEmpty && double.tryParse(v) == null) {
            return 'Must be a number';
          }
          return null;
        },
      );
    } else if (fieldType == 'textarea' || fieldType == 'longtext') {
      input = TextFormField(
        controller: controller,
        keyboardType: TextInputType.multiline,
        maxLines: 4,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          labelText: field.label,
          labelStyle: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.black, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        validator: (v) {
          if (field.required && (v == null || v.isEmpty)) return 'Required';
          return null;
        },
      );
    } else if (field.name.toLowerCase().contains('smallgroupname') ||
        field.name.toLowerCase() == 'smallgroupname') {
      input = Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: _isLoadingMcs
            ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 12),
                    Text('Loading MCs...'),
                  ],
                ),
              )
            : DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _selectedMcId,
                  hint: Text(
                    'Select MC',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  items: _availableMcs.map((mc) {
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
                      final selectedMc = _availableMcs.firstWhere(
                        (mc) => mc['id']?.toString() == value,
                      );
                      if (mounted) {
                        setState(() {
                          _selectedMcId = value;
                          _selectedMcName = selectedMc['name'] ?? 'Unknown MC';
                        });
                      }
                    }
                  },
                ),
              ),
      );
    } else {
      // Default text input
      input = TextFormField(
        controller: controller,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          labelText: field.label,
          labelStyle: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.black, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        validator: (v) {
          if (field.required && (v == null || v.isEmpty)) return 'Required';
          return null;
        },
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!field.name.toLowerCase().contains('smallgroupname')) ...[
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
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
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                if (field.required)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'REQUIRED',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.red,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
          ] else ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'Missional Community',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
          input,
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Column(
      children: [
        LongButton(
          text: 'Submit MC Report',
          onPressed: _submitReport,
          isLoading: _isSubmitting,
          backgroundColor: Colors.black,
          height: 56,
        ),
        const SizedBox(height: 8),
        Text(
          'Please review all information before submitting',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
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

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select the MC gathering date'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_selectedMcId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a Missional Community'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (mounted) {
      setState(() {
        _isSubmitting = true;
      });
    }
    try {
      // Collect form data with exact field names
      final reportData = <String, dynamic>{};

      // // Add selected date - ALWAYS store if selected
      // if (_selectedDate != null) {
      //   reportData['date'] = _selectedDate!.toIso8601String().split('T')[0];
      //   print('✅ Date captured: ${reportData['date']}');
      // } else {
      //   print('❌ No date selected');
      // }

      // // Add selected MC data - ALWAYS store if selected
      // if (_selectedMcName != null && _selectedMcName!.isNotEmpty) {
      //   reportData['smallGroupName'] = _selectedMcName!;
      //   print('✅ MC Name captured: ${reportData['smallGroupName']}');
      // } else {
      //   print('❌ No MC name selected');
      // }

      // if (_selectedMcId != null && _selectedMcId!.isNotEmpty) {
      //   reportData['smallGroupId'] = _selectedMcId!;
      //   print('✅ MC ID captured: ${reportData['smallGroupId']}');
      // } else {
      //   print('❌ No MC ID selected');
      // }

      // Collect all field values using exact field names
      for (var field in _report!.fields!) {
        final controller = _controllers[field.id];
        final value = controller?.text ?? '';

        // Handle different field types properly
        // if (field.type.toLowerCase() == 'number' ||
        //     field.type.toLowerCase() == 'numeric') {
        //   reportData[field.name] = value.isNotEmpty
        //       ? (int.tryParse(value) ?? 0)
        //       : 0;
        // } else
        if (field.name == 'smallGroupName' || field.name == 'smallGroupId') {
          reportData['smallGroupName'] = _selectedMcName;
          reportData['smallGroupId'] = int.tryParse(_selectedMcId!);
          reportData['date'] = _selectedDate?.toIso8601String();
        } else {
          // For text, date, and other field types
          reportData[field.name] = value;
        }
      }

      // Validate required fields before submission
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a date'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isSubmitting = false;
        });
        return;
      }

      if (_selectedMcName == null || _selectedMcName!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select an MC'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isSubmitting = false;
        });
        return;
      }

      // Log the data being sent for debugging
      print('📦 Submitting report data: $reportData');
      print('🆔 Report template ID: ${_report!.id}');
      print('📅 Selected Date: $_selectedDate');
      print('🏠 Selected MC Name: $_selectedMcName');
      print('🆔 Selected MC ID: $_selectedMcId');
      // print('📝 All Controllers:');
      // _controllers.forEach((fieldId, controller) {
      //   print('  Field $fieldId: ${controller.text}');
      // });

      // Submit the report with correct payload structure
      await ReportsService.submitReport(
        reportId: _report!.id,
        groupId: 100, //TODO: Replace with actual group ID
        data: reportData,
      );

      print('✅ Report submission successful with data: $reportData');

      // Store the submitted data locally for display in MC Reports List
      await _storeSubmittedData(reportData);

      // Additional debug: verify what was stored
      print('🔍 === POST-STORAGE VERIFICATION ===');
      print('🔍 Stored MC Name: ${reportData['smallGroupName']}');
      print('🔍 Stored Date: ${reportData['date']}');
      print('🔍 All stored keys: ${reportData.keys.toList()}');

      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('MC report submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }

      // Enhanced error logging for debugging
      print('❌ Report Submission Failed:');
      print('🔍 Error Details: $e');
      print('🆔 Report ID: ${_report!.id}');

      String errorMessage = 'Error submitting report';
      if (e.toString().contains('500') ||
          e.toString().contains('Internal Server Error')) {
        errorMessage = 'Server error - please check your data and try again';
      } else if (e.toString().contains('400') ||
          e.toString().contains('Bad Request')) {
        errorMessage = 'Invalid data format - please check all fields';
      } else if (e.toString().contains('401') ||
          e.toString().contains('Unauthorized')) {
        errorMessage = 'Authentication required - please log in again';
      } else if (e.toString().contains('404') ||
          e.toString().contains('Not Found')) {
        errorMessage =
            'Report template not found - please refresh and try again';
      } else if (e.toString().contains('network') ||
          e.toString().contains('connection')) {
        errorMessage = 'Network error - please check your connection';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$errorMessage: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  /// Store submitted data locally for MC Reports List display
  Future<void> _storeSubmittedData(Map<String, dynamic> reportData) async {
    try {
      // print('🔥 === STORING DATA ===');
      // print('🔥 Input data: $reportData');
      // print('🔥 Report template: ${_report!.name}');
      // print('🔥 MC Name being stored: ${reportData['smallGroupName']}');
      // print('🔥 Date being stored: ${reportData['date']}');
      // print('🔥 Input data keys: ${reportData.keys.toList()}');

      final prefs = await SharedPreferences.getInstance();

      // Create submission object with proper structure including template info
      final submission = {
        'id': DateTime.now().millisecondsSinceEpoch, // Unique ID
        'reportId': _report!.id,
        'reportName': _report!.name,
        'createdAt': DateTime.now().toIso8601String(),
        'data': reportData, // This preserves exact field names
        'template': {
          'id': _report!.id,
          'name': _report!.name,
          'fields': _report!.fields!
              .map(
                (field) => {
                  'id': field.id,
                  'name': field.name,
                  'label': field.label,
                  'type': field.type,
                },
              )
              .toList(),
        },
      };

      print('🔥 Final submission object:');
      print('🔥   ID: ${submission['id']}');
      print('🔥   Report ID: ${submission['reportId']}');
      print('🔥   Data: ${submission['data']}');
      print(
        '🔥   Template fields: ${(submission['template'] as Map)['fields']}',
      );

      // Get existing submissions
      final existingSubmissions =
          prefs.getStringList('mc_report_submissions') ?? [];
      print('🔥 Existing submissions count: ${existingSubmissions.length}');

      // Add new submission
      existingSubmissions.add(json.encode(submission));

      // Store back
      await prefs.setStringList('mc_report_submissions', existingSubmissions);

      // Verify storage
      final verifyList = prefs.getStringList('mc_report_submissions');
      print('🔥 Verification: stored ${verifyList?.length ?? 0} submissions');
      if (verifyList != null && verifyList.isNotEmpty) {
        final lastStored = json.decode(verifyList.last);
        print(
          '🔥 Last stored submission data keys: ${(lastStored['data'] as Map).keys.toList()}',
        );
      }

      print('💾 Stored submission locally: ${submission['id']}');
      print(
        '📊 Stored data keys: ${(submission['data'] as Map).keys.toList()}',
      );
      final template = submission['template'] as Map?;
      print('📋 Template fields: ${template?['fields']}');
    } catch (e) {
      print('❌ Error storing submission locally: $e');
      print('❌ Stack trace: ${StackTrace.current}');
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}
