<<<<<<< HEAD
// import 'dart:convert';

// import 'package:dio/dio.dart';
// import 'package:flutter/widgets.dart';
// import 'package:project_zoe/models/report_template.dart';
// import '../api/api_client.dart';
// import '../api/endpoints/report_endpoints.dart';
// import '../models/report.dart';

// /// Service class to handle report API calls
// class ReportService {
//   static final ApiClient _apiClient = ApiClient();
//   static Dio get _dio => _apiClient.dio;

//   /// Get available groups/MCs from server
//   static Future<List<Map<String, dynamic>>> getAvailableGroups() async {
//     try {
//       debugPrint('🔍 Fetching groups from /groups/combo...');
//       final response = await _dio.get('/groups/combo');
//       // debugPrint('✅ Groups response received: ${response.data}');
//       // debugPrint('📊 Response type: ${response.data.runtimeType}');

//       final List<dynamic> groupsData = response.data ?? [];
//       // debugPrint('📝 Parsed groups count: ${groupsData.length}');

//       final result = groupsData
//           .map(
//             (group) => {
//               'id': group['id'],
//               'name': group['name'] ?? 'Unknown Group',
//             },
//           )
//           .toList();

//       debugPrint('🎯 Final groups result: $result');
//       return result;
//     } on DioException catch (e) {
//       debugPrint('❌ DioException fetching groups: ${e.toString()}');
//       debugPrint('💥 Error response: ${e.response?.data}');
//       debugPrint('🔢 Status code: ${e.response?.statusCode}');
//       throw _handleDioException(e);
//     } catch (e) {
//       debugPrint('💀 Unexpected error fetching groups: ${e.toString()}');
//       throw Exception('Failed to fetch groups: ${e.toString()}');
//     }
//   }

//   static Future<List<Map<String, dynamic>>> getMCGroups() async {
//     try {
//       debugPrint('🔍 Fetching groups from /groups/combo...');
//       final response = await _dio.get(
//         '/groups/combo?categories=Missional Community',
//       );
//       // debugPrint('✅ Groups response received: ${response.data}');
//       // debugPrint('📊 Response type: ${response.data.runtimeType}');

//       final List<dynamic> groupsData = response.data ?? [];
//       // debugPrint('📝 Parsed groups count: ${groupsData.length}');

//       final result = groupsData
//           .map(
//             (group) => {
//               'id': group['id'],
//               'name': group['name'] ?? 'Unknown Group',
//             },
//           )
//           .toList();

//       debugPrint('🎯 Final groups result: $result');
//       return result;
//     } on DioException catch (e) {
//       debugPrint('❌ DioException fetching groups: ${e.toString()}');
//       debugPrint('💥 Error response: ${e.response?.data}');
//       debugPrint('🔢 Status code: ${e.response?.statusCode}');
//       throw _handleDioException(e);
//     } catch (e) {
//       debugPrint('💀 Unexpected error fetching groups: ${e.toString()}');
//       throw Exception('Failed to fetch groups: ${e.toString()}');
//     }
//   }

//   /// Get report categories from server
//   static Future<List<Map<String, dynamic>>> getReportCategories() async {
//     try {
//       debugPrint('🔍 Fetching categories from /reports/category...');
//       final response = await _dio.get('/reports/category');
//       debugPrint('✅ Categories response received: ${response.data}');
//       // debugPrint('📊 Response type: ${response.data.runtimeType}');

//       // Based on your test data, server returns array directly
//       if (response.data is List) {
//         debugPrint('📋 Response is a List');
//         final List<dynamic> categoriesData = response.data;
//         final result = categoriesData
//             .map(
//               (category) => {
//                 'id': category['id'],
//                 'name': category['name'] ?? 'Unknown Category',
//               },
//             )
//             .toList();
//         debugPrint('🎯 Final categories result: $result');
//         return result;
//       } else if (response.data is Map && response.data['categories'] != null) {
//         // debugPrint('📋 Response is a Map with categories property');
//         final List<dynamic> categoriesData = response.data['categories'];
//         final result = categoriesData
//             .map(
//               (category) => {
//                 'id': category['id'],
//                 'name': category['name'] ?? 'Unknown Category',
//               },
//             )
//             .toList();
//         // debugPrint('🎯 Final categories result: $result');
//         return result;
//       }

//       debugPrint('⚠️ No categories found in server response');
//       return [];
//     } on DioException catch (e) {
//       debugPrint('❌ DioException fetching categories: ${e.toString()}');
//       debugPrint('💥 Error response: ${e.response?.data}');
//       debugPrint('🔢 Status code: ${e.response?.statusCode}');

//       throw _handleDioException(e);
//     } catch (e) {
//       debugPrint('💀 Unexpected error fetching categories: ${e.toString()}');
//       throw Exception('Failed to fetch categories: ${e.toString()}');
//     }
//   }

//   /// Submit Report with correct payload structure
//   static Future<Map<String, dynamic>> submitReport({
//     required int reportId,
//     required Map<String, dynamic> data,
//   }) async {
//     final reportPayload = {'reportId': reportId, 'data': data};

//     try {
//       // debugPrint('📤 Submitting report with payload: $reportPayload');

//       final response = await _dio.post(
//         ReportEndpoints.reportsSubmit,
//         data: jsonEncode(reportPayload),
//       );

//       // debugPrint('✅ Report submitted successfully: ${response.data}');
//       return response.data;
//     } on DioException catch (e) {
//       debugPrint('❌ Report Submission Error:');
//       debugPrint('📍 URL: ${ReportEndpoints.reportsSubmit}');
//       debugPrint('📦 Request Payload: $reportPayload');
//       debugPrint('🔥 Error Type: ${e.type}');
//       debugPrint('📊 Status Code: ${e.response?.statusCode}');
//       debugPrint('💥 Response Data: ${e.response?.data}');
//       debugPrint('💬 Error Message: ${e.message}');
//       throw _handleDioException(e);
//     } catch (e) {
//       debugPrint('💀 Unexpected error in report submission: $e');
//       throw Exception('Failed to submit report: ${e.toString()}');
//     }
//   }

//   /// Submit MC Report to the backend
//   static Future<Map<String, dynamic>> submitMcReport({
//     required String gatheringDate,
//     required String mcName,
//     String? mcId,
//     required String hostHome,
//     required int totalMembers,
//     required int attendance,
//     String? streamingMethod,
//     String? attendeesNames,
//     String? visitors,
//     String? highlights,
//     String? testimonies,
//     String? prayerRequests,
//   }) async {
//     // Map fields to match server expectations based on report template
//     final reportData = {
//       'reportId': 4, // MC Attendance Report ID from server response
//       'date': gatheringDate,
//       'smallGroupName': mcName,
//       'smallGroupId':
//           int.tryParse(mcId ?? '4') ?? 4, // Default to Jerusalem MC id
//       'mcHostHome': hostHome,
//       'smallGroupNumberOfMembers': totalMembers,
//       'smallGroupAttendanceCount': attendance,
//       // Additional fields for extended data
//       'streamingMethod': streamingMethod ?? '',
//       'attendeesNames': attendeesNames ?? '',
//       'visitors': visitors ?? '',
//       'highlights': highlights ?? '',
//       'testimonies': testimonies ?? '',
//       'prayerRequests': prayerRequests ?? '',
//       'submittedAt': DateTime.now().toIso8601String(),
//     };

//     try {
//       final response = await _dio.post(
//         ReportEndpoints.reportsSubmit,
//         data: reportData,
//       );

//       return response.data;
//     } on DioException catch (e) {
//       // Enhanced error logging for debugging
//       debugPrint('MC Report Submission Error:');
//       debugPrint('URL: ${ReportEndpoints.reportsSubmit}');
//       debugPrint('Request Data: $reportData');
//       debugPrint('Error Type: ${e.type}');
//       debugPrint('Status Code: ${e.response?.statusCode}');
//       debugPrint('Response Data: ${e.response?.data}');
//       debugPrint('Error Message: ${e.message}');
//       throw _handleDioException(e);
//     } catch (e) {
//       debugPrint('Unexpected error in MC report submission: $e');
//       throw Exception('Failed to submit MC report: ${e.toString()}');
//     }
//   }

//   /// Get MC report submissions from the server
//   static Future<List<Map<String, dynamic>>> getMcReportSubmissions() async {
//     debugPrint('🔍 Testing multiple endpoints for actual submissions...');

//     // Try multiple possible endpoints
//     final endpoints = [
//       '/reports/submissions',
//       '/report-submissions',
//       '/submissions',
//       '/reports/data',
//       '/reports',
//     ];

//     for (final endpoint in endpoints) {
//       try {
//         debugPrint('📡 Trying endpoint: $endpoint');
//         final response = await _dio.get(endpoint);
//         debugPrint('✅ $endpoint Response: ${response.data}');

//         if (response.data is List) {
//           final submissions = <Map<String, dynamic>>[];
//           for (var item in response.data) {
//             if (item is Map) {
//               final mapItem = Map<String, dynamic>.from(item);
//               // Check if this looks like a submission with actual data
//               if (mapItem.containsKey('data') &&
//                   mapItem['data'] != null &&
//                   mapItem['data'] is Map &&
//                   (mapItem['data'] as Map).isNotEmpty) {
//                 submissions.add(mapItem);
//                 debugPrint('✅ Found submission with data: ${mapItem['id']}');
//               } else if (endpoint == '/reports' &&
//                   !mapItem.containsKey('fields')) {
//                 // This might be a submission without the nested structure
//                 submissions.add(mapItem);
//                 debugPrint('✅ Found potential submission: ${mapItem['id']}');
//               }
//             }
//           }

//           if (submissions.isNotEmpty) {
//             debugPrint(
//               '🎉 Found ${submissions.length} submissions from $endpoint',
//             );
//             return submissions;
//           }
//           debugPrint(
//             '⚠️ $endpoint returned ${(response.data as List).length} items but no actual submissions',
//           );
//         } else {
//           debugPrint(
//             '⚠️ $endpoint response is not a list: ${response.data.runtimeType}',
//           );
//         }
//       } catch (e) {
//         debugPrint('❌ $endpoint failed: $e');
//       }
//     }

//     debugPrint('💀 No submissions found from any endpoint');
//     return [];
//   }

//   /// Get specific MC report details by MC ID
//   static Future<List<Map<String, dynamic>>> getMcReportsByGroupId(
//     int groupId,
//   ) async {
//     try {
//       debugPrint('🔍 Fetching reports for MC ID: $groupId');
//       final response = await _dio.get('/reports/group/$groupId');
//       debugPrint('✅ MC reports response: ${response.data}');

//       if (response.data is List) {
//         return List<Map<String, dynamic>>.from(response.data);
//       }

//       return [];
//     } on DioException catch (e) {
//       debugPrint('❌ Error fetching MC reports: ${e.toString()}');
//       debugPrint('🔢 Status code: ${e.response?.statusCode}');
//       debugPrint('💥 Error response: ${e.response?.data}');

//       // Return empty list if endpoint doesn't exist yet
//       return [];
//     } catch (e) {
//       debugPrint('💀 Unexpected error: ${e.toString()}');
//       return [];
//     }
//   }

//   /// Get specific report template by report ID
//   static Future<Map<String, dynamic>?> getReportTemplate(
//     dynamic reportId,
//   ) async {
//     try {
//       debugPrint('🔍 Fetching report template for ID: $reportId');
//       final response = await _dio.get('/reports/$reportId');
//       debugPrint('✅ Report template response: ${response.data}');

//       if (response.data is Map<String, dynamic>) {
//         return Map<String, dynamic>.from(response.data);
//       }

//       return null;
//     } on DioException catch (e) {
//       debugPrint('❌ Error fetching report template: ${e.toString()}');
//       debugPrint('🔢 Status code: ${e.response?.statusCode}');
//       debugPrint('💥 Error response: ${e.response?.data}');
//       return null;
//     } catch (e) {
//       debugPrint('💀 Unexpected error: ${e.toString()}');
//       return null;
//     }
//   }

//   /// Get report submissions for a specific report template
//   static Future<List<Map<String, dynamic>>> getReportSubmissions(
//     int reportId,
//   ) async {
//     try {
//       debugPrint('🔍 Fetching submissions for report ID: $reportId');
//       final response = await _dio.get('/reports/$reportId/submissions');
//       debugPrint('✅ Report submissions response: ${response.data}');

//       if (response.data is List) {
//         return List<Map<String, dynamic>>.from(response.data);
//       }

//       return [];
//     } on DioException catch (e) {
//       debugPrint('❌ Error fetching report submissions: ${e.toString()}');
//       debugPrint('🔢 Status code: ${e.response?.statusCode}');
//       debugPrint('💥 Error response: ${e.response?.data}');
//       return [];
//     } catch (e) {
//       debugPrint('💀 Unexpected error: ${e.toString()}');
//       return [];
//     }
//   }

//   /// Submit Garage Attendance Report
//   static Future<Map<String, dynamic>> submitGarageReport({
//     required String date,
//     required int attendance,
//     required String notes,
//   }) async {
//     try {
//       final reportData = {
//         'type': 'garage_report',
//         'date': date,
//         'attendance': attendance,
//         'notes': notes,
//         'submittedAt': DateTime.now().toIso8601String(),
//       };

//       final response = await _dio.post(
//         ReportEndpoints.reportsSubmit,
//         data: reportData,
//       );

//       return response.data;
//     } on DioException catch (e) {
//       throw _handleDioException(e);
//     } catch (e) {
//       throw Exception('Failed to submit garage report: ${e.toString()}');
//     }
//   }

//   static Future<List<ReportTemplate>> getReportTemplates() async {
//     try {
//       final response = await _dio.get(ReportEndpoints.reports);

//       // Handle different response formats
//       List<dynamic> reportsData;
//       if (response.data is List) {
//         // Direct array response
//         reportsData = response.data;
//         // debugPrint(reportsData);
//         debugPrint('📋 Response is a List with ${reportsData.length} items');
//       } else if (response.data is Map && response.data['reports'] != null) {
//         // Wrapped in reports property
//         reportsData = response.data['reports'];
//       } else {
//         debugPrint(
//           '⚠️ Unexpected reports response format: ${response.data.runtimeType}',
//         );
//         return [];
//       }

//       debugPrint('📋 Processing ${reportsData.length} report items');

//       // Try to map each item, skip items that fail parsing
//       final reports = <ReportTemplate>[];
//       for (var i = 0; i < reportsData.length; i++) {
//         try {
//           final report = _mapApiResponseToReportTemplate(reportsData[i]);
//           reports.add(report);
//         } catch (e) {
//           debugPrint('⚠️ Failed to parse report item $i: $e');
//           debugPrint('📄 Raw item: ${reportsData[i]}');
//           // Continue processing other items
//         }
//       }

//       debugPrint('✅ Successfully parsed ${reports.length} reports');
//       return reports;
//     } on DioException catch (e) {
//       throw _handleDioException(e);
//     } catch (e) {
//       throw Exception('Failed to fetch reports: ${e.toString()}');
//     }
//   }

//   /// Get all reports
//   static Future<List<Report>> getAllReports() async {
//     try {
//       final response = await _dio.get(ReportEndpoints.reports);

//       // Handle different response formats
//       List<dynamic> reportsData;
//       if (response.data is List) {
//         // Direct array response
//         reportsData = response.data;
//       } else if (response.data is Map && response.data['reports'] != null) {
//         // Wrapped in reports property
//         reportsData = response.data['reports'];
//       } else {
//         return [];
//       }

//       debugPrint('📋 Processing ${reportsData.length} report items');

//       // Try to map each item, skip items that fail parsing
//       final reports = <Report>[];
//       for (var i = 0; i < reportsData.length; i++) {
//         try {
//           final report = _mapApiResponseToReport(reportsData[i]);
//           reports.add(report);
//         } catch (e) {
//           debugPrint('⚠️ Failed to parse report item $i: $e');
//           debugPrint('📄 Raw item: ${reportsData[i]}');
//           // Continue processing other items
//         }
//       }

//       debugPrint('✅ Successfully parsed ${reports.length} reports');
//       return reports;
//     } on DioException catch (e) {
//       throw _handleDioException(e);
//     } catch (e) {
//       throw Exception('Failed to fetch reports: ${e.toString()}');
//     }
//   }

//   /// Get report by ID
//   static Future<Report> getReportById(String id) async {
//     try {
//       final response = await _dio.get(ReportEndpoints.getReportById(id));
//       return _mapApiResponseToReport(response.data);
//     } on DioException catch (e) {
//       throw _handleDioException(e);
//     } catch (e) {
//       throw Exception('Failed to fetch report: ${e.toString()}');
//     }
//   }

//   static Future<ReportTemplate> getReportTempById(String id) async {
//     try {
//       final response = await _dio.get(ReportEndpoints.getReportById(id));
//       return _mapApiResponseToReportTemplate(response.data);
//     } on DioException catch (e) {
//       throw _handleDioException(e);
//     } catch (e) {
//       throw Exception('Failed to fetch report: ${e.toString()}');
//     }
//   }

//   /// Update report status
//   static Future<Map<String, dynamic>> updateReportStatus({
//     required String reportId,
//     required String status,
//   }) async {
//     try {
//       final response = await _dio.put(
//         ReportEndpoints.updateReportById(reportId),
//         data: {'status': status},
//       );

//       return response.data;
//     } on DioException catch (e) {
//       throw _handleDioException(e);
//     } catch (e) {
//       throw Exception('Failed to update report status: ${e.toString()}');
//     }
//   }

//   /// Map API response to ReportTmeplate model
//   static ReportTemplate _mapApiResponseToReportTemplate(
//     Map<String, dynamic> json,
//   ) {
//     try {
//       final id = json['id'] ?? '';
//       final title = json['name'] ?? json['title'] ?? 'Untitled Report';
//       final description = json['description'] ?? '';

//       // Parse display columns
//       final displayColumns = (json['displayColumns'] as List<dynamic>? ?? [])
//           .map((c) => DisplayColumn(name: c['name'], label: c['label']))
//           .toList();

//       // Parse fields
//       final fields = (json['fields'] as List<dynamic>? ?? [])
//           .map(
//             (f) => ReportField(
//               id: f['id'],
//               name: f['name'],
//               type: f['type'],
//               label: f['label'] ?? '',
//               required: f['required'] ?? false,
//               hidden: f['hidden'] ?? false,
//               options: f['options'],
//             ),
//           )
//           .toList();

//       return ReportTemplate(
//         id: id,
//         name: title,
//         description: description,
//         viewType: json['viewType'] ?? 'table',
//         status: json['status'],
//         functionName: json['functionName'],
//         submissionFrequency: json['submissionFrequency'],
//         displayColumns: displayColumns,
//         fields: fields,
//         footer: json['footer'],
//         labels: json['labels'],
//         dataPoints: json['dataPoints'],
//         sqlQuery: json['sqlQuery'],
//         active: json['active'] ?? true,
//       );
//     } catch (e) {
//       debugPrint('❌ Error mapping template: $e');
//       debugPrint('📄 Raw JSON: $json');
//       throw Exception("Failed to parse report template: ${e.toString()}");
//     }
//   }

//   /// Map API response to Report model
//   static Report _mapApiResponseToReport(Map<String, dynamic> json) {
//     try {
//       // Handle server response format where we get report templates/definitions
//       final id = json['id']?.toString() ?? '';
//       final title = json['name'] ?? json['title'] ?? 'Untitled Report';
//       final description = json['description'] ?? '';

//       // Map type based on name or functionName
//       final typeString = json['type'] ?? json['name'] ?? '';
//       final type = _mapStringToReportType(typeString);

//       // Default status for report templates
//       final statusString = json['status'] ?? 'active';
//       final status = statusString == 'active'
//           ? ReportStatus.pending
//           : _mapStringToReportStatus(statusString);

//       // Handle dates - use current date if not provided (for templates)
//       final now = DateTime.now();
//       final createdAt = json['createdAt'] != null
//           ? DateTime.tryParse(json['createdAt']) ?? now
//           : now;

//       final completedAt = json['completedAt'] != null
//           ? DateTime.tryParse(json['completedAt'])
//           : null;

//       return Report(
//         id: id,
//         title: title,
//         description: description,
//         type: type,
//         status: status,
//         createdAt: createdAt,
//         completedAt: completedAt,
//         createdBy: json['createdBy'] ?? 'System',
//         assignedTo: json['assignedTo'],
//         tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
//         priority: json['priority'] ?? 2,
//         data: Map<String, dynamic>.from(json['data'] ?? json),
//       );
//     } catch (e) {
//       debugPrint('❌ Error mapping report: $e');
//       debugPrint('📄 Raw JSON: $json');
//       throw Exception('Failed to parse report data: ${e.toString()}');
//     }
//   }

//   /// Map string to ReportType enum
//   static ReportType _mapStringToReportType(String? type) {
//     switch (type?.toLowerCase()) {
//       case 'attendance':
//         return ReportType.attendance;
//       case 'financial':
//         return ReportType.financial;
//       case 'membership':
//         return ReportType.membership;
//       case 'events':
//         return ReportType.events;
//       case 'shepherds':
//         return ReportType.shepherds;
//       default:
//         return ReportType.general;
//     }
//   }

//   /// Map string to ReportStatus enum
//   static ReportStatus _mapStringToReportStatus(String? status) {
//     switch (status?.toLowerCase()) {
//       case 'pending':
//         return ReportStatus.pending;
//       case 'in_progress':
//       case 'inprogress':
//         return ReportStatus.inProgress;
//       case 'completed':
//         return ReportStatus.completed;
//       case 'overdue':
//         return ReportStatus.pending; // Map overdue to pending
//       default:
//         return ReportStatus.pending;
//     }
//   }

//   /// Handle Dio exceptions and convert to readable messages
//   static Exception _handleDioException(DioException e) {
//     String message;

//     switch (e.type) {
//       case DioExceptionType.connectionTimeout:
//         message = 'Connection timeout. Please check your internet connection.';
//         break;
//       case DioExceptionType.sendTimeout:
//         message = 'Request timeout. Please try again.';
//         break;
//       case DioExceptionType.receiveTimeout:
//         message = 'Response timeout. Please try again.';
//         break;
//       case DioExceptionType.badResponse:
//         message = e.response?.data['message'] ?? 'Server error occurred';
//         break;
//       case DioExceptionType.cancel:
//         message = 'Request was cancelled';
//         break;
//       case DioExceptionType.connectionError:
//         message = 'Connection error. Please check your internet connection.';
//         break;
//       default:
//         message = 'Network error occurred';
//     }

//     return Exception(message);
//   }

//   // Church name management for testing different tenants
//   static String? _overrideChurchName;

//   /// Set church name override for testing
//   static void setChurchName(String churchName) {
//     _overrideChurchName = churchName;
//     // Also set it in the API client for headers
//     _apiClient.setTenant(churchName);
//   }

//   /// Clear church name override
//   static void clearChurchNameOverride() {
//     _overrideChurchName = null;
//     _apiClient.clearTenant();
//   }

//   /// Get current church name (with override support)
//   static Future<String> getChurchName() async {
//     if (_overrideChurchName != null) {
//       return _overrideChurchName!;
//     }
//     // Return saved church name or default
//     // For now, return a default - this can be enhanced to get from storage
//     return 'demo';
//   }
// }
=======
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:project_zoe/models/report_template.dart';
import '../api/api_client.dart';
import '../api/endpoints/report_endpoints.dart';
import '../models/report.dart';
import '../models/group.dart';

/// Service class to handle report API calls
class ReportService {
  static final ApiClient _apiClient = ApiClient();
  static Dio get _dio => _apiClient.dio;

  /// Get user's groups from /groups/me endpoint
  static Future<GroupsResponse> getUserGroups() async {
    try {
      print('🔍 Fetching user groups from /groups/me...');
      final response = await _dio.get('/groups/me');
      print('✅ User groups response received: ${response.data}');

      return GroupsResponse.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ DioException fetching user groups: ${e.toString()}');
      print('💥 Error response: ${e.response?.data}');
      print('🔢 Status code: ${e.response?.statusCode}');
      throw _handleDioException(e);
    } catch (e) {
      print('💀 Unexpected error fetching user groups: ${e.toString()}');
      throw Exception('Failed to fetch user groups: ${e.toString()}');
    }
  }

  /// Get individual group details from /groups/{id} endpoint
  static Future<Group> getGroupDetails(int groupId) async {
    try {
      print('🔍 Fetching group details from /groups/$groupId...');
      final response = await _dio.get('/groups/$groupId');
      print('✅ Group details response received: ${response.data}');

      return Group.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ DioException fetching group details: ${e.toString()}');
      print('💥 Error response: ${e.response?.data}');
      print('🔢 Status code: ${e.response?.statusCode}');
      throw _handleDioException(e);
    } catch (e) {
      print('💀 Unexpected error fetching group details: ${e.toString()}');
      throw Exception('Failed to fetch group details: ${e.toString()}');
    }
  }

  /// Get available groups/MCs from server
  static Future<List<Map<String, dynamic>>> getAvailableGroups() async {
    try {
      print('🔍 Fetching groups from /groups/combo...');
      final response = await _dio.get('/groups/combo');
      // print('✅ Groups response received: ${response.data}');
      // print('📊 Response type: ${response.data.runtimeType}');

      final List<dynamic> groupsData = response.data ?? [];
      // print('📝 Parsed groups count: ${groupsData.length}');

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

  static Future<List<Map<String, dynamic>>> getMCGroups() async {
    try {
      print('🔍 Fetching groups from /groups/combo...');
      final response = await _dio.get(
        '/groups/combo?categories=Missional Community',
      );
      // print('✅ Groups response received: ${response.data}');
      // print('📊 Response type: ${response.data.runtimeType}');

      final List<dynamic> groupsData = response.data ?? [];
      // print('📝 Parsed groups count: ${groupsData.length}');

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
      // print('📊 Response type: ${response.data.runtimeType}');

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
        // print('📋 Response is a Map with categories property');
        final List<dynamic> categoriesData = response.data['categories'];
        final result = categoriesData
            .map(
              (category) => {
                'id': category['id'],
                'name': category['name'] ?? 'Unknown Category',
              },
            )
            .toList();
        // print('🎯 Final categories result: $result');
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

  /// Submit Report with correct payload structure
  static Future<Map<String, dynamic>> submitReport({
    required int reportId,
    required Map<String, dynamic> data,
  }) async {
    final reportPayload = {'reportId': reportId, 'data': data};

    try {
      // print('📤 Submitting report with payload: $reportPayload');

      final response = await _dio.post(
        ReportEndpoints.reportsSubmit,
        data: jsonEncode(reportPayload),
      );

      // print('✅ Report submitted successfully: ${response.data}');
      return response.data;
    } on DioException catch (e) {
      print('❌ Report Submission Error:');
      print('📍 URL: ${ReportEndpoints.reportsSubmit}');
      print('📦 Request Payload: $reportPayload');
      print('🔥 Error Type: ${e.type}');
      print('📊 Status Code: ${e.response?.statusCode}');
      print('💥 Response Data: ${e.response?.data}');
      print('💬 Error Message: ${e.message}');
      throw _handleDioException(e);
    } catch (e) {
      print('💀 Unexpected error in report submission: $e');
      throw Exception('Failed to submit report: ${e.toString()}');
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
      print('🔍 Fetching MC report submissions from server...');

      // Try the main submissions endpoint first
      final response = await _dio.get('/reports/submissions');
      print('✅ Server response received: ${response.data}');

      if (response.data is List) {
        final submissions = <Map<String, dynamic>>[];
        for (var item in response.data) {
          if (item is Map) {
            final mapItem = Map<String, dynamic>.from(item);
            submissions.add(mapItem);
            print('📋 Added server submission: ${mapItem['id']}');
          }
        }
        print('🎉 Loaded ${submissions.length} submissions from server');
        return submissions;
      } else if (response.data is Map && response.data['data'] is List) {
        // Handle wrapped response
        final dataList = response.data['data'] as List;
        final submissions = <Map<String, dynamic>>[];
        for (var item in dataList) {
          if (item is Map) {
            final mapItem = Map<String, dynamic>.from(item);
            submissions.add(mapItem);
          }
        }
        print(
          '🎉 Loaded ${submissions.length} submissions from server (wrapped)',
        );
        return submissions;
      }

      print('⚠️ No submissions found in server response');
      return [];
    } on DioException catch (e) {
      print(
        '❌ Error fetching server submissions: ${e.response?.statusCode} ${e.message}',
      );
      if (e.response?.statusCode == 404) {
        print('ℹ️ Submissions endpoint not available, returning empty list');
        return [];
      }
      throw _handleDioException(e);
    } catch (e) {
      print('💀 Unexpected error fetching server submissions: $e');
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

  /// Get all submitted reports from server (for display)
  static Future<List<Map<String, dynamic>>> getAllSubmittedReports() async {
    try {
      print('🔍 Fetching all submitted reports from server...');

      // Try to get submitted report data
      final response = await _dio.get('/report-data');
      print('✅ Report data response: ${response.data}');

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
        print('📊 Found ${reports.length} submitted reports from server');
        return reports;
      }

      print('⚠️ No report data found');
      return [];
    } on DioException catch (e) {
      print(
        '❌ Error fetching submitted reports: ${e.response?.statusCode} ${e.message}',
      );
      if (e.response?.statusCode == 404) {
        print('ℹ️ Report data endpoint not available');
        return [];
      }
      return [];
    } catch (e) {
      print('💀 Unexpected error: $e');
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
>>>>>>> f5a54e92f5a9d2d2e0c411bba539122d49942514
