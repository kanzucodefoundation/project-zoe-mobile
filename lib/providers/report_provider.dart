import 'package:flutter/foundation.dart';

import 'package:project_zoe/services/reports_service.dart';
import '../models/report.dart';

/// Provider for managing reports state and operations
class ReportProvider extends ChangeNotifier {
  /// Initialize provider - load reports from API
  ReportProvider() {
    _loadReportsFromApi();
  }

  List<Report> _reports = [];
  List<Report> get reports => _reports;

  List<Report> _singleReports = [];
  List<Report> get singleReports => _singleReports;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  String? _currentChurch;
  String? get currentChurch => _currentChurch;

  bool _isUsingServerData = false;
  bool get isUsingServerData => _isUsingServerData;

  // ReportStatus? _statusFilter;
  // ReportStatus? get statusFilter => _statusFilter;

  // ReportType? _typeFilter;
  // ReportType? get typeFilter => _typeFilter;

  /// Load reports from API
  Future<void> _loadReportsFromApi() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Don't set church name manually - let server determine from auth
      // ReportService.setChurchName(_currentChurch!);

      _reports = await ReportsService.getAllReports();
      // _reportsTemplate = await ReportService.getReportTemplates();
      _isUsingServerData = true;

      debugPrint('Successfully loaded ${_reports.length} reports from server');
    } catch (e) {
      _error = e.toString();
      debugPrint('Failed to load reports from API: $e');

      // Check if it's a church name error
      if (e.toString().contains('No church name provided')) {
        _error =
            'Server Error: Invalid church name "$_currentChurch". '
            'Try switching to a different church or check server configuration.';
      }

      // Only use server data - no fallback
      _isUsingServerData = false;
      _reports = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get filtered reports
  // List<Report> get filteredReports {
  //   List<Report> filtered = List.from(_reports);

  //   if (_statusFilter != null) {
  //     filtered = ReportHelpers.filterByStatus(filtered, _statusFilter!);
  //   }

  //   if (_typeFilter != null) {
  //     filtered = ReportHelpers.filterByType(filtered, _typeFilter!);
  //   }

  //   // Sort by priority and date
  //   filtered = ReportHelpers.sortByPriority(filtered);
  //   return ReportHelpers.sortByDate(filtered);
  // }

  /// Set status filter
  // void setStatusFilter(ReportStatus? status) {
  //   _statusFilter = status;
  //   notifyListeners();
  // }

  // /// Set type filter
  // void setTypeFilter(ReportType? type) {
  //   _typeFilter = type;
  //   notifyListeners();
  // }

  /// Clear all filters
  // void clearFilters() {
  //   _statusFilter = null;
  //   _typeFilter = null;
  //   notifyListeners();
  // }

  /// Get report by ID
  Future<Report> getReportById(int id) async {
    try {
      _isLoading = true;
      _error = null;

      final report = await ReportsService.getReportById(id);

      _singleReports.add(report);
      notifyListeners();

      return _singleReports.firstWhere((report) => report.id == id);
    } catch (e) {
      _error = 'Failed to load report: ${e.toString()}';
      debugPrint('Failed to load report by ID: $e');
      // rethrow;
      throw Exception('Failed to load report: ${e.toString()}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Map<String, dynamic>> get titleAndId {
    return _reports
        .map((report) => {'id': report.id, 'title': report.name})
        .toList();
  }

  /// Get reports summary
  Map<String, int> get reportsSummary {
    // return ReportHelpers.getReportsSummary(_reports);
    return {};
  }

  /// Get overdue reports
  List<Report> get overdueReports {
    // return ReportHelpers.getOverdueReports(_reports);
    return [];
  }

  /// Update report status
  // Future<void> updateReportStatus(
  //   String reportId,
  //   ReportStatus newStatus,
  // ) async {
  //   _isLoading = true;
  //   _error = null;
  //   notifyListeners();

  //   try {
  //     // Update status via API
  //     await ReportService.updateReportStatus(
  //       reportId: reportId,
  //       status: newStatus.toString().split('.').last,
  //     );

  //     // Update local copy
  //     final reportIndex = _reports.indexWhere(
  //       (report) => report.id == reportId,
  //     );
  //     if (reportIndex != -1) {
  //       _reports[reportIndex] = _reports[reportIndex].copyWith(
  //         status: newStatus,
  //         completedAt: newStatus == ReportStatus.completed
  //             ? DateTime.now()
  //             : null,
  //       );
  //       notifyListeners();
  //     }
  //   } catch (e) {
  //     _error = 'Failed to update report status: ${e.toString()}';
  //     debugPrint('Failed to update report status: $e');
  //   } finally {
  //     _isLoading = false;
  //     notifyListeners();
  //   }
  // }

  /// Refresh reports from API
  Future<void> refreshReports() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _reports = await ReportsService.getAllReports();
    } catch (e) {
      _error = 'Failed to refresh reports: ${e.toString()}';
      debugPrint('Failed to refresh reports: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Retry server connection with current church
  Future<void> retryServerConnection() async {
    await _loadReportsFromApi();
  }
}
