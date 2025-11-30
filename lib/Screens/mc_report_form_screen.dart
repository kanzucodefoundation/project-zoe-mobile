import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/report_provider.dart';
import '../models/report.dart';
import '../services/report_service.dart';

/// MC (Missional Community) Report Form Screen
class McReportFormScreen extends StatefulWidget {
  const McReportFormScreen({super.key});

  @override
  State<McReportFormScreen> createState() => _McReportFormScreenState();
}

class _McReportFormScreenState extends State<McReportFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _hostHomeController = TextEditingController();
  final _totalMembersController = TextEditingController();
  final _attendanceController = TextEditingController();
  final _streamingMethodController = TextEditingController();
  final _attendeesNamesController = TextEditingController();
  final _visitorsController = TextEditingController();
  final _highlightsController = TextEditingController();
  final _testimoniesController = TextEditingController();
  final _prayerRequestsController = TextEditingController();

  DateTime? _selectedDate;
  bool _isLoading = false;

  // MC dropdown data
  List<Map<String, dynamic>> _availableMcs = [];
  String? _selectedMcId;
  String? _selectedMcName;
  bool _isLoadingMcs = true;

  @override
  void initState() {
    super.initState();
    _loadAvailableMcs();
  }

  /// Load available MCs from server
  Future<void> _loadAvailableMcs() async {
    try {
      print('🔄 MC Form: Starting to load available MCs...');
      final groups = await ReportService.getAvailableGroups();
      print('✅ MC Form: Groups loaded successfully: $groups');
      setState(() {
        _availableMcs = groups;
        _isLoadingMcs = false;
      });
      print('🎯 MC Form: State updated - MCs count: ${_availableMcs.length}');
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

  @override
  void dispose() {
    _hostHomeController.dispose();
    _totalMembersController.dispose();
    _attendanceController.dispose();
    _streamingMethodController.dispose();
    _attendeesNamesController.dispose();
    _visitorsController.dispose();
    _highlightsController.dispose();
    _testimoniesController.dispose();
    _prayerRequestsController.dispose();
    super.dispose();
  }

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

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a date for the MC gathering'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_selectedMcId == null || _selectedMcName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an MC from the dropdown'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final reportProvider = Provider.of<ReportProvider>(
        context,
        listen: false,
      );

      final report = Report(
        id: 'mc_${DateTime.now().millisecondsSinceEpoch}',
        title: 'MC Report - $_selectedMcName',
        description:
            'MC Report for $_selectedMcName on ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
        type: ReportType.general,
        status: ReportStatus.pending,
        createdAt: DateTime.now(),
        createdBy: 'Current User', // Replace with actual user
        tags: ['mc', 'missional-community', 'report'],
        priority: 2,
        data: {
          'gatheringDate': _selectedDate!.toIso8601String(),
          'mcId': _selectedMcId!,
          'mcName': _selectedMcName!,
          'hostHome': _hostHomeController.text.trim(),
          'totalMembers': int.tryParse(_totalMembersController.text) ?? 0,
          'attendance': int.tryParse(_attendanceController.text) ?? 0,
          'streamingMethod': _streamingMethodController.text.trim(),
          'attendeesNames': _attendeesNamesController.text.trim(),
          'visitors': _visitorsController.text.trim(),
          'highlights': _highlightsController.text.trim(),
          'testimonies': _testimoniesController.text.trim(),
          'prayerRequests': _prayerRequestsController.text.trim(),
        },
      );

      await reportProvider.addReport(report);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('MC Report submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Error submitting report. Please try again.';

        if (e.toString().contains('user not found') ||
            e.toString().contains('User does not exist') ||
            e.toString().contains('404')) {
          errorMessage = 'User not found. Please log out and log back in.';
        } else if (e.toString().contains('unauthorized') ||
            e.toString().contains('401')) {
          errorMessage = 'Authentication failed. Please log in again.';
        } else if (e.toString().contains('network') ||
            e.toString().contains('connection') ||
            e.toString().contains('timeout')) {
          errorMessage =
              'Network error. Please check your internet connection.';
        } else if (e.toString().contains('validation') ||
            e.toString().contains('400')) {
          errorMessage = 'Invalid data. Please check your form and try again.';
        } else {
          errorMessage = 'Error submitting report: ${e.toString()}';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
          'MC Report',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Container(
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
                            color: Colors.black.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.church,
                            size: 24,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Missional Community Report',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Submit your MC gathering report',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Date Selection
              _buildFormSection(
                title: 'MC Gathering Date',
                children: [
                  GestureDetector(
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
                                : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                            style: TextStyle(
                              fontSize: 16,
                              color: _selectedDate == null
                                  ? Colors.grey
                                  : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Basic Information
              _buildFormSection(
                title: 'Basic Information',
                children: [
                  _buildMcDropdown(),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _hostHomeController,
                    label: 'Host Home',
                    hint: 'Who\'s home hosted the MC?',
                    validator: (value) =>
                        value?.isEmpty == true ? 'Host home is required' : null,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Attendance Information
              _buildFormSection(
                title: 'Attendance',
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildNumberField(
                          controller: _totalMembersController,
                          label: 'Total Members',
                          hint: '0',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildNumberField(
                          controller: _attendanceController,
                          label: 'Members Attended',
                          hint: '0',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _streamingMethodController,
                    label: 'How did you stream the MC?',
                    hint: 'e.g., YouTube, TikTok, FM Radio, etc.',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _attendeesNamesController,
                    label: 'Which Members Attended (Names)',
                    hint: 'List the names of members who attended',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _visitorsController,
                    label: 'Who visited the MC?',
                    hint: 'Names of visitors/new people',
                    maxLines: 2,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Highlights and Testimonies
              _buildFormSection(
                title: 'Highlights & Testimonies',
                children: [
                  _buildTextField(
                    controller: _highlightsController,
                    label: 'General highlights from the MC today',
                    hint: 'Share the key highlights from today\'s MC gathering',
                    maxLines: 4,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _testimoniesController,
                    label: 'Testimonies from the MC (2 to 3)',
                    hint: 'Share 2-3 testimonies from members',
                    maxLines: 5,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _prayerRequestsController,
                    label: 'How may we pray for you?',
                    hint: 'Share challenges, things you believe God for',
                    maxLines: 4,
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Submit MC Report',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormSection({
    required String title,
    required List<Widget> children,
  }) {
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.black),
        ),
      ),
    );
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required String label,
    String? hint,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.black),
        ),
      ),
    );
  }

  Widget _buildMcDropdown() {
    return Column(
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
                          _selectedMcName = selectedMc['name'] ?? 'Unknown MC';
                        });
                      }
                    },
                  ),
                ),
        ),
      ],
    );
  }
}
