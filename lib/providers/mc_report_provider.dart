import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/report_template.dart';
import '../services/report_service.dart';

class McReportProvider with ChangeNotifier {
  // Report template data
  ReportTemplate? _reportTemplate;
  bool _isLoading = true;
  String? _error;
  bool _isSubmitting = false;

  // MC dropdown data
  List<Map<String, dynamic>> _availableMcs = [];
  String? _selectedMcId;
  String? _selectedMcName;
  bool _isLoadingMcs = true;
  DateTime? _selectedDate;

  // Form data
  final Map<int, String> _fieldValues = {};

  // Getters
  ReportTemplate? get reportTemplate => _reportTemplate;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isSubmitting => _isSubmitting;
  List<Map<String, dynamic>> get availableMcs => _availableMcs;
  String? get selectedMcId => _selectedMcId;
  String? get selectedMcName => _selectedMcName;
  bool get isLoadingMcs => _isLoadingMcs;
  DateTime? get selectedDate => _selectedDate;
  Map<int, String> get fieldValues => _fieldValues;

  /// Load report template data
  Future<void> loadReportData(String reportId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final templateData = await ReportService.getReportTemplate(
        int.parse(reportId),
      );

      if (templateData != null) {
        _reportTemplate = ReportTemplate.fromJson(templateData);
      } else {
        throw Exception('Report template not found');
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load report: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load available MCs from server
  Future<void> loadAvailableMcs() async {
    try {
      final groups = await ReportService.getMCGroups();
      _availableMcs = groups;
      _isLoadingMcs = false;
      notifyListeners();
    } catch (e) {
      _isLoadingMcs = false;
      notifyListeners();
    }
  }

  /// Set selected MC
  void setSelectedMc(String mcId, String mcName) {
    _selectedMcId = mcId;
    _selectedMcName = mcName;
    notifyListeners();
  }

  /// Set selected date
  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  /// Update field value
  void updateFieldValue(int fieldId, String value) {
    _fieldValues[fieldId] = value;
    notifyListeners();
  }

  /// Submit report
  Future<bool> submitReport() async {
    try {
      _isSubmitting = true;
      notifyListeners();

      // Validate required fields
      if (_selectedDate == null) {
        throw Exception('Please select a date');
      }

      if (_selectedMcName == null || _selectedMcName!.isEmpty) {
        throw Exception('Please select an MC');
      }

      // Collect form data with exact field names
      final reportData = <String, dynamic>{};

      // Add selected date
      if (_selectedDate != null) {
        reportData['date'] = _selectedDate!.toIso8601String().split('T')[0];
      }

      // Add selected MC data
      if (_selectedMcName != null && _selectedMcName!.isNotEmpty) {
        reportData['smallGroupName'] = _selectedMcName!;
      }

      if (_selectedMcId != null && _selectedMcId!.isNotEmpty) {
        reportData['smallGroupId'] = _selectedMcId!;
      }

      // Collect all field values using exact field names
      if (_reportTemplate != null) {
        for (var field in _reportTemplate!.fields) {
          final value = _fieldValues[field.id] ?? '';

          // Handle different field types properly
          if (field.type.toLowerCase() == 'number' ||
              field.type.toLowerCase() == 'numeric') {
            reportData[field.name] = value.isNotEmpty
                ? (int.tryParse(value) ?? 0)
                : 0;
          } else if (field.type.toLowerCase() == 'dropdown') {
            // For dropdown fields, check if we have a selected value
            if (field.name == 'smallGroupName') {
              // This is handled by the MC dropdown above, skip
              continue;
            } else {
              // For other dropdown fields, use the field value
              reportData[field.name] = value.isNotEmpty ? value : '';
            }
          } else {
            // For text, date, and other field types
            reportData[field.name] = value;
          }
        }
      }

      // Submit the report with correct payload structure
      await ReportService.submitReport(
        reportId: _reportTemplate!.id,
        data: reportData,
      );

      // Store the submitted data locally for display in MC Reports List
      await _storeSubmittedData(reportData);

      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isSubmitting = false;
      notifyListeners();
      throw e;
    }
  }

  /// Store submitted data locally for offline viewing
  Future<void> _storeSubmittedData(Map<String, dynamic> reportData) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Create a submission record with timestamp
      final submission = {
        'timestamp': DateTime.now().toIso8601String(),
        'mcName': reportData['smallGroupName'],
        'selectedDate': reportData['date'],
        'sections': [
          {
            'sectionTitle': 'MC Report Details',
            'fields': reportData.entries
                .map(
                  (entry) => {
                    'label': entry.key,
                    'value': entry.value?.toString() ?? '',
                  },
                )
                .toList(),
          },
        ],
      };

      // Get existing submissions
      final existingSubmissions = prefs.getStringList('reports_list') ?? [];

      // Add new submission
      existingSubmissions.add(json.encode(submission));

      // Save back to preferences
      await prefs.setStringList('reports_list', existingSubmissions);
    } catch (e) {
      // Don't throw here as the main submission was successful
    }
  }

  /// Clear form data
  void clearForm() {
    _selectedMcId = null;
    _selectedMcName = null;
    _selectedDate = null;
    _fieldValues.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
