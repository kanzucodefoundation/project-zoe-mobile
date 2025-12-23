import 'package:flutter/material.dart';
import '../models/dashboard_summary.dart';
import '../services/dashboard_service.dart';

enum DashboardStatus { loading, loaded, error }

class DashboardProvider with ChangeNotifier {
  DashboardSummary? _dashboardSummary;
  DashboardStatus _status = DashboardStatus.loading;
  String? _errorMessage;

  DashboardSummary? get dashboardSummary => _dashboardSummary;
  DashboardStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == DashboardStatus.loading;
  bool get hasError => _status == DashboardStatus.error;
  bool get hasData =>
      _status == DashboardStatus.loaded && _dashboardSummary != null;

  /// Load dashboard summary from the API
  Future<void> loadDashboardSummary() async {
    try {
      _status = DashboardStatus.loading;
      _errorMessage = null;
      notifyListeners();

      final summary = await DashboardService.getDashboardSummary();

      _dashboardSummary = summary;
      _status = DashboardStatus.loaded;
      _errorMessage = null;

      notifyListeners();
    } catch (e) {
      _status = DashboardStatus.error;
      _errorMessage = e.toString();
      _dashboardSummary = null;

      print('❌ Dashboard Provider Error: $e');
      notifyListeners();
    }
  }

  /// Refresh dashboard data
  Future<void> refresh() async {
    await loadDashboardSummary();
  }

  /// Clear dashboard data
  void clearDashboard() {
    _dashboardSummary = null;
    _status = DashboardStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }
}
