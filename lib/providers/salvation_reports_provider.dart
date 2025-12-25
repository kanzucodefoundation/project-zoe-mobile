import 'package:flutter/foundation.dart';
import '../models/report.dart';
import '../services/reports_service.dart';

class SalvationReportsProvider extends ChangeNotifier {
  Report? _reportTemplate;
  final List<Map<String, dynamic>> _submissions = [];
  bool _isLoading = false;
  String? _error;
  bool _isSubmitting = false;

  // Getters
  Report? get reportTemplate => _reportTemplate;
  List<Map<String, dynamic>> get submissions => List.unmodifiable(_submissions);
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isSubmitting => _isSubmitting;

  /// Load report data including template and submissions
  Future<void> loadReportData(int reportId) async {
    _setLoading(true);
    _clearError();

    try {
      final templateData = await ReportsService.getReportById(reportId);
      final template = Report.fromJson(templateData.toJson());
      final submissions = await ReportsService.getReportSubmissions(reportId);

      _reportTemplate = template;
      _submissions.clear();
      _submissions.addAll(submissions);

      notifyListeners();
    } catch (e) {
      _setError('Error loading report data: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Submit a salvation report
  Future<bool> submitReport(
    int reportId,
    Map<String, dynamic> formData, {
    int groupId = 0,
  }) async {
    _setSubmitting(true);
    _clearError();

    try {
      await ReportsService.submitReport(
        groupId: groupId,
        reportId: reportId,
        data: formData,
      );

      // Reload data to show the new submission
      await loadReportData(reportId);
      return true;
    } catch (e) {
      _setError('Error submitting report: ${e.toString()}');
      return false;
    } finally {
      _setSubmitting(false);
    }
  }

  /// Clear all data
  void clearData() {
    _reportTemplate = null;
    _submissions.clear();
    _clearError();
    notifyListeners();
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setSubmitting(bool submitting) {
    _isSubmitting = submitting;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}
