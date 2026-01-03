import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:project_zoe/models/group.dart';
import 'package:project_zoe/models/report_submission.dart';
import 'package:project_zoe/models/report_submissions_response%20.dart';
import 'package:project_zoe/providers/auth_provider.dart';
import '../api/api_client.dart';
import '../api/endpoints/report_endpoints.dart';
import '../models/report.dart';

/// Service class to handle report API calls
class ReportsService {
  static final ApiClient _apiClient = ApiClient();
  static Dio get _dio => _apiClient.dio;

  static Future<List<Group>> getAllGroups() async {
    try {
      debugPrint('🔍 Fetching groups from /groups...');
      final response = await _dio.get('/groups');

      // Handle the new API response structure: { groups: [...], summary: {...} }
      final Map<String, dynamic> responseData = response.data ?? {};
      final List<dynamic> groupsData = responseData['groups'] ?? [];
      debugPrint('📝 Parsed groups count: ${groupsData.length}');

      final result = groupsData
          .map((group) => Group.fromJson(group as Map<String, dynamic>))
          .toList();

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

  /// Get available groups/MCs from server
  static Future<List<Map<String, dynamic>>> getMyAvailableGroups() async {
    try {
      debugPrint('🔍 Fetching groups from /groups/me...');
      final response = await _dio.get('/groups/me');
      debugPrint('✅ Groups response received: ${response.data}');
      debugPrint('📊 Response type: ${response.data.runtimeType}');

      // Handle the new API response structure: direct array
      final List<dynamic> groupsData = response.data ?? [];
      debugPrint('📝 Parsed groups count: ${groupsData.length}');

      final result = groupsData
          .map(
            (group) => {
              'id': group['id'],
              'name': group['name'] ?? 'Unknown Group',
              'type': group['type'] ?? 'Unknown Type',
              'categoryName': group['categoryName'] ?? 'Unknown Category',
              'role': group['role'] ?? 'Member',
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

  /// Get MC report submissions from the server
  static Future<ReportSubmissionsResponse> getMcReportSubmissions({
    int limit = 10,
    int offset = 0,
    int? reportId,
  }) async {
    try {
      final queryParams = {
        'limit': limit,
        'offset': offset,
        if (reportId != null) 'reportId': reportId,
      };

      final response = await _dio.get(
        '/reports/submissions/me',
        queryParameters: queryParams,
      );

      return ReportSubmissionsResponse.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('❌ Error fetching submissions: ${e.message}');
      throw _handleDioException(e);
    }
  }

  /// Get specific MC report details by MC ID
  static Future<List<Map<String, dynamic>>> getReportDetailsByGroupId(
    int groupId,
  ) async {
    try {
      debugPrint('🔍 Fetching reports for MC ID: $groupId');
      final response = await _dio.get('/reports/submissions/$groupId');
      debugPrint('✅✅✅ MC reports response: ${response.data}');

      if (response.data is List) {
        return List<Map<String, dynamic>>.from(response.data);
      }

      return [];
    } on DioException catch (e) {
      debugPrint('❌ Error fetching MC reports: ${e.toString()}');
      debugPrint('🔢 Status code: ${e.response?.statusCode}');
      debugPrint('💥 Error response: ${e.response?.data}');

      // Return empty list if endpoint doesn't exist yet
      return [];
    } catch (e) {
      debugPrint('💀 Unexpected error: ${e.toString()}');
      return [];
    }
  }

  /// Get all submitted reports from server (for display)
  static Future<List<Map<String, dynamic>>> getAllSubmittedReports() async {
    try {
      debugPrint('🔍 Fetching all submitted reports from server...');

      // Try to get submitted report data
      final response = await _dio.get('/report-data');
      debugPrint('✅ Report data response: ${response.data}');

      if (response.data is List) {
        final reports = <Map<String, dynamic>>[];
        for (var item in response.data) {
          if (item is Map) {
            final mapItem = Map<String, dynamic>.from(item);
            // Ensure it has the expected structure
            if (mapItem.containsKey('id') || mapItem.containsKey('reportId')) {
              reports.add(mapItem);
            }
          }
        }
        debugPrint('📊 Found ${reports.length} submitted reports from server');
        return reports;
      }

      debugPrint('⚠️ No report data found');
      return [];
    } on DioException catch (e) {
      debugPrint(
        '❌ Error fetching submitted reports: ${e.response?.statusCode} ${e.message}',
      );
      if (e.response?.statusCode == 404) {
        debugPrint('ℹ️ Report data endpoint not available');
        return [];
      }
      return [];
    } catch (e) {
      debugPrint('💀 Unexpected error: $e');
      return [];
    }
  }

  static Future<Group> getGroupDetails(int groupId) async {
    try {
      debugPrint('🔍 Fetching group details from /groups/$groupId...');
      final response = await _dio.get('/groups/$groupId');
      debugPrint('✅ Group details response received: ${response.data}');

      return Group.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('❌ DioException fetching group details: ${e.toString()}');
      debugPrint('💥 Error response: ${e.response?.data}');
      debugPrint('🔢 Status code: ${e.response?.statusCode}');
      throw _handleDioException(e);
    } catch (e) {
      debugPrint('💀 Unexpected error fetching group details: ${e.toString()}');
      throw Exception('Failed to fetch group details: ${e.toString()}');
    }
  }

  static Future<GroupsResponse> getUserGroups() async {
    try {
      debugPrint('🔍 Fetching user groups from /groups/me...');
      final response = await _dio.get('/groups/me');
      debugPrint('✅ User groups response received: ${response.data}');

      // Handle direct array response and create GroupsResponse
      final List<dynamic> groupsArray = response.data ?? [];
      final groups = groupsArray
          .map((groupData) => Group.fromJson(groupData as Map<String, dynamic>))
          .toList();
      
      // Create a simple summary since the API no longer provides it
      final summary = GroupsSummary(
        totalGroups: groups.length,
        totalMembers: 0, // Not available from direct array response
      );
      
      return GroupsResponse(groups: groups, summary: summary);
    } on DioException catch (e) {
      debugPrint('❌ DioException fetching user groups: ${e.toString()}');
      debugPrint('💥 Error response: ${e.response?.data}');
      debugPrint('🔢 Status code: ${e.response?.statusCode}');
      throw _handleDioException(e);
    } catch (e) {
      debugPrint('💀 Unexpected error fetching user groups: ${e.toString()}');
      throw Exception('Failed to fetch user groups: ${e.toString()}');
    }
  }

  static Future<List<Map<String, dynamic>>> getMyGroups() async {
    try {
      debugPrint('🔍 Fetching groups from /groups/me');
      final response = await _dio.get(ReportEndpoints.getGroupsForMe);
      debugPrint('✅ My Groups response received: ${response.data}');

      // Handle direct array response
      final List<dynamic> groupsArray = response.data ?? [];
      
      debugPrint('📝 Parsed groups count: ${groupsArray.length}');

      final result = groupsArray
          .map((groupData) => {
            'id': groupData['id'], 
            'name': groupData['name'] ?? 'Unknown Group'
          })
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

  /// Extract report categories from reports data
  static List<Map<String, dynamic>> getReportCategoriesFromReports(List<Report> reports) {
    debugPrint('🏷️ Extracting categories from ${reports.length} reports...');
    
    final Map<int, Map<String, dynamic>> categoriesMap = {};
    
    for (final report in reports) {
      final categoryId = report.targetGroupCategory.id;
      if (!categoriesMap.containsKey(categoryId)) {
        categoriesMap[categoryId] = {
          'id': categoryId,
          'name': report.targetGroupCategory.name,
        };
      }
    }
    
    final categories = categoriesMap.values.toList();
    debugPrint('✅ Extracted ${categories.length} unique categories: $categories');
    return categories;
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

      // Handle current API response: {"data":{"reportId":9,"submissionId":233,"submittedAt":"...","submittedBy":"..."},"status":200,"message":"..."}
      final apiResponse = response.data as Map<String, dynamic>;
      final submissionData = apiResponse['data'] as Map<String, dynamic>;
      
      // Map to ReportSubmission format (only submission.id is actually used by the app)
      final mappedData = {
        'id': submissionData['submissionId'],
        'reportId': submissionData['reportId'], 
        'reportName': '', // Placeholder - not used
        'groupId': groupId,
        'groupName': '', // Placeholder - not used  
        'submittedAt': submissionData['submittedAt'],
        'submittedBy': {
          'id': 0, // Placeholder - API only returns email
          'name': submissionData['submittedBy'],
        },
        'data': {}, // Placeholder - not used after submission
        'canEdit': false, // Placeholder - not used
      };
      
      return ReportSubmission.fromJson(mappedData);
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
      debugPrint('API call for reports returned data');
      if (response.data is List) {
        // Direct array response
        debugPrint('API call for reports: List returned');
        reportsData = response.data;
        debugPrint(jsonEncode(reportsData));
      } else if (response.data is Map && response.data['reports'] != null) {
        // Wrapped in reports property
        debugPrint('API call for reports: Map returned');
        reportsData = response.data['reports'];
        debugPrint(jsonEncode(reportsData));
      } else {
        debugPrint('API call for reports: NOTHING returned');
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
          if (report.active == true && report.status == 'active') {
            reports.add(report);
          }
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

  /// Get all groups by category for tenant (admin level)
  static Future<List<Map<String, dynamic>>> getAllGroupsByCategory(String categoryName) async {
    try {
      debugPrint('🔍 Fetching all groups for category: $categoryName');
      final response = await _dio.get('/groups/categories/$categoryName');
      debugPrint('✅ All groups response: ${response.data}');
      
      if (response.data is List) {
        return List<Map<String, dynamic>>.from(response.data);
      }
      
      return [];
    } on DioException catch (e) {
      debugPrint('❌ Error fetching all groups by category: ${e.toString()}');
      return [];
    } catch (e) {
      debugPrint('💀 Unexpected error: ${e.toString()}');
      return [];
    }
  }

  /// Resolve dynamic group selector from field options
  static Future<List<Map<String, dynamic>>> resolveDynamicGroupSelector(
    Map<String, dynamic> selectorConfig,
    AuthProvider authProvider,
  ) async {
    final type = selectorConfig['type']?.toString();
    final scope = selectorConfig['scope']?.toString();
    final groupCategory = selectorConfig['group_category']?.toString();

    if (type != 'dynamic_group_selector' || groupCategory == null) {
      debugPrint('⚠️ Invalid dynamic group selector config: $selectorConfig');
      return [];
    }

    try {
      if (scope == 'user') {
        // Use hierarchy with exact category name from backend
        return authProvider.getGroupsFromHierarchy(groupCategory);
      } else if (scope == 'tenant') {
        // Fetch all groups of this category for the tenant
        return await getAllGroupsByCategory(groupCategory);
      } else {
        debugPrint('⚠️ Unknown scope: $scope');
        return [];
      }
    } catch (e) {
      debugPrint('💀 Error resolving dynamic group selector: $e');
      return [];
    }
  }

  /// Handle Dio exceptions and convert to readable messages
  static Exception _handleDioException(DioException e) {
    String message;

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        message = 'Connection timeout - server is not responding.';
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
        message = 'Server unavailable - unable to connect.';
        break;
      default:
        message = 'Network error occurred';
    }

    return Exception(message);
  }
}
