import '../base_url.dart';

/// Report management related API endpoints
class ReportEndpoints {
  /// Base URL for report endpoints
  static String get _baseUrl => BaseUrl.apiUrl;

  /// Get all reports endpoint - GET /reports
  static String get reports => '$_baseUrl/reports';

  /// Submit report endpoint - POST /reports/submit
  static String get reportsSubmit => '$_baseUrl/reports/submit';

  /// Report categories endpoint - GET /reports/category
  static String get reportsCategories => '$_baseUrl/reports/category';

  // Legacy aliases for backward compatibility
  /// Get all reports endpoint (legacy)
  static String get allReports => reports;

  /// Submit MC report endpoint (legacy)
  static String get submitMcReport => reportsSubmit;

  /// Submit garage attendance report endpoint (legacy)
  static String get submitGarageReport => reportsSubmit;

  /// Submit shepherds report endpoint (legacy)
  static String get submitShepherdsReport => reportsSubmit;

  /// Get report by ID endpoint
  static String getReportById(String reportId) => '$_baseUrl/reports/$reportId';

  /// Update specific report endpoint
  static String updateReportById(String reportId) =>
      '$_baseUrl/reports/$reportId';

  /// Delete specific report endpoint
  static String deleteReportById(String reportId) =>
      '$_baseUrl/reports/$reportId';
}
