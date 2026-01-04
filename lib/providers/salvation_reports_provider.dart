import 'package:flutter/foundation.dart';
import '../models/report.dart';
import '../services/reports_service.dart';

class SalvationReportsProvider extends ChangeNotifier {
  Report? _reportTemplate;
  bool _isLoading = false;
  String? _error;
  bool _isSubmitting = false;

  // Getters
  Report? get reportTemplate => _reportTemplate;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isSubmitting => _isSubmitting;

  /// Load report template for creating new submissions
  Future<void> loadReportData(int reportId) async {
    _setLoading(true);
    _clearError();

    try {
      final templateData = await ReportsService.getReportById(reportId);
      final template = Report.fromJson(templateData.toJson());

      _reportTemplate = template;
      notifyListeners();
    } catch (e) {
      _setError('Error loading report template: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Submit a salvation report
  Future<bool> submitReport({
    required int groupId,
    required int reportId,
    required Map<String, dynamic> data,
  }) async {
    _setSubmitting(true);
    _clearError();

    try {
      await ReportsService.submitReport(
        groupId: groupId,
        reportId: reportId,
        data: data,
      );

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
