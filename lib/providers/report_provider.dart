import 'package:flutter/foundation.dart';
import '../models/report.dart';
import '../helpers/report_helpers.dart';
import '../services/report_service.dart';

/// Provider for managing reports state and operations
class ReportProvider extends ChangeNotifier {
  List<Report> _reports = [];
  List<Report> get reports => _reports;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  String? _currentChurch;
  String? get currentChurch => _currentChurch;

  bool _isUsingServerData = false;
  bool get isUsingServerData => _isUsingServerData;

  ReportStatus? _statusFilter;
  ReportStatus? get statusFilter => _statusFilter;

  ReportType? _typeFilter;
  ReportType? get typeFilter => _typeFilter;

  /// Initialize provider - load reports from API
  ReportProvider() {
    _loadReportsFromApi();
  }

  /// Load reports from API
  Future<void> _loadReportsFromApi() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Get current church name for display
      _currentChurch = await ReportService.getChurchName();

      debugPrint('Loading reports from server for church: $_currentChurch');
      _reports = await ReportService.getAllReports();
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

      // Fallback to demo data if API fails
      _isUsingServerData = false;
      // _loadDemoReports(); // Commented out - using server data only
      _reports = []; // Show empty list instead of demo data
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get filtered reports
  List<Report> get filteredReports {
    List<Report> filtered = List.from(_reports);

    if (_statusFilter != null) {
      filtered = ReportHelpers.filterByStatus(filtered, _statusFilter!);
    }

    if (_typeFilter != null) {
      filtered = ReportHelpers.filterByType(filtered, _typeFilter!);
    }

    // Sort by priority and date
    filtered = ReportHelpers.sortByPriority(filtered);
    return ReportHelpers.sortByDate(filtered);
  }

  /// Set status filter
  void setStatusFilter(ReportStatus? status) {
    _statusFilter = status;
    notifyListeners();
  }

  /// Set type filter
  void setTypeFilter(ReportType? type) {
    _typeFilter = type;
    notifyListeners();
  }

  /// Clear all filters
  void clearFilters() {
    _statusFilter = null;
    _typeFilter = null;
    notifyListeners();
  }

  /// Get report by ID
  Report? getReportById(String id) {
    try {
      return _reports.firstWhere((report) => report.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get reports summary
  Map<String, int> get reportsSummary {
    return ReportHelpers.getReportsSummary(_reports);
  }

  /// Get overdue reports
  List<Report> get overdueReports {
    return ReportHelpers.getOverdueReports(_reports);
  }

  /// Update report status
  Future<void> updateReportStatus(
    String reportId,
    ReportStatus newStatus,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Update status via API
      await ReportService.updateReportStatus(
        reportId: reportId,
        status: newStatus.toString().split('.').last,
      );

      // Update local copy
      final reportIndex = _reports.indexWhere(
        (report) => report.id == reportId,
      );
      if (reportIndex != -1) {
        _reports[reportIndex] = _reports[reportIndex].copyWith(
          status: newStatus,
          completedAt: newStatus == ReportStatus.completed
              ? DateTime.now()
              : null,
        );
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to update report status: ${e.toString()}';
      debugPrint('Failed to update report status: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh reports from API
  Future<void> refreshReports() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _reports = await ReportService.getAllReports();
    } catch (e) {
      _error = 'Failed to refresh reports: ${e.toString()}';
      debugPrint('Failed to refresh reports: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add a new report via API
  Future<void> addReport(Report report) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Submit MC report to API if it's an MC report
      if (report.data.containsKey('mcName')) {
        await ReportService.submitMcReport(
          gatheringDate: report.data['gatheringDate'] ?? '',
          mcName: report.data['mcName'] ?? '',
          mcId: report.data['mcId']?.toString(),
          hostHome: report.data['hostHome'] ?? '',
          totalMembers: report.data['totalMembers'] ?? 0,
          attendance: report.data['attendance'] ?? 0,
          streamingMethod: report.data['streamingMethod'],
          attendeesNames: report.data['attendeesNames'],
          visitors: report.data['visitors'],
          highlights: report.data['highlights'],
          testimonies: report.data['testimonies'],
          prayerRequests: report.data['prayerRequests'],
        );
      } else {
        // For other report types, just add locally for now
        _reports.insert(0, report);
      }

      // Refresh reports from API to get the latest data
      await _loadReportsFromApi();
    } catch (e) {
      // Handle specific error cases for better user experience
      if (e.toString().contains('user not found') ||
          e.toString().contains('User does not exist') ||
          e.toString().contains('404')) {
        _error = 'User not found. Please log out and log back in.';
      } else if (e.toString().contains('unauthorized') ||
          e.toString().contains('401')) {
        _error = 'Authentication failed. Please log in again.';
      } else if (e.toString().contains('network') ||
          e.toString().contains('connection') ||
          e.toString().contains('timeout')) {
        _error =
            'Network error. Please check your internet connection and try again.';
      } else if (e.toString().contains('validation') ||
          e.toString().contains('400')) {
        _error = 'Invalid data. Please check your form and try again.';
      } else {
        _error = 'Failed to submit report: ${e.toString()}';
      }

      debugPrint('Failed to add report: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Switch to a different church for testing
  Future<void> switchChurch(String churchName) async {
    debugPrint('Switching to church: $churchName');
    ReportService.setChurchName(churchName);
    await _loadReportsFromApi();
  }

  /// Try to find a working church automatically
  Future<void> findWorkingChurch() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final testChurches = [
      'Champions Network',
      'WH Naalya',
      'Jerusalem MC',
      'Najjera-Buwate Zone',
      'demo',
    ];

    try {
      for (final church in testChurches) {
        try {
          debugPrint('Testing church: $church');
          ReportService.setChurchName(church);

          // Test if this church works by trying to fetch reports
          final testReports = await ReportService.getAllReports();
          if (testReports.isNotEmpty) {
            _currentChurch = church;
            _reports = testReports;
            _isUsingServerData = true;
            debugPrint(
              'Found working church: $church with ${testReports.length} reports',
            );
            return;
          }
        } catch (e) {
          debugPrint('Church $church failed: $e');
          continue;
        }
      }

      // If no church worked
      _error = 'No working church found. All tested churches failed.';
      _isUsingServerData = false;
      // _loadDemoReports(); // Commented out - show empty list instead
      _reports = [];
    } catch (e) {
      _error = 'Failed to find working church: ${e.toString()}';
      _isUsingServerData = false;
      // _loadDemoReports(); // Commented out - show empty list instead
      _reports = [];
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
