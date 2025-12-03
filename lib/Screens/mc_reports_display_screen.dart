import 'package:flutter/material.dart';
import '../models/report_template.dart';
import '../services/report_service.dart';

/// MC Reports Display Screen - Shows MC report template and submissions
class McReportsScreen extends StatefulWidget {
  final String reportId;
  const McReportsScreen({super.key, required this.reportId});

  @override
  State<McReportsScreen> createState() => _McReportsScreenState();
}

class _McReportsScreenState extends State<McReportsScreen> {
  ReportTemplate? _reportTemplate;
  List<Map<String, dynamic>> _submissions = [];
  bool _isLoading = true;
  String? _error;
  final Map<int, TextEditingController> _controllers = {};
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadReportData();
  }

  Future<void> _loadReportData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load MC report template (ID: 1)
      final templateData = await ReportService.getReportTemplate(
        widget.reportId,
      );

      if (templateData != null) {
        final template = ReportTemplate.fromJson(templateData);
        final submissions = await ReportService.getReportSubmissions(1);

        setState(() {
          _reportTemplate = template;
          // _submissions = submissions;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load MC report template';
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

  // MC dropdown data
  List<Map<String, dynamic>> _availableMcs = [];
  String? _selectedMcId;
  String? _selectedMcName;
  bool _isLoadingMcs = true;

  /// Load available MCs from server
  Future<void> _loadAvailableMcs() async {
    try {
      print('🔄 MC Form: Starting to load available MCs...');
      // Let server determine church from authenticated user

      final groups = await ReportService.getMCGroups();
      print('✅ MC Form: Groups loaded successfully: $groups');
      setState(() {
        _availableMcs = groups;
        _isLoadingMcs = false;
      });
      print('🎯 MC Form: State updated - MCs ${_availableMcs.toList()}');
    } catch (e) {
      print('❌ MC Form: Error loading MCs: $e');
      setState(() {
        _isLoadingMcs = false;
      });
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

  DateTime? _selectedDate;
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
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
          : _reportTemplate != null
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

          // Submissions Section
          _buildSubmissionsSection(),
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
              // _buildInfoChip('View Type', _reportTemplate!.viewType),
              // _buildInfoChip( 'Status',
              //        _reportTemplate!.status.toUpperCase(),
              //  color: _reportTemplate!.active ? Colors.green : Colors.orange,
              // )
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
    final visibleFields = _reportTemplate!.fields
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
          // Text(
          //   'Fill in all the required fields',
          //   style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          // ),
          const SizedBox(height: 16),
          ...visibleFields.map((field) => _buildFieldItem(field)),
        ],
      ),
    );
  }

  Widget _buildFieldItem(ReportField field) {
    // ensure a controller exists for this field
    final controller = _controllers.putIfAbsent(
      field.id,
      () => TextEditingController(),
    );

    Widget input;
    final t = field.type.toLowerCase();

    if (t == 'date') {
      input = GestureDetector(
        onTap: () => _selectDate(context),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_today, color: Colors.grey),
              const SizedBox(width: 12),
              Text(
                _selectedDate == null
                    ? 'Select date of MC gathering'
                    : '_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                style: TextStyle(
                  fontSize: 16,
                  color: _selectedDate == null ? Colors.grey : Colors.black,
                ),
              ),
            ],
          ),
        ),

        // AbsorbPointer(
        //   child: TextFormField(
        //     controller: controller,
        //     decoration: InputDecoration(
        //       hintText: 'Select ${field.label.toLowerCase()}',
        //       suffixIcon: const Icon(Icons.calendar_today_outlined),
        //     ),
        //     validator: (v) {
        //       if (field.required && (v == null || v.isEmpty)) return 'Required';
        //       return null;
        //     },
        //   ),
        // ),
      );
    } else if (t == 'number' || t == 'numeric') {
      input = TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: field.label,
          // hintText: field.label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.black),
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
    } else if (t == 'textarea' || t == 'text area' || t == 'longtext') {
      input = TextFormField(
        controller: controller,
        keyboardType: TextInputType.multiline,
        maxLines: 4,
        // decoration: InputDecoration(hintText: field.label),
        decoration: InputDecoration(
          labelText: field.label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.black),
          ),
        ),
        validator: (v) {
          if (field.required && (v == null || v.isEmpty)) return 'Required';
          return null;
        },
      );
    } else if (field.name.toLowerCase().contains('smallGroupName')) {
      input = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Missional Community',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
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
                      hint: const Text(
                        'Select MC',
                        style: TextStyle(color: Colors.grey),
                      ),
                      items: _availableMcs.map((mc) {
                        return DropdownMenuItem<String>(
                          value: mc['id']?.toString(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                mc['name'] ?? 'Unknown MC',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              if (mc['description'] != null)
                                Text(
                                  mc['description'],
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          final selectedMc = _availableMcs.firstWhere(
                            (mc) => mc['id']?.toString() == value,
                          );
                          setState(() {
                            _selectedMcId = value;
                            _selectedMcName =
                                selectedMc['name'] ?? 'Unknown MC';
                          });
                        }
                      },
                    ),
                  ),
          ),
        ],
      );
    } else {
      // default to single-line text
      input = TextFormField(
        controller: controller,
        decoration: InputDecoration(hintText: field.label),
        validator: (v) {
          if (field.required && (v == null || v.isEmpty)) return 'Required';
          return null;
        },
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.only(top: 6),
                decoration: BoxDecoration(
                  color: field.required ? Colors.red : Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Row(
                  children: [
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
                    if (field.required) ...[
                      const SizedBox(width: 4),
                      const Text(
                        '*',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          input,
        ],
      ),
    );
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Widget _buildSubmissionsSection() {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recent Submissions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_submissions.length} submissions found',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
              IconButton(
                onPressed: _loadReportData,
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh submissions',
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_submissions.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No submissions yet',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Submit your first MC report to see it here',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Column(
              children: _submissions
                  .take(5)
                  .map((submission) => _buildSubmissionItem(submission))
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildSubmissionItem(Map<String, dynamic> submission) {
    final submissionDate =
        submission['date'] ?? submission['submittedAt'] ?? 'Unknown date';
    final mcName = submission['smallGroupName'] ?? 'Unknown MC';
    final attendance =
        submission['smallGroupAttendanceCount']?.toString() ?? '0';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.assignment, size: 16, color: Colors.blue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mcName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$submissionDate • $attendance attended',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 16),
        ],
      ),
    );
  }
}
