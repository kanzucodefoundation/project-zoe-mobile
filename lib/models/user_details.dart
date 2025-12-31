import 'package:project_zoe/models/user.dart';

/// User details model for detailed user information
/// This is used for user profile/details endpoints
class UserDetails {
  final int id;
  final String username;
  final String fullName;
  final String email;
  final String avatar;
  final int contactId;
  final List<String> roles;
  final List<String> permissions;
  final List<int> manageGroupIds;
  final List<int> viewGroupIds;
  final bool isActive;

  const UserDetails({
    required this.id,
    required this.username,
    required this.fullName,
    required this.email,
    required this.avatar,
    required this.contactId,
    required this.roles,
    required this.permissions,
    required this.manageGroupIds,
    required this.viewGroupIds,
    required this.isActive,
  });

  /// Factory constructor from JSON
  factory UserDetails.fromJson(Map<String, dynamic> json) {
    return UserDetails(
      id: json['id'] as int,
      username: json['username'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      avatar: json['avatar'] as String,
      contactId: json['contactId'] as int,
      roles: (json['roles'] as List<dynamic>)
          .map((role) => role as String)
          .toList(),
      permissions: (json['permissions'] as List<dynamic>)
          .map((perm) => perm as String)
          .toList(),
      manageGroupIds: (json['manageGroupIds'] as List<dynamic>)
          .map((id) => id as int)
          .toList(),
      viewGroupIds: (json['viewGroupIds'] as List<dynamic>)
          .map((id) => id as int)
          .toList(),
      isActive: json['isActive'] as bool,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'fullName': fullName,
      'email': email,
      'avatar': avatar,
      'contactId': contactId,
      'roles': roles,
      'permissions': permissions,
      'manageGroupIds': manageGroupIds,
      'viewGroupIds': viewGroupIds,
      'isActive': isActive,
    };
  }

  // ============================================================
  // ROLE CHECKS
  // ============================================================

  /// Get primary role
  String get primaryRole => roles.isNotEmpty ? roles.first : 'Unknown';

  /// Check if user has a specific role
  bool hasRole(String role) => roles.contains(role);

  /// Check if user has multiple roles
  bool get hasMultipleRoles => roles.length > 1;

  /// Get formatted roles string
  String get rolesDisplay => roles.join(', ');

  /// Check if user is a member (basic role)
  bool get isMember => hasRole('Member');

  /// Check if user is a fellowship leader (MC Shepherd)
  bool get isFellowshipLeader => hasRole('MC Shepherd');

  /// Check if user is a zone leader
  bool get isZoneLeader => hasRole('Zone Leader');

  /// Check if user is a location pastor
  bool get isLocationPastor => hasRole('Location Pastor');

  /// Check if user is a FOB leader
  bool get isFOBLeader => hasRole('FOB Leader');

  /// Check if user is a network leader
  bool get isNetworkLeader => hasRole('Network Leader');

  // ============================================================
  // PERMISSION CHECKS
  // ============================================================

  /// Check if user has a specific permission
  bool hasPermission(String permission) => permissions.contains(permission);

  /// Check if user can access dashboard
  bool get canAccessDashboard => hasPermission('DASHBOARD');

  /// Check if user can submit reports
  bool get canSubmitReports => hasPermission('REPORT_SUBMIT');

  /// Check if user can view reports
  bool get canViewReports => hasPermission('REPORT_VIEW');

  /// Check if user can view report submissions (from others)
  bool get canViewSubmissions => hasPermission('REPORT_VIEW_SUBMISSIONS');

  /// Check if user can access CRM
  bool get canAccessCRM =>
      hasPermission('CRM_VIEW') || hasPermission('CRM_EDIT');

  /// Check if user can edit CRM
  bool get canEditCRM => hasPermission('CRM_EDIT');

  /// Check if user can manage users
  bool get canManageUsers => hasPermission('USER_MANAGE');

  /// Check if user can view users
  bool get canViewUsers => hasPermission('USER_VIEW');

  // ============================================================
  // GROUP PERMISSIONS
  // ============================================================

  /// Check if user can manage a specific group
  bool canManageGroup(int groupId) => manageGroupIds.contains(groupId);

  /// Check if user can view a specific group
  bool canViewGroup(int groupId) =>
      viewGroupIds.contains(groupId) || manageGroupIds.contains(groupId);

  /// Check if user has any groups they can manage
  bool get hasManageableGroups => manageGroupIds.isNotEmpty;

  /// Check if user has any groups they can view
  bool get hasViewableGroups => viewGroupIds.isNotEmpty;

  /// Get total number of groups user can interact with
  int get totalAccessibleGroups {
    return {...manageGroupIds, ...viewGroupIds}.length;
  }

  // ============================================================
  // UI HELPERS
  // ============================================================

  /// Get user initials for avatar fallback
  String get initials {
    final parts = fullName.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';
  }

  /// Get display name with primary role
  String get displayNameWithRole => '$fullName ($primaryRole)';

  /// Get status badge text
  String get statusText => isActive ? 'Active' : 'Inactive';

  /// Get permissions count
  int get permissionCount => permissions.length;

  /// Check if user has limited access (only basic permissions)
  bool get hasLimitedAccess =>
      permissions.length == 1 && permissions.first == 'DASHBOARD';

  // ============================================================
  // CONVERSION METHODS
  // ============================================================

  /// Convert UserDetails to simplified User model
  User toUser({UserHierarchy? hierarchy}) {
    return User(
      id: id,
      contactId: contactId,
      username: username,
      email: email,
      fullName: fullName,
      avatar: avatar,
      isActive: isActive,
      roles: roles,
      permissions: permissions,
      hierarchy: hierarchy ?? const UserHierarchy.empty(),
    );
  }

  /// Convert to dropdown-friendly map
  Map<String, dynamic> toDropdownMap() {
    return {'id': id, 'name': fullName, 'email': email, 'roles': rolesDisplay};
  }

  // ============================================================
  // OBJECT METHODS
  // ============================================================

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserDetails && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'UserDetails(id: $id, name: $fullName, roles: $roles, '
        'permissions: ${permissions.length}, '
        'manageGroups: ${manageGroupIds.length}, '
        'viewGroups: ${viewGroupIds.length})';
  }

  /// Create a copy with updated fields
  UserDetails copyWith({
    int? id,
    String? username,
    String? fullName,
    String? email,
    String? avatar,
    int? contactId,
    List<String>? roles,
    List<String>? permissions,
    List<int>? manageGroupIds,
    List<int>? viewGroupIds,
    bool? isActive,
  }) {
    return UserDetails(
      id: id ?? this.id,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      contactId: contactId ?? this.contactId,
      roles: roles ?? this.roles,
      permissions: permissions ?? this.permissions,
      manageGroupIds: manageGroupIds ?? this.manageGroupIds,
      viewGroupIds: viewGroupIds ?? this.viewGroupIds,
      isActive: isActive ?? this.isActive,
    );
  }
}

// ============================================================
// USAGE EXAMPLES
// ============================================================
