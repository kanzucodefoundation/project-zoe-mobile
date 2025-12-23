/// Authentication models for the new server structure

/// Group model for user's groups and hierarchy
class UserGroup {
  final int id;
  final String name;
  final String type;
  final int categoryId;
  final String categoryName;
  final String role;
  final int? parentId;
  final int memberCount;

  const UserGroup({
    required this.id,
    required this.name,
    required this.type,
    required this.categoryId,
    required this.categoryName,
    required this.role,
    this.parentId,
    required this.memberCount,
  });

  factory UserGroup.fromJson(Map<String, dynamic> json) {
    return UserGroup(
      id: json['id'] as int,
      name: json['name'] as String,
      type: json['type'] as String,
      categoryId: json['categoryId'] as int,
      categoryName: json['categoryName'] as String,
      role: json['role'] as String,
      parentId: json['parentId'] as int?,
      memberCount: json['memberCount'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'role': role,
      'parentId': parentId,
      'memberCount': memberCount,
    };
  }
}

/// User hierarchy model containing group permissions
class UserHierarchy {
  final List<UserGroup> myGroups;
  final List<int> canManageGroupIds;
  final List<int> canViewGroupIds;

  const UserHierarchy({
    required this.myGroups,
    required this.canManageGroupIds,
    required this.canViewGroupIds,
  });

  factory UserHierarchy.fromJson(Map<String, dynamic> json) {
    return UserHierarchy(
      myGroups: (json['myGroups'] as List<dynamic>)
          .map((group) => UserGroup.fromJson(group as Map<String, dynamic>))
          .toList(),
      canManageGroupIds: (json['canManageGroupIds'] as List<dynamic>)
          .map((id) => id as int)
          .toList(),
      canViewGroupIds: (json['canViewGroupIds'] as List<dynamic>)
          .map((id) => id as int)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'myGroups': myGroups.map((group) => group.toJson()).toList(),
      'canManageGroupIds': canManageGroupIds,
      'canViewGroupIds': canViewGroupIds,
    };
  }

  /// Check if user can manage a specific group
  bool canManageGroup(int groupId) => canManageGroupIds.contains(groupId);

  /// Check if user can view a specific group
  bool canViewGroup(int groupId) => canViewGroupIds.contains(groupId);

  /// Get groups by type (fellowship, zone, etc.)
  List<UserGroup> getGroupsByType(String type) {
    return myGroups.where((group) => group.type == type).toList();
  }

  /// Get fellowship groups (Missional Communities)
  List<UserGroup> get fellowshipGroups => getGroupsByType('fellowship');

  /// Get zone groups
  List<UserGroup> get zoneGroups => getGroupsByType('zone');
}

/// User model for authentication and authorization
class User {
  final int id;
  final int contactId;
  final String username;
  final String email;
  final String fullName;
  final String avatar;
  final bool isActive;
  final List<String> roles;
  final List<String> permissions;
  final UserHierarchy hierarchy;

  const User({
    required this.id,
    required this.contactId,
    required this.username,
    required this.email,
    required this.fullName,
    required this.avatar,
    required this.isActive,
    required this.roles,
    required this.permissions,
    required this.hierarchy,
  });

  /// Get primary role
  String get primaryRole => roles.isNotEmpty ? roles.first : 'Unknown';

  /// Check if user has a specific role
  bool hasRole(String role) => roles.contains(role);

  /// Check if user has a specific permission
  bool hasPermission(String permission) => permissions.contains(permission);

  /// Check if user is a fellowship leader (MC Shepherd)
  bool get isFellowshipLeader => hasRole('MC Shepherd');

  /// Check if user is a zone leader
  bool get isZoneLeader => hasRole('Zone Leader');

  /// Check if user is a location pastor
  bool get isLocationPastor => hasRole('Location Pastor');

  /// Check if user is a movement leader
  bool get isMovementLeader => hasRole('Movement Leader');

  /// Check if user can submit reports
  bool get canSubmitReports => hasPermission('REPORT_SUBMIT');

  /// Check if user can view reports
  bool get canViewReports => hasPermission('REPORT_VIEW');

  /// Check if user can view report submissions (from others)
  bool get canViewSubmissions => hasPermission('REPORT_VIEW_SUBMISSIONS');

  /// Check if user can access CRM
  bool get canAccessCRM =>
      hasPermission('CRM_VIEW') || hasPermission('CRM_EDIT');

  /// Get church name from first group's category or default
  String get churchName {
    if (hierarchy.myGroups.isNotEmpty) {
      // This might need adjustment based on actual church name source
      return 'Worship Harvest'; // Default, could be derived from group structure
    }
    return 'Unknown Church';
  }

  factory User.fromJson(Map<String, dynamic> json, UserHierarchy hierarchy) {
    return User(
      id: json['id'] as int,
      contactId: json['contactId'] as int,
      username: json['username'] as String,
      email: json['email'] as String,
      fullName: json['fullName'] as String,
      avatar: json['avatar'] as String,
      isActive: json['isActive'] as bool,
      roles: (json['roles'] as List<dynamic>)
          .map((role) => role as String)
          .toList(),
      permissions: (json['permissions'] as List<dynamic>)
          .map((perm) => perm as String)
          .toList(),
      hierarchy: hierarchy,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contactId': contactId,
      'username': username,
      'email': email,
      'fullName': fullName,
      'avatar': avatar,
      'isActive': isActive,
      'roles': roles,
      'permissions': permissions,
      'hierarchy': hierarchy.toJson(),
    };
  }
}

/// Authentication response model
class AuthResponse {
  final String token;
  final String refreshToken;
  final int expiresIn;
  final User user;

  const AuthResponse({
    required this.token,
    required this.refreshToken,
    required this.expiresIn,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final hierarchy = UserHierarchy.fromJson(
      json['hierarchy'] as Map<String, dynamic>,
    );
    final user = User.fromJson(json['user'] as Map<String, dynamic>, hierarchy);

    return AuthResponse(
      token: json['token'] as String,
      refreshToken: json['refreshToken'] as String,
      expiresIn: json['expiresIn'] as int,
      user: user,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'refreshToken': refreshToken,
      'expiresIn': expiresIn,
      'user': user.toJson(),
    };
  }
}
