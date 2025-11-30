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
    notifyListeners();

    try {
      _reports = await ReportService.getAllReports();
    } catch (e) {
      debugPrint('Failed to load reports from API: $e');
      // Fallback to demo data if API fails
      _loadDemoReports();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load demo reports
  void _loadDemoReports() {
    _reports = [
      Report(
        id: 'rpt_001',
        title: 'Weekly Attendance Summary',
        description:
            'Comprehensive weekly attendance report showing member participation across all services and activities.',
        type: ReportType.attendance,
        status: ReportStatus.completed,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        completedAt: DateTime.now().subtract(const Duration(days: 1)),
        createdBy: 'John Doe',
        assignedTo: 'Jane Smith',
        tags: ['weekly', 'attendance', 'members'],
        priority: 2,
        data: {
          'totalMembers': 450,
          'attendanceRate': 78.5,
          'services': [
            {'name': 'Garage', 'attendance': 380},
            {'name': 'Bible Study', 'attendance': 120},
            {'name': 'MC', 'attendance': 85},
          ],
        },
      ),

      Report(
        id: 'rpt_007',
        title: 'Missional Communities Monthly Report',
        description:
            'Monthly report on Missional Communities activities, outreach efforts, and community engagement initiatives.',
        type: ReportType.general,
        status: ReportStatus.pending,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        createdBy: 'Sarah Johnson',
        assignedTo: 'Mike Wilson',
        tags: ['monthly', 'missional', 'community', 'outreach'],
        priority: 1,
        data: {
          'totalCommunities': 12,
          'activeMembers': 145,
          'newConnections': 23,
          'outreachEvents': 8,
          'prayerRequests': 34,
          'testimonies': 6,
          'communities': [
            {'name': 'Downtown MC', 'members': 15, 'newConnections': 4},
            {'name': 'University MC', 'members': 22, 'newConnections': 8},
            {'name': 'Families MC', 'members': 18, 'newConnections': 3},
            {
              'name': 'Young Professionals MC',
              'members': 20,
              'newConnections': 5,
            },
          ],
        },
      ),
      Report(
        id: 'rpt_002',
        title: 'Monthly Financial Statement',
        description:
            'Detailed financial report covering income, expenses, and fund allocations for the current month.',
        type: ReportType.financial,
        status: ReportStatus.inProgress,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        createdBy: 'Finance Team',
        assignedTo: 'Robert Johnson',
        tags: ['monthly', 'finance', 'budget'],
        priority: 3,
        data: {
          'totalIncome': 25000.0,
          'totalExpenses': 18500.0,
          'balance': 6500.0,
          'categories': [
            {'name': 'Tithes', 'amount': 20000.0},
            {'name': 'Offerings', 'amount': 5000.0},
            {'name': 'Utilities', 'amount': 3500.0},
            {'name': 'Maintenance', 'amount': 2000.0},
          ],
        },
      ),
      Report(
        id: 'rpt_003',
        title: 'New Members Registration',
        description:
            'Report on new member registrations and membership growth trends over the past quarter.',
        type: ReportType.membership,
        status: ReportStatus.pending,
        createdAt: DateTime.now().subtract(const Duration(days: 8)),
        createdBy: 'Membership Committee',
        tags: ['quarterly', 'membership', 'growth'],
        priority: 2,
        data: {
          'newMembers': 28,
          'totalMembers': 450,
          'growthRate': 6.6,
          'ageGroups': [
            {'range': '18-30', 'count': 12},
            {'range': '31-45', 'count': 8},
            {'range': '46-60', 'count': 5},
            {'range': '60+', 'count': 3},
          ],
        },
      ),
      Report(
        id: 'rpt_004',
        title: 'Youth Event Participation',
        description:
            'Analysis of youth participation in recent events and activities including feedback and recommendations.',
        type: ReportType.events,
        status: ReportStatus.completed,
        createdAt: DateTime.now().subtract(const Duration(days: 12)),
        completedAt: DateTime.now().subtract(const Duration(days: 10)),
        createdBy: 'Youth Pastor',
        assignedTo: 'Event Coordinator',
        tags: ['youth', 'events', 'participation'],
        priority: 1,
        data: {
          'eventsCount': 3,
          'totalParticipants': 85,
          'averageRating': 4.2,
          'events': [
            {'name': 'Youth Camp', 'participants': 45, 'rating': 4.5},
            {'name': 'Game Night', 'participants': 25, 'rating': 4.0},
            {'name': 'Community Service', 'participants': 15, 'rating': 4.1},
          ],
        },
      ),
      Report(
        id: 'rpt_005',
        title: 'Shepherds Performance Review',
        description:
            'Quarterly performance review of shepherds including member feedback and pastoral care metrics.',
        type: ReportType.shepherds,
        status: ReportStatus.inProgress,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        createdBy: 'Senior Pastor',
        assignedTo: 'Associate Pastor',
        tags: ['quarterly', 'shepherds', 'performance'],
        priority: 4,
        data: {
          'totalShepherds': 12,
          'averageRating': 4.3,
          'membersPerShepherd': 37.5,
          'completedVisits': 168,
          'pendingVisits': 42,
        },
      ),
      Report(
        id: 'rpt_006',
        title: 'Church Security Assessment',
        description:
            'Annual security assessment report covering physical security, emergency procedures, and safety protocols.',
        type: ReportType.general,
        status: ReportStatus.pending,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        createdBy: 'Security Team',
        tags: ['annual', 'security', 'safety'],
        priority: 3,
        data: {
          'areasAssessed': 8,
          'issuesFound': 3,
          'recommendations': 5,
          'priority': 'medium',
        },
      ),
    ];
    notifyListeners();
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
}
