import '../base_url.dart';

/// Church and ministry related API endpoints
class ChurchEndpoints {
  /// Base URL for church endpoints
  static String get _baseUrl => BaseUrl.apiUrl;

  /// Get church information endpoint - GET /church/info
  static String get churchInfo => '$_baseUrl/church/info';

  /// Update church information endpoint - PUT /church/info
  static String get updateChurchInfo => '$_baseUrl/church/info';

  /// Get all ministries endpoint - GET /church/ministries
  static String get ministries => '$_baseUrl/church/ministries';

  /// Create ministry endpoint - POST /church/ministries
  static String get createMinistry => '$_baseUrl/church/ministries';

  /// Update ministry endpoint - PUT /church/ministries/{id}
  static String get updateMinistry => '$_baseUrl/church/ministries';

  /// Delete ministry endpoint - DELETE /church/ministries/{id}
  static String get deleteMinistry => '$_baseUrl/church/ministries';

  /// Get shepherds/leaders endpoint - GET /church/shepherds
  static String get shepherds => '$_baseUrl/church/shepherds';

  /// Create shepherd/leader endpoint - POST /church/shepherds
  static String get createShepherd => '$_baseUrl/church/shepherds';

  /// Update shepherd/leader endpoint - PUT /church/shepherds/{id}
  static String get updateShepherd => '$_baseUrl/church/shepherds';

  /// Delete shepherd/leader endpoint - DELETE /church/shepherds/{id}
  static String get deleteShepherd => '$_baseUrl/church/shepherds';

  /// Get all Missional Communities endpoint - GET /church/mcs
  static String get mcs => '$_baseUrl/church/mcs';

  /// Create MC endpoint - POST /church/mcs
  static String get createMc => '$_baseUrl/church/mcs';

  /// Update MC endpoint - PUT /church/mcs/{id}
  static String get updateMc => '$_baseUrl/church/mcs';

  /// Delete MC endpoint - DELETE /church/mcs/{id}
  static String get deleteMc => '$_baseUrl/church/mcs';

  /// Get ministry by ID endpoint
  static String getMinistryById(String ministryId) => '$ministries/$ministryId';

  /// Update specific ministry endpoint
  static String updateMinistryById(String ministryId) =>
      '$updateMinistry/$ministryId';

  /// Delete specific ministry endpoint
  static String deleteMinistryById(String ministryId) =>
      '$deleteMinistry/$ministryId';

  /// Get shepherd by ID endpoint
  static String getShepherdById(String shepherdId) => '$shepherds/$shepherdId';

  /// Update specific shepherd endpoint
  static String updateShepherdById(String shepherdId) =>
      '$updateShepherd/$shepherdId';

  /// Delete specific shepherd endpoint
  static String deleteShepherdById(String shepherdId) =>
      '$deleteShepherd/$shepherdId';

  /// Get ministry members endpoint
  static String getMinistryMembers(String ministryId) =>
      '$ministries/$ministryId/members';

  /// Get shepherd assignments endpoint
  static String getShepherdAssignments(String shepherdId) =>
      '$shepherds/$shepherdId/assignments';

  /// Get MC by ID endpoint
  static String getMcById(String mcId) => '$mcs/$mcId';

  /// Update specific MC endpoint
  static String updateMcById(String mcId) => '$updateMc/$mcId';

  /// Delete specific MC endpoint
  static String deleteMcById(String mcId) => '$deleteMc/$mcId';

  /// Get MC members endpoint
  static String getMcMembers(String mcId) => '$mcs/$mcId/members';
}
