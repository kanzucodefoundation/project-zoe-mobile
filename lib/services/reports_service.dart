import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:project_zoe/models/group.dart';
import 'package:project_zoe/models/report_submission.dart';
import '../api/api_client.dart';
import '../api/endpoints/report_endpoints.dart';
import '../models/report.dart';

/// Service class to handle report API calls
class ReportsService {
  static final ApiClient _apiClient = ApiClient();
  static Dio get _dio => _apiClient.dio;

  /// Get available groups/MCs from server
  static Future<List<Map<String, dynamic>>> getAvailableGroups() async {
    try {
      debugPrint('🔍 Fetching groups from /groups/combo...');
      final response = await _dio.get('/groups/combo');
      // debugPrint('✅ Groups response received: ${response.data}');
      // debugPrint('📊 Response type: ${response.data.runtimeType}');

      final List<dynamic> groupsData = response.data ?? [];
      // debugPrint('📝 Parsed groups count: ${groupsData.length}');

      final result = groupsData
          .map(
            (group) => {
              'id': group['id'],
              'name': group['name'] ?? 'Unknown Group',
            },
          )
          .toList();

      debugPrint('🎯 Final groups result: $result');
      return result;
    } on DioException catch (e) {
      debugPrint('❌ DioException fetching groups: ${e.toString()}');
      debugPrint('💥 Error response: ${e.response?.data}');
      debugPrint('🔢 Status code: ${e.response?.statusCode}');
      throw _handleDioException(e);
    } catch (e) {
      debugPrint('💀 Unexpected error fetching groups: ${e.toString()}');
      throw Exception('Failed to fetch groups: ${e.toString()}');
    }
  }

  // static Future<List<Map<String, dynamic>>> getMCGroups() async {
  //   try {
  //     debugPrint('🔍 Fetching groups from /groups/combo...');
  //     final response = await _dio.get(
  //       '/groups/combo?categories=Missional Community',
  //     );
  //     // debugPrint('✅ Groups response received: ${response.data}');
  //     // debugPrint('📊 Response type: ${response.data.runtimeType}');

  //     final List<dynamic> groupsData = response.data ?? [];
  //     // debugPrint('📝 Parsed groups count: ${groupsData.length}');

  //     final result = groupsData
  //         .map(
  //           (group) => {
  //             'id': group['id'],
  //             'name': group['name'] ?? 'Unknown Group',
  //           },
  //         )
  //         .toList();

  //     debugPrint('🎯 Final groups result: $result');
  //     return result;
  //   } on DioException catch (e) {
  //     debugPrint('❌ DioException fetching groups: ${e.toString()}');
  //     debugPrint('💥 Error response: ${e.response?.data}');
  //     debugPrint('🔢 Status code: ${e.response?.statusCode}');
  //     throw _handleDioException(e);
  //   } catch (e) {
  //     debugPrint('💀 Unexpected error fetching groups: ${e.toString()}');
  //     throw Exception('Failed to fetch groups: ${e.toString()}');
  //   }
  // }

  static Future<List<Map<String, dynamic>>> getMyGroups() async {
    try {
      debugPrint('🔍 Fetching groups from /groups/me');
      final response = await _dio.get(ReportEndpoints.getGroupsForMe);
      debugPrint('✅ My Groups response received: ${response.data}');

      final groupsData = GroupsResponse.fromJson(
        response.data as Map<String, dynamic>,
      );

      debugPrint('📝 Parsed groups count: ${groupsData.groups.length}');
      debugPrint('📊 Total groups: ${groupsData.summary.totalGroups}');
      debugPrint('👥 Total members: ${groupsData.summary.totalMembers}');

      final result = groupsData.groups
          .map((group) => {'id': group.id, 'name': group.name})
          .toList();

      return result;
    } on DioException catch (e) {
      debugPrint('❌ DioException fetching groups: ${e.toString()}');
      debugPrint('💥 Error response: ${e.response?.data}');
      throw _handleDioException(e);
    } catch (e) {
      debugPrint('💀 Unexpected error fetching groups: ${e.toString()}');
      throw Exception('Failed to fetch groups: ${e.toString()}');
    }
  }

  /// Get report categories from server
  static Future<List<Map<String, dynamic>>> getReportCategories() async {
    try {
      debugPrint('🔍 Fetching categories from /reports/category...');
      final response = await _dio.get('/reports/category');
      debugPrint('✅ Categories response received: ${response.data}');
      // debugPrint('📊 Response type: ${response.data.runtimeType}');

      // Based on your test data, server returns array directly
      if (response.data is List) {
        debugPrint('📋 Response is a List');
        final List<dynamic> categoriesData = response.data;
        final result = categoriesData
            .map(
              (category) => {
                'id': category['id'],
                'name': category['name'] ?? 'Unknown Category',
              },
            )
            .toList();
        debugPrint('🎯 Final categories result: $result');
        return result;
      } else if (response.data is Map && response.data['categories'] != null) {
        // debugPrint('📋 Response is a Map with categories property');
        final List<dynamic> categoriesData = response.data['categories'];
        final result = categoriesData
            .map(
              (category) => {
                'id': category['id'],
                'name': category['name'] ?? 'Unknown Category',
              },
            )
            .toList();
        // debugPrint('🎯 Final categories result: $result');
        return result;
      }

      debugPrint('⚠️ No categories found in server response');
      return [];
    } on DioException catch (e) {
      debugPrint('❌ DioException fetching categories: ${e.toString()}');
      debugPrint('💥 Error response: ${e.response?.data}');
      debugPrint('🔢 Status code: ${e.response?.statusCode}');

      throw _handleDioException(e);
    } catch (e) {
      debugPrint('💀 Unexpected error fetching categories: ${e.toString()}');
      throw Exception('Failed to fetch categories: ${e.toString()}');
    }
  }

  /// Submit Report with correct payload structure
  static Future<ReportSubmission> submitReport({
    required int groupId,
    required int reportId,
    required Map<String, dynamic> data,
  }) async {
    final reportPayload = {'groupId': groupId, 'data': data};

    try {
      // debugPrint('📤 Submitting report with payload: $reportPayload');

      final response = await _dio.post(
        ReportEndpoints.reportsSubmit(reportId),
        data: jsonEncode(reportPayload),
      );

      // debugPrint('✅ Report submitted successfully: ${response.data}');
      return ReportSubmission.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      debugPrint('❌ Report Submission Error:');
      debugPrint('📍 URL: ${ReportEndpoints.reportsSubmit}');
      debugPrint('📦 Request Payload: $reportPayload');
      debugPrint('🔥 Error Type: ${e.type}');
      throw _handleDioException(e);
    } catch (e) {
      debugPrint('💀 Unexpected error in report submission: $e');
      throw Exception('Failed to submit report: ${e.toString()}');
    }
  }

  /// Get report submissions for a specific report ID
  static Future<List<Map<String, dynamic>>> getReportSubmissions(
    int reportId,
  ) async {
    try {
      final response = await _dio.get(
        ReportEndpoints.getReportSubmissions(reportId),
      );
      debugPrint('✅ Report submissions response: ${response.data}');

      if (response.data is List) {
        return List<Map<String, dynamic>>.from(response.data);
      }

      return [];
    } on DioException catch (e) {
      debugPrint('❌ Error fetching report submissions: ${e.toString()}');
      debugPrint('🔢 Status code: ${e.response?.statusCode}');
      debugPrint('💥 Error response: ${e.response?.data}');
      return [];
    } catch (e) {
      debugPrint('💀 Unexpected error: ${e.toString()}');
      return [];
    }
  }

  /**
  * NEW REPORTS MOCK API
  */
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
        return [];
      }

      debugPrint('📋 Processing ${reportsData.length} report items');

      // Try to map each item, skip items that fail parsing
      final reports = <Report>[];
      for (var i = 0; i < reportsData.length; i++) {
        try {
          final report = Report.fromJson(
            reportsData[i] as Map<String, dynamic>,
          );
          reports.add(report);
        } catch (e) {
          debugPrint('⚠️ Failed to parse report item $i: $e');
          debugPrint('📄 Raw item: ${reportsData[i]}');
          // Continue processing other items
        }
      }

      debugPrint('✅ Successfully parsed ${reports.length} reports');
      return reports;
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Failed to fetch reports: ${e.toString()}');
    }
  }

  /// Get report defination by ID
  static Future<Report> getReportById(int id) async {
    try {
      final response = await _dio.get(ReportEndpoints.getReportById(id));
      return Report.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Failed to fetch report: ${e.toString()}');
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

  // // Church name management for testing different tenants
  // static String? _overrideChurchName;

  // /// Set church name override for testing
  // static void setChurchName(String churchName) {
  //   _overrideChurchName = churchName;
  //   // Also set it in the API client for headers
  //   _apiClient.setTenant(churchName);
  // }

  // /// Clear church name override
  // static void clearChurchNameOverride() {
  //   _overrideChurchName = null;
  //   _apiClient.clearTenant();
  // }

  // /// Get current church name (with override support)
  // static Future<String> getChurchName() async {
  //   if (_overrideChurchName != null) {
  //     return _overrideChurchName!;
  //   }
  //   // Return saved church name or default
  //   // For now, return a default - this can be enhanced to get from storage
  //   return 'demo';
  // }
}
