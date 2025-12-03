import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:frontend/models/report_template.dart';
import '../api/api_client.dart';
import '../api/endpoints/report_endpoints.dart';
import '../models/report.dart';

/// Service class to handle report API calls
class ReportService {
  static final ApiClient _apiClient = ApiClient();
  static Dio get _dio => _apiClient.dio;

  /// Get available groups/MCs from server
  static Future<List<Map<String, dynamic>>> getAvailableGroups() async {
    try {
      print('🔍 Fetching groups from /groups/combo...');
      final response = await _dio.get('/groups/combo');
      print('✅ Groups response received: ${response.data}');
      print('📊 Response type: ${response.data.runtimeType}');

      final List<dynamic> groupsData = response.data ?? [];
      print('📝 Parsed groups count: ${groupsData.length}');

      final result = groupsData
          .map(
            (group) => {
              'id': group['id'],
              'name': group['name'] ?? 'Unknown Group',
            },
          )
          .toList();

      print('🎯 Final groups result: $result');
      return result;
    } on DioException catch (e) {
      print('❌ DioException fetching groups: ${e.toString()}');
      print('💥 Error response: ${e.response?.data}');
      print('🔢 Status code: ${e.response?.statusCode}');
      throw _handleDioException(e);
    } catch (e) {
      print('💀 Unexpected error fetching groups: ${e.toString()}');
      throw Exception('Failed to fetch groups: ${e.toString()}');
    }
  }

  /// Get report categories from server
  static Future<List<Map<String, dynamic>>> getReportCategories() async {
    try {
      print('🔍 Fetching categories from /reports/category...');
      final response = await _dio.get('/reports/category');
      print('✅ Categories response received: ${response.data}');
      print('📊 Response type: ${response.data.runtimeType}');

      // Based on your test data, server returns array directly
      if (response.data is List) {
        print('📋 Response is a List');
        final List<dynamic> categoriesData = response.data;
        final result = categoriesData
            .map(
              (category) => {
                'id': category['id'],
                'name': category['name'] ?? 'Unknown Category',
              },
            )
            .toList();
        print('🎯 Final categories result: $result');
        return result;
      } else if (response.data is Map && response.data['categories'] != null) {
        print('📋 Response is a Map with categories property');
        final List<dynamic> categoriesData = response.data['categories'];
        final result = categoriesData
            .map(
              (category) => {
                'id': category['id'],
                'name': category['name'] ?? 'Unknown Category',
              },
            )
            .toList();
        print('🎯 Final categories result: $result');
        return result;
      }

      print('⚠️ No categories found in server response');
      return [];
    } on DioException catch (e) {
      print('❌ DioException fetching categories: ${e.toString()}');
      print('💥 Error response: ${e.response?.data}');
      print('🔢 Status code: ${e.response?.statusCode}');

      throw _handleDioException(e);
    } catch (e) {
      print('💀 Unexpected error fetching categories: ${e.toString()}');
      throw Exception('Failed to fetch categories: ${e.toString()}');
    }
  }

  /// Submit MC Report to the backend
  static Future<Map<String, dynamic>> submitMcReport({
    required String gatheringDate,
    required String mcName,
    String? mcId,
    required String hostHome,
    required int totalMembers,
    required int attendance,
    String? streamingMethod,
    String? attendeesNames,
    String? visitors,
    String? highlights,
    String? testimonies,
    String? prayerRequests,
  }) async {
    // Map fields to match server expectations based on report template
    final reportData = {
      'reportId': 4, // MC Attendance Report ID from server response
      'date': gatheringDate,
      'smallGroupName': mcName,
      'smallGroupId':
          int.tryParse(mcId ?? '4') ?? 4, // Default to Jerusalem MC id
      'mcHostHome': hostHome,
      'smallGroupNumberOfMembers': totalMembers,
      'smallGroupAttendanceCount': attendance,
      // Additional fields for extended data
      'streamingMethod': streamingMethod ?? '',
      'attendeesNames': attendeesNames ?? '',
      'visitors': visitors ?? '',
      'highlights': highlights ?? '',
      'testimonies': testimonies ?? '',
      'prayerRequests': prayerRequests ?? '',
      'submittedAt': DateTime.now().toIso8601String(),
    };

    try {
      final response = await _dio.post(
        ReportEndpoints.reportsSubmit,
        data: reportData,
      );

      return response.data;
    } on DioException catch (e) {
      // Enhanced error logging for debugging
      print('MC Report Submission Error:');
      print('URL: ${ReportEndpoints.reportsSubmit}');
      print('Request Data: $reportData');
      print('Error Type: ${e.type}');
      print('Status Code: ${e.response?.statusCode}');
      print('Response Data: ${e.response?.data}');
      print('Error Message: ${e.message}');
      throw _handleDioException(e);
    } catch (e) {
      print('Unexpected error in MC report submission: $e');
      throw Exception('Failed to submit MC report: ${e.toString()}');
    }
  }

  /// Get MC report submissions from the server
  static Future<List<Map<String, dynamic>>> getMcReportSubmissions() async {
    try {
      print('🔍 Fetching MC report submissions...');
      final response = await _dio.get('/reports/submissions');
      print('✅ MC submissions response: ${response.data}');

      if (response.data is List) {
        return List<Map<String, dynamic>>.from(response.data);
      }

      return [];
    } on DioException catch (e) {
      print('❌ Error fetching MC submissions: ${e.toString()}');
      print('🔢 Status code: ${e.response?.statusCode}');
      print('💥 Error response: ${e.response?.data}');

      // Return empty list if endpoint doesn't exist yet
      return [];
    } catch (e) {
      print('💀 Unexpected error: ${e.toString()}');
      return [];
    }
  }

  /// Get specific MC report details by MC ID
  static Future<List<Map<String, dynamic>>> getMcReportsByGroupId(
    int groupId,
  ) async {
    try {
      print('🔍 Fetching reports for MC ID: $groupId');
      final response = await _dio.get('/reports/group/$groupId');
      print('✅ MC reports response: ${response.data}');

      if (response.data is List) {
        return List<Map<String, dynamic>>.from(response.data);
      }

      return [];
    } on DioException catch (e) {
      print('❌ Error fetching MC reports: ${e.toString()}');
      print('🔢 Status code: ${e.response?.statusCode}');
      print('💥 Error response: ${e.response?.data}');

      // Return empty list if endpoint doesn't exist yet
      return [];
    } catch (e) {
      print('💀 Unexpected error: ${e.toString()}');
      return [];
    }
  }

  /// Get specific report template by report ID
  static Future<Map<String, dynamic>?> getReportTemplate(
    dynamic reportId,
  ) async {
    try {
      print('🔍 Fetching report template for ID: $reportId');
      final response = await _dio.get('/reports/$reportId');
      print('✅ Report template response: ${response.data}');

      if (response.data is Map<String, dynamic>) {
        return Map<String, dynamic>.from(response.data);
      }

      return null;
    } on DioException catch (e) {
      print('❌ Error fetching report template: ${e.toString()}');
      print('🔢 Status code: ${e.response?.statusCode}');
      print('💥 Error response: ${e.response?.data}');
      return null;
    } catch (e) {
      print('💀 Unexpected error: ${e.toString()}');
      return null;
    }
  }

  /// Get report submissions for a specific report template
  static Future<List<Map<String, dynamic>>> getReportSubmissions(
    int reportId,
  ) async {
    try {
      print('🔍 Fetching submissions for report ID: $reportId');
      final response = await _dio.get('/reports/$reportId/submissions');
      print('✅ Report submissions response: ${response.data}');

      if (response.data is List) {
        return List<Map<String, dynamic>>.from(response.data);
      }

      return [];
    } on DioException catch (e) {
      print('❌ Error fetching report submissions: ${e.toString()}');
      print('🔢 Status code: ${e.response?.statusCode}');
      print('💥 Error response: ${e.response?.data}');
      return [];
    } catch (e) {
      print('💀 Unexpected error: ${e.toString()}');
      return [];
    }
  }

  /// Submit Garage Attendance Report
  static Future<Map<String, dynamic>> submitGarageReport({
    required String date,
    required int attendance,
    required String notes,
  }) async {
    try {
      final reportData = {
        'type': 'garage_report',
        'date': date,
        'attendance': attendance,
        'notes': notes,
        'submittedAt': DateTime.now().toIso8601String(),
      };

      final response = await _dio.post(
        ReportEndpoints.reportsSubmit,
        data: reportData,
      );

      return response.data;
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Failed to submit garage report: ${e.toString()}');
    }
  }

  static Future<List<ReportTemplate>> getReportTemplates() async {
    try {
      final response = await _dio.get(ReportEndpoints.reports);

      // Handle different response formats
      List<dynamic> reportsData;
      if (response.data is List) {
        // Direct array response
        reportsData = response.data;
        // print(reportsData);
        debugPrint('📋 Response is a List with ${reportsData.length} items');
      } else if (response.data is Map && response.data['reports'] != null) {
        // Wrapped in reports property
        reportsData = response.data['reports'];
      } else {
        print(
          '⚠️ Unexpected reports response format: ${response.data.runtimeType}',
        );
        return [];
      }

      print('📋 Processing ${reportsData.length} report items');

      // Try to map each item, skip items that fail parsing
      final reports = <ReportTemplate>[];
      for (var i = 0; i < reportsData.length; i++) {
        try {
          final report = _mapApiResponseToReportTemplate(reportsData[i]);
          reports.add(report);
        } catch (e) {
          print('⚠️ Failed to parse report item $i: $e');
          print('📄 Raw item: ${reportsData[i]}');
          // Continue processing other items
        }
      }

      print('✅ Successfully parsed ${reports.length} reports');
      return reports;
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Failed to fetch reports: ${e.toString()}');
    }
  }

  /// Get all reports
  static Future<List<Report>> getAllReports() async {
    try {
      final response = await _dio.get(ReportEndpoints.reports);

      // Handle different response formats
      List<dynamic> reportsData;
      if (response.data is List) {
        // Direct array response
        reportsData = response.data;
      } else if (response.data is Map && response.data['reports'] != null) {
        // Wrapped in reports property
        reportsData = response.data['reports'];
      } else {
        print(
          '⚠️ Unexpected reports response format: ${response.data.runtimeType}',
        );
        return [];
      }

      print('📋 Processing ${reportsData.length} report items');

      // Try to map each item, skip items that fail parsing
      final reports = <Report>[];
      for (var i = 0; i < reportsData.length; i++) {
        try {
          final report = _mapApiResponseToReport(reportsData[i]);
          reports.add(report);
        } catch (e) {
          print('⚠️ Failed to parse report item $i: $e');
          print('📄 Raw item: ${reportsData[i]}');
          // Continue processing other items
        }
      }

      print('✅ Successfully parsed ${reports.length} reports');
      return reports;
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Failed to fetch reports: ${e.toString()}');
    }
  }

  /// Get report by ID
  static Future<Report> getReportById(String id) async {
    try {
      final response = await _dio.get(ReportEndpoints.getReportById(id));
      return _mapApiResponseToReport(response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Failed to fetch report: ${e.toString()}');
    }
  }

  static Future<ReportTemplate> getReportTempById(String id) async {
    try {
      final response = await _dio.get(ReportEndpoints.getReportById(id));
      return _mapApiResponseToReportTemplate(response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Failed to fetch report: ${e.toString()}');
    }
  }

  /// Update report status
  static Future<Map<String, dynamic>> updateReportStatus({
    required String reportId,
    required String status,
  }) async {
    try {
      final response = await _dio.put(
        ReportEndpoints.updateReportById(reportId),
        data: {'status': status},
      );

      return response.data;
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Failed to update report status: ${e.toString()}');
    }
  }

  /// Map API response to ReportTmeplate model
  static ReportTemplate _mapApiResponseToReportTemplate(
    Map<String, dynamic> json,
  ) {
    try {
      final id = json['id'] ?? '';
      final title = json['name'] ?? json['title'] ?? 'Untitled Report';
      final description = json['description'] ?? '';

      // Map report type using your existing logic
      final typeString = json['functionName'] ?? json['name'] ?? '';
      final type = _mapStringToReportType(typeString);

      // Parse display columns
      final displayColumns = (json['displayColumns'] as List<dynamic>? ?? [])
          .map((c) => DisplayColumn(name: c['name'], label: c['label']))
          .toList();

      // Parse fields
      final fields = (json['fields'] as List<dynamic>? ?? [])
          .map(
            (f) => ReportField(
              id: f['id'],
              name: f['name'],
              type: f['type'],
              label: f['label'] ?? '',
              required: f['required'] ?? false,
              hidden: f['hidden'] ?? false,
              options: f['options'],
            ),
          )
          .toList();

      return ReportTemplate(
        id: id,
        name: title,
        description: description,
        viewType: json['viewType'] ?? 'table',
        status: json['status'],
        functionName: json['functionName'],
        submissionFrequency: json['submissionFrequency'],
        displayColumns: displayColumns,
        fields: fields,
        footer: json['footer'],
        labels: json['labels'],
        dataPoints: json['dataPoints'],
        sqlQuery: json['sqlQuery'],
        active: json['active'] ?? true,
      );
    } catch (e) {
      print('❌ Error mapping template: $e');
      print('📄 Raw JSON: $json');
      throw Exception("Failed to parse report template: ${e.toString()}");
    }
  }

  /// Map API response to Report model
  static Report _mapApiResponseToReport(Map<String, dynamic> json) {
    try {
      // Handle server response format where we get report templates/definitions
      final id = json['id']?.toString() ?? '';
      final title = json['name'] ?? json['title'] ?? 'Untitled Report';
      final description = json['description'] ?? '';

      // Map type based on name or functionName
      final typeString = json['type'] ?? json['name'] ?? '';
      final type = _mapStringToReportType(typeString);

      // Default status for report templates
      final statusString = json['status'] ?? 'active';
      final status = statusString == 'active'
          ? ReportStatus.pending
          : _mapStringToReportStatus(statusString);

      // Handle dates - use current date if not provided (for templates)
      final now = DateTime.now();
      final createdAt = json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? now
          : now;

      final completedAt = json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'])
          : null;

      return Report(
        id: id,
        title: title,
        description: description,
        type: type,
        status: status,
        createdAt: createdAt,
        completedAt: completedAt,
        createdBy: json['createdBy'] ?? 'System',
        assignedTo: json['assignedTo'],
        tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
        priority: json['priority'] ?? 2,
        data: Map<String, dynamic>.from(json['data'] ?? json),
      );
    } catch (e) {
      print('❌ Error mapping report: $e');
      print('📄 Raw JSON: $json');
      throw Exception('Failed to parse report data: ${e.toString()}');
    }
  }

  /// Map string to ReportType enum
  static ReportType _mapStringToReportType(String? type) {
    switch (type?.toLowerCase()) {
      case 'attendance':
        return ReportType.attendance;
      case 'financial':
        return ReportType.financial;
      case 'membership':
        return ReportType.membership;
      case 'events':
        return ReportType.events;
      case 'shepherds':
        return ReportType.shepherds;
      default:
        return ReportType.general;
    }
  }

  /// Map string to ReportStatus enum
  static ReportStatus _mapStringToReportStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return ReportStatus.pending;
      case 'in_progress':
      case 'inprogress':
        return ReportStatus.inProgress;
      case 'completed':
        return ReportStatus.completed;
      case 'overdue':
        return ReportStatus.pending; // Map overdue to pending
      default:
        return ReportStatus.pending;
    }
  }

  /// Handle Dio exceptions and convert to readable messages
  static Exception _handleDioException(DioException e) {
    String message;

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        message = 'Connection timeout. Please check your internet connection.';
        break;
      case DioExceptionType.sendTimeout:
        message = 'Request timeout. Please try again.';
        break;
      case DioExceptionType.receiveTimeout:
        message = 'Response timeout. Please try again.';
        break;
      case DioExceptionType.badResponse:
        message = e.response?.data['message'] ?? 'Server error occurred';
        break;
      case DioExceptionType.cancel:
        message = 'Request was cancelled';
        break;
      case DioExceptionType.connectionError:
        message = 'Connection error. Please check your internet connection.';
        break;
      default:
        message = 'Network error occurred';
    }

    return Exception(message);
  }

  // Church name management for testing different tenants
  static String? _overrideChurchName;

  /// Set church name override for testing
  static void setChurchName(String churchName) {
    _overrideChurchName = churchName;
    // Also set it in the API client for headers
    _apiClient.setTenant(churchName);
  }

  /// Clear church name override
  static void clearChurchNameOverride() {
    _overrideChurchName = null;
    _apiClient.clearTenant();
  }

  /// Get current church name (with override support)
  static Future<String> getChurchName() async {
    if (_overrideChurchName != null) {
      return _overrideChurchName!;
    }
    // Return saved church name or default
    // For now, return a default - this can be enhanced to get from storage
    return 'demo';
  }
}
