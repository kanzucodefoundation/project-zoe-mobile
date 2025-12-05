import 'package:flutter/material.dart';
import '../models/report_template.dart';
import '../services/report_service.dart';
import '../components/long_button.dart';

/// MC Reports Display Screen - Shows MC report template and submissions
class McReportsScreen extends StatefulWidget {
  final String reportId;
  const McReportsScreen({super.key, required this.reportId});

  @override
  State<McReportsScreen> createState() => _McReportsScreenState();
}

class _McReportsScreenState extends State<McReportsScreen> {
  ReportTemplate? _reportTemplate;
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
      final groups = await ReportService.getMCGroups();
      setState(() {
        _availableMcs = groups;
        _isLoadingMcs = false;
      });
    } catch (e) {
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

  Future<void> _loadReportData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load MC report template with provided ID
      final templateData = await ReportService.getReportTemplate(
        widget.reportId,
      );

      if (templateData != null) {
        final template = ReportTemplate.fromJson(templateData);

        setState(() {
          _reportTemplate = template;
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
              _buildInfoChip('View Type', _reportTemplate!.viewType),
              _buildInfoChip(
                'Status',
                _reportTemplate!.status.toUpperCase(),
                color: _reportTemplate!.active ? Colors.green : Colors.orange,
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
              Icon(
                Icons.calendar_today,
                color: Colors.grey.shade600,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _selectedDate == null
                      ? 'Select date'
                      : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                  style: TextStyle(
                    fontSize: 16,
                    color: _selectedDate == null ? Colors.grey.shade600 : Colors.black87,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_drop_down,
                color: Colors.grey.shade600,
              ),
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
          labelStyle: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
          ),
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
          labelStyle: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
          ),
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        validator: (v) {
          if (field.required && (v == null || v.isEmpty)) return 'Required';
          return null;
        },
      );
    } else if (field.name.toLowerCase().contains('smallgroupname') || field.name.toLowerCase().contains('mc')) {
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
                      setState(() {
                        _selectedMcId = value;
                        _selectedMcName = selectedMc['name'] ?? 'Unknown MC';
                      });
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
          labelStyle: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
          ),
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Collect form data based on field mappings
      String? hostHome;
      int? totalMembers;
      int? attendance;
      String? streamingMethod;
      String? attendeesNames;
      String? visitors;
      String? highlights;
      String? testimonies;
      String? prayerRequests;

      for (var field in _reportTemplate!.fields) {
        final controller = _controllers[field.id];
        final value = controller?.text ?? '';
        
        // Map fields based on their names/types
        final fieldName = field.name.toLowerCase();
        if (fieldName.contains('host')) {
          hostHome = value;
        } else if (fieldName.contains('member')) {
          totalMembers = int.tryParse(value) ?? 0;
        } else if (fieldName.contains('attendance')) {
          attendance = int.tryParse(value) ?? 0;
        } else if (fieldName.contains('streaming')) {
          streamingMethod = value;
        } else if (fieldName.contains('attendees')) {
          attendeesNames = value;
        } else if (fieldName.contains('visitor')) {
          visitors = value;
        } else if (fieldName.contains('highlight')) {
          highlights = value;
        } else if (fieldName.contains('testimon')) {
          testimonies = value;
        } else if (fieldName.contains('prayer')) {
          prayerRequests = value;
        }
      }

      // Submit the report
      await ReportService.submitMcReport(
        gatheringDate: _selectedDate!.toIso8601String().split('T')[0],
        mcName: _selectedMcName!,
        mcId: _selectedMcId,
        hostHome: hostHome ?? '',
        totalMembers: totalMembers ?? 0,
        attendance: attendance ?? 0,
        streamingMethod: streamingMethod,
        attendeesNames: attendeesNames,
        visitors: visitors,
        highlights: highlights,
        testimonies: testimonies,
        prayerRequests: prayerRequests,
      );

      setState(() {
        _isSubmitting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('MC report submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);

    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting report: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
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
