import 'package:dio/dio.dart';
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

      // For debugging: return test data when server is unreachable
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        print('🚧 Network issue detected, using test data for debugging');
        return [
          {'id': 4, 'name': 'Jerusalem MC'},
        ];
      }

      // Only throw for other types of errors
      throw _handleDioException(e);
    } catch (e) {
      print('💀 Unexpected error fetching groups: ${e.toString()}');
      print('🚧 Returning test data for debugging');
      return [
        {'id': 4, 'name': 'Jerusalem MC'},
      ];
    }
  }

  /// Get report categories from server
  static Future<List<Map<String, dynamic>>> getReportCategories() async {
    try {
      print('🔍 Fetching categories from /api/reports...');
      final response = await _dio.get('/reports');
      print('✅ Categories response received: ${response.data}');
      print('📊 Response type: ${response.data.runtimeType}');

      // Check if response has categories array
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

      print('⚠️ Using fallback categories');
      // Return default categories if server doesn't provide them
      return [
        {'id': 1, 'name': 'Network'},
        {'id': 2, 'name': 'Cluster'},
        {'id': 3, 'name': 'Location'},
        {'id': 4, 'name': 'Zone'},
        {'id': 5, 'name': 'Missional Community'},
        {'id': 6, 'name': 'Huddle'},
        {'id': 7, 'name': 'Garage Team'},
      ];
    } on DioException catch (e) {
      print('❌ DioException fetching categories: ${e.toString()}');
      print('💥 Error response: ${e.response?.data}');
      print('🔢 Status code: ${e.response?.statusCode}');

      // For debugging: return test data when server is unreachable
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        print('🚧 Network issue detected, using test categories for debugging');
        return [
          {'id': 1, 'name': 'Network'},
          {'id': 2, 'name': 'Cluster'},
          {'id': 3, 'name': 'Location'},
          {'id': 4, 'name': 'Zone'},
          {'id': 5, 'name': 'Missional Community'},
          {'id': 6, 'name': 'Huddle'},
          {'id': 7, 'name': 'Garage Team'},
        ];
      }

      // Only throw for other types of errors
      throw _handleDioException(e);
    } catch (e) {
      print('💀 Unexpected error fetching categories: ${e.toString()}');
      print('🚧 Returning test categories for debugging');
      return [
        {'id': 1, 'name': 'Network'},
        {'id': 2, 'name': 'Cluster'},
        {'id': 3, 'name': 'Location'},
        {'id': 4, 'name': 'Zone'},
        {'id': 5, 'name': 'Missional Community'},
        {'id': 6, 'name': 'Huddle'},
        {'id': 7, 'name': 'Garage Team'},
      ];
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
    final reportData = {
      'type': 'mc_report',
      'gatheringDate': gatheringDate,
      'mcName': mcName,
      'mcId': mcId,
      'hostHome': hostHome,
      'totalMembers': totalMembers,
      'attendance': attendance,
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

  /// Get all reports
  static Future<List<Report>> getAllReports() async {
    try {
      final response = await _dio.get(ReportEndpoints.reports);

      final List<dynamic> reportsData = response.data['reports'] ?? [];
      return reportsData.map((json) => _mapApiResponseToReport(json)).toList();
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

  /// Map API response to Report model
  static Report _mapApiResponseToReport(Map<String, dynamic> json) {
    return Report(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? 'Untitled Report',
      description: json['description'] ?? '',
      type: _mapStringToReportType(json['type']),
      status: _mapStringToReportStatus(json['status']),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'])
          : null,
      createdBy: json['createdBy'] ?? 'Unknown',
      assignedTo: json['assignedTo'],
      tags: List<String>.from(json['tags'] ?? []),
      priority: json['priority'] ?? 2,
      data: Map<String, dynamic>.from(json['data'] ?? {}),
    );
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
    return 'Champions Network';
  }
}
