// import 'package:dio/dio.dart';
// import '../api/api_client.dart';
// import '../api/endpoints/church_endpoints.dart';

// /// Service class to handle church and ministry API calls
// class ChurchService {
//   static final ApiClient _apiClient = ApiClient();
//   static Dio get _dio => _apiClient.dio;

//   /// Get church information
//   static Future<Map<String, dynamic>> getChurchInfo() async {
//     try {
//       final response = await _dio.get(ChurchEndpoints.churchInfo);
//       return response.data;
//     } on DioException catch (e) {
//       throw _handleDioException(e);
//     } catch (e) {
//       throw Exception('Failed to get church info: ${e.toString()}');
//     }
//   }

//   /// Update church information
//   static Future<Map<String, dynamic>> updateChurchInfo({
//     required Map<String, dynamic> churchData,
//   }) async {
//     try {
//       final response = await _dio.put(
//         ChurchEndpoints.updateChurchInfo,
//         data: churchData,
//       );
//       return response.data;
//     } on DioException catch (e) {
//       throw _handleDioException(e);
//     } catch (e) {
//       throw Exception('Failed to update church info: ${e.toString()}');
//     }
//   }

//   /// Get all ministries
//   static Future<List<Map<String, dynamic>>> getAllMinistries() async {
//     try {
//       final response = await _dio.get(ChurchEndpoints.ministries);
//       final List<dynamic> ministries = response.data['ministries'] ?? [];
//       return ministries.cast<Map<String, dynamic>>();
//     } on DioException catch (e) {
//       throw _handleDioException(e);
//     } catch (e) {
//       throw Exception('Failed to get ministries: ${e.toString()}');
//     }
//   }

//   /// Create a new ministry
//   static Future<Map<String, dynamic>> createMinistry({
//     required String name,
//     required String description,
//     String? leader,
//     List<String>? members,
//   }) async {
//     try {
//       final ministryData = {
//         'name': name,
//         'description': description,
//         'leader': leader,
//         'members': members ?? [],
//         'createdAt': DateTime.now().toIso8601String(),
//       };

//       final response = await _dio.post(
//         ChurchEndpoints.createMinistry,
//         data: ministryData,
//       );
//       return response.data;
//     } on DioException catch (e) {
//       throw _handleDioException(e);
//     } catch (e) {
//       throw Exception('Failed to create ministry: ${e.toString()}');
//     }
//   }

//   /// Get ministry by ID
//   static Future<Map<String, dynamic>> getMinistryById(String ministryId) async {
//     try {
//       final response = await _dio.get(
//         ChurchEndpoints.getMinistryById(ministryId),
//       );
//       return response.data;
//     } on DioException catch (e) {
//       throw _handleDioException(e);
//     } catch (e) {
//       throw Exception('Failed to get ministry: ${e.toString()}');
//     }
//   }

//   /// Update ministry
//   static Future<Map<String, dynamic>> updateMinistry({
//     required String ministryId,
//     required Map<String, dynamic> ministryData,
//   }) async {
//     try {
//       final response = await _dio.put(
//         ChurchEndpoints.updateMinistryById(ministryId),
//         data: ministryData,
//       );
//       return response.data;
//     } on DioException catch (e) {
//       throw _handleDioException(e);
//     } catch (e) {
//       throw Exception('Failed to update ministry: ${e.toString()}');
//     }
//   }

//   /// Delete ministry
//   static Future<void> deleteMinistry(String ministryId) async {
//     try {
//       await _dio.delete(ChurchEndpoints.deleteMinistryById(ministryId));
//     } on DioException catch (e) {
//       throw _handleDioException(e);
//     } catch (e) {
//       throw Exception('Failed to delete ministry: ${e.toString()}');
//     }
//   }

//   /// Get all shepherds/leaders
//   static Future<List<Map<String, dynamic>>> getAllShepherds() async {
//     try {
//       final response = await _dio.get(ChurchEndpoints.shepherds);
//       final List<dynamic> shepherds = response.data['shepherds'] ?? [];
//       return shepherds.cast<Map<String, dynamic>>();
//     } on DioException catch (e) {
//       throw _handleDioException(e);
//     } catch (e) {
//       throw Exception('Failed to get shepherds: ${e.toString()}');
//     }
//   }

//   /// Create a new shepherd/leader
//   static Future<Map<String, dynamic>> createShepherd({
//     required String name,
//     required String email,
//     String? phone,
//     String? ministry,
//     List<String>? assignments,
//   }) async {
//     try {
//       final shepherdData = {
//         'name': name,
//         'email': email,
//         'phone': phone,
//         'ministry': ministry,
//         'assignments': assignments ?? [],
//         'createdAt': DateTime.now().toIso8601String(),
//       };

//       final response = await _dio.post(
//         ChurchEndpoints.createShepherd,
//         data: shepherdData,
//       );
//       return response.data;
//     } on DioException catch (e) {
//       throw _handleDioException(e);
//     } catch (e) {
//       throw Exception('Failed to create shepherd: ${e.toString()}');
//     }
//   }

//   /// Get shepherd by ID
//   static Future<Map<String, dynamic>> getShepherdById(String shepherdId) async {
//     try {
//       final response = await _dio.get(
//         ChurchEndpoints.getShepherdById(shepherdId),
//       );
//       return response.data;
//     } on DioException catch (e) {
//       throw _handleDioException(e);
//     } catch (e) {
//       throw Exception('Failed to get shepherd: ${e.toString()}');
//     }
//   }

//   /// Update shepherd
//   static Future<Map<String, dynamic>> updateShepherd({
//     required String shepherdId,
//     required Map<String, dynamic> shepherdData,
//   }) async {
//     try {
//       final response = await _dio.put(
//         ChurchEndpoints.updateShepherdById(shepherdId),
//         data: shepherdData,
//       );
//       return response.data;
//     } on DioException catch (e) {
//       throw _handleDioException(e);
//     } catch (e) {
//       throw Exception('Failed to update shepherd: ${e.toString()}');
//     }
//   }

//   /// Delete shepherd
//   static Future<void> deleteShepherd(String shepherdId) async {
//     try {
//       await _dio.delete(ChurchEndpoints.deleteShepherdById(shepherdId));
//     } on DioException catch (e) {
//       throw _handleDioException(e);
//     } catch (e) {
//       throw Exception('Failed to delete shepherd: ${e.toString()}');
//     }
//   }

//   /// Get ministry members
//   static Future<List<Map<String, dynamic>>> getMinistryMembers(
//     String ministryId,
//   ) async {
//     try {
//       final response = await _dio.get(
//         ChurchEndpoints.getMinistryMembers(ministryId),
//       );
//       final List<dynamic> members = response.data['members'] ?? [];
//       return members.cast<Map<String, dynamic>>();
//     } on DioException catch (e) {
//       throw _handleDioException(e);
//     } catch (e) {
//       throw Exception('Failed to get ministry members: ${e.toString()}');
//     }
//   }

//   /// Get shepherd assignments
//   static Future<List<Map<String, dynamic>>> getShepherdAssignments(
//     String shepherdId,
//   ) async {
//     try {
//       final response = await _dio.get(
//         ChurchEndpoints.getShepherdAssignments(shepherdId),
//       );
//       final List<dynamic> assignments = response.data['assignments'] ?? [];
//       return assignments.cast<Map<String, dynamic>>();
//     } on DioException catch (e) {
//       throw _handleDioException(e);
//     } catch (e) {
//       throw Exception('Failed to get shepherd assignments: ${e.toString()}');
//     }
//   }

//   /// Get all Missional Communities
//   static Future<List<Map<String, dynamic>>> getAllMcs() async {
//     try {
//       final response = await _dio.get(ChurchEndpoints.mcs);
//       final List<dynamic> mcs = response.data['mcs'] ?? response.data ?? [];
//       return mcs.cast<Map<String, dynamic>>();
//     } on DioException catch (e) {
//       throw _handleDioException(e);
//     } catch (e) {
//       throw Exception('Failed to get MCs: ${e.toString()}');
//     }
//   }

//   /// Create a new MC
//   static Future<Map<String, dynamic>> createMc({
//     required String name,
//     required String description,
//     String? leader,
//     String? hostHome,
//     List<String>? members,
//   }) async {
//     try {
//       final mcData = {
//         'name': name,
//         'description': description,
//         'leader': leader,
//         'hostHome': hostHome,
//         'members': members ?? [],
//         'createdAt': DateTime.now().toIso8601String(),
//       };

//       final response = await _dio.post(ChurchEndpoints.createMc, data: mcData);
//       return response.data;
//     } on DioException catch (e) {
//       throw _handleDioException(e);
//     } catch (e) {
//       throw Exception('Failed to create MC: ${e.toString()}');
//     }
//   }

//   /// Get MC by ID
//   static Future<Map<String, dynamic>> getMcById(String mcId) async {
//     try {
//       final response = await _dio.get(ChurchEndpoints.getMcById(mcId));
//       return response.data;
//     } on DioException catch (e) {
//       throw _handleDioException(e);
//     } catch (e) {
//       throw Exception('Failed to get MC: ${e.toString()}');
//     }
//   }

//   /// Update MC
//   static Future<Map<String, dynamic>> updateMc({
//     required String mcId,
//     required Map<String, dynamic> mcData,
//   }) async {
//     try {
//       final response = await _dio.put(
//         ChurchEndpoints.updateMcById(mcId),
//         data: mcData,
//       );
//       return response.data;
//     } on DioException catch (e) {
//       throw _handleDioException(e);
//     } catch (e) {
//       throw Exception('Failed to update MC: ${e.toString()}');
//     }
//   }

//   /// Delete MC
//   static Future<void> deleteMc(String mcId) async {
//     try {
//       await _dio.delete(ChurchEndpoints.deleteMcById(mcId));
//     } on DioException catch (e) {
//       throw _handleDioException(e);
//     } catch (e) {
//       throw Exception('Failed to delete MC: ${e.toString()}');
//     }
//   }

//   /// Get MC members
//   static Future<List<Map<String, dynamic>>> getMcMembers(String mcId) async {
//     try {
//       final response = await _dio.get(ChurchEndpoints.getMcMembers(mcId));
//       final List<dynamic> members = response.data['members'] ?? [];
//       return members.cast<Map<String, dynamic>>();
//     } on DioException catch (e) {
//       throw _handleDioException(e);
//     } catch (e) {
//       throw Exception('Failed to get MC members: ${e.toString()}');
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
// }
