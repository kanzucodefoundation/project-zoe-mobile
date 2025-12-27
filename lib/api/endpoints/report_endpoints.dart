import '../base_url.dart';

/// Report management related API endpoints
class ReportEndpoints {
  /// Base URL for report endpoints
  static String get _baseUrl => BaseUrl.apiUrl;

  /// Get all reports endpoint - GET /reports
  static String get reports => '$_baseUrl/reports';

  /// Submit report endpoint - POST /reports/submit
  static String reportsSubmit(int reportId) =>
      '$_baseUrl/reports/$reportId/submissions';

  /// Report categories endpoint - GET /reports/category
  static String get reportsCategories => '$_baseUrl/reports/category';

  // Legacy aliases for backward compatibility
  /// Get all reports endpoint (legacy)
  static String get allReports => reports;

  /// Get report by ID endpoint
  static String getReportById(int reportId) => '$_baseUrl/reports/$reportId';

  /// Get report by ID endpoint
  static String getReportSubmissions(reportId) =>
      '$_baseUrl/reports/submissions/$reportId';

  /// Get MC groups endpoint
  static String get getGroupsForMe => '$_baseUrl/groups/me';

  static String getGroupDetails(int groupId) => '$_baseUrl/groups/$groupId';
}
