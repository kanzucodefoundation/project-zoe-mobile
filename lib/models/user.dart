/// Authentication models for the new server structure
library;

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
      type: json['type'] as String? ?? 'group', // Default type if missing
      categoryId: (json['categoryId'] as int?) ?? 0, // Handle null categoryId
      categoryName: (json['categoryName'] as String?) ?? '', // Handle null categoryName
      role: (json['role'] as String?) ?? '', // Handle null role
      parentId: json['parentId'] as int?,
      memberCount: (json['memberCount'] as int?) ?? 0, // Handle null memberCount
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

  /// Convert to dropdown-friendly map for UI components
  Map<String, dynamic> toDropdownMap() {
    return {'id': id, 'name': name, 'type': type, 'role': role};
  }

  /// Display name with member count for UI
  String get displayNameWithCount => '$name ($memberCount members)';

  /// Display name with role for UI
  String get displayNameWithRole => '$name - $role';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserGroup && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'UserGroup(id: $id, name: $name, type: $type, role: $role)';

  UserGroup copyWith({
    int? id,
    String? name,
    String? type,
    int? categoryId,
    String? categoryName,
    String? role,
    int? parentId,
    int? memberCount,
  }) {
    return UserGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      role: role ?? this.role,
      parentId: parentId ?? this.parentId,
      memberCount: memberCount ?? this.memberCount,
    );
  }
}

/// User hierarchy model containing group permissions
class UserHierarchy {
  final List<UserGroup> myGroups;
  final List<UserGroup> canManageGroups;
  final List<UserGroup> canViewGroups;
  
  // Keep legacy fields for backward compatibility
  final List<int> canManageGroupIds;
  final List<int> canViewGroupIds;

  UserHierarchy({
    required this.myGroups,
    required this.canManageGroups,
    required this.canViewGroups,
    this.canManageGroupIds = const [],
    this.canViewGroupIds = const [],
  });

  /// Create empty hierarchy for users without hierarchy data
  UserHierarchy.empty()
    : myGroups = const [],
      canManageGroups = const [],
      canViewGroups = const [],
      canManageGroupIds = const [],
      canViewGroupIds = const [];

  factory UserHierarchy.fromJson(Map<String, dynamic> json) {
    // Handle new format with full group objects
    final canManageGroups = (json['canManageGroups'] as List<dynamic>?)
        ?.map((group) => UserGroup.fromJson(group as Map<String, dynamic>))
        .toList() ?? const <UserGroup>[];
        
    final canViewGroups = (json['canViewGroups'] as List<dynamic>?)
        ?.map((group) => UserGroup.fromJson(group as Map<String, dynamic>))
        .toList() ?? const <UserGroup>[];

    // Handle legacy format with IDs only (for backward compatibility)
    final canManageGroupIds = (json['canManageGroupIds'] as List<dynamic>?)
        ?.map((id) => id as int)
        .toList() ?? canManageGroups.map((g) => g.id).toList();
        
    final canViewGroupIds = (json['canViewGroupIds'] as List<dynamic>?)
        ?.map((id) => id as int)
        .toList() ?? canViewGroups.map((g) => g.id).toList();

    return UserHierarchy(
      myGroups: (json['myGroups'] as List<dynamic>?)
          ?.map((group) => UserGroup.fromJson(group as Map<String, dynamic>))
          .toList() ?? const [],
      canManageGroups: canManageGroups,
      canViewGroups: canViewGroups,
      canManageGroupIds: canManageGroupIds,
      canViewGroupIds: canViewGroupIds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'myGroups': myGroups.map((group) => group.toJson()).toList(),
      'canManageGroups': canManageGroups.map((group) => group.toJson()).toList(),
      'canViewGroups': canViewGroups.map((group) => group.toJson()).toList(),
      'canManageGroupIds': canManageGroupIds,
      'canViewGroupIds': canViewGroupIds,
    };
  }

  /// Check if user can manage a specific group
  bool canManageGroup(int groupId) {
    return canManageGroups.any((g) => g.id == groupId) || 
           canManageGroupIds.contains(groupId);
  }

  /// Check if user can view a specific group
  bool canViewGroup(int groupId) {
    return canViewGroups.any((g) => g.id == groupId) || 
           canViewGroupIds.contains(groupId);
  }

  /// Get groups by type (fellowship, zone, etc.)
  List<UserGroup> getGroupsByType(String type) {
    return myGroups.where((group) => group.type == type).toList();
  }

  /// Get fellowship groups (Missional Communities)
  List<UserGroup> get fellowshipGroups => getGroupsByType('fellowship');

  /// Get zone groups
  List<UserGroup> get zoneGroups => getGroupsByType('zone');

  /// Get location groups
  List<UserGroup> get locationGroups => getGroupsByType('location');

  /// Get FOB groups
  List<UserGroup> get fobGroups => getGroupsByType('fob');

  /// Get network groups
  List<UserGroup> get networkGroups => getGroupsByType('network');

  /// Get all groups that can be managed
  List<UserGroup> get manageableGroups {
    return myGroups
        .where((group) => canManageGroupIds.contains(group.id))
        .toList();
  }

  /// Get all groups that can be viewed (including manageable ones)
  List<UserGroup> get viewableGroups {
    return myGroups
        .where(
          (group) =>
              canViewGroupIds.contains(group.id) ||
              canManageGroupIds.contains(group.id),
        )
        .toList();
  }

  /// Get unique groups by ID to prevent duplicates in dropdowns
  List<UserGroup> get uniqueGroups {
    final seen = <int>{};
    return myGroups.where((group) {
      if (seen.contains(group.id)) return false;
      seen.add(group.id);
      return true;
    }).toList();
  }

  /// Get groups suitable for dropdown selection (unique + formatted)
  List<Map<String, dynamic>> getDropdownGroups({String? filterByType}) {
    var groups = uniqueGroups;

    if (filterByType != null) {
      groups = groups.where((g) => g.type == filterByType).toList();
    }

    return groups.map((g) => g.toDropdownMap()).toList();
  }

  /// Find a group by ID
  UserGroup? findGroupById(int id) {
    try {
      return myGroups.firstWhere((group) => group.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Check if user has any groups
  bool get hasGroups => myGroups.isNotEmpty;

  /// Check if user has manageable groups
  bool get hasManageableGroups => canManageGroupIds.isNotEmpty;
}

/// User model for authentication and authorization
class User {
  final int id;
  final int contactId;
  final String username;
  final String? email; // Optional - not in all endpoints
  final String fullName;
  final String avatar;
  final bool isActive;
  final List<String> roles;
  final List<String> permissions; // Optional - not in all endpoints
  final UserHierarchy hierarchy; // Optional - not in all endpoints

  User({
    required this.id,
    required this.contactId,
    required this.username,
    this.email,
    required this.fullName,
    required this.avatar,
    required this.isActive,
    required this.roles,
    this.permissions = const [],
    UserHierarchy? hierarchy,
  }) : hierarchy = hierarchy ?? UserHierarchy.empty();

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

  /// Check if user is a FOB leader
  bool get isFOBLeader => hasRole('FOB Leader');

  /// Check if user is a network leader
  bool get isNetworkLeader => hasRole('Network Leader');

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

  bool get canEditCRM => hasPermission('CRM_EDIT');

  /// Get church name from first group's category or default
  String get churchName {
    if (hierarchy.myGroups.isNotEmpty) {
      return hierarchy.myGroups.first.categoryName;
    }
    return 'Unknown Church';
  }

  /// Get user's fellowship groups for dropdown
  List<Map<String, dynamic>> get fellowshipDropdownList {
    return hierarchy.getDropdownGroups(filterByType: 'fellowship');
  }

  /// Get user's zone groups for dropdown
  List<Map<String, dynamic>> get zoneDropdownList {
    return hierarchy.getDropdownGroups(filterByType: 'zone');
  }

  /// Get all manageable groups for reporting
  List<UserGroup> get manageableGroups {
    return hierarchy.manageableGroups;
  }

  /// Get display name with primary role
  String get displayNameWithRole => '$fullName ($primaryRole)';

  /// Get user initials for avatar fallback
  String get initials {
    final parts = fullName.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';
  }

  /// Check if user has multiple roles (acts as multiple leaders)
  bool get hasMultipleRoles => roles.length > 1;

  /// Get formatted roles string for display
  String get rolesDisplay => roles.join(', ');

  /// Factory for simple user lists (without email, permissions, hierarchy)
  factory User.fromSimpleJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      contactId: json['contactId'] as int,
      username: json['username'] as String,
      email: json['email'] as String?,
      fullName: json['fullName'] as String,
      avatar: (json['avatar'] as String?) ?? '', // Handle null avatar
      isActive: json['isActive'] as bool,
      roles: (json['roles'] as List<dynamic>)
          .map((role) => role as String)
          .toList(),
      permissions: const [], // Empty permissions
      hierarchy: UserHierarchy.empty(), // Empty hierarchy
    );
  }

  /// Factory for full user data (with email, permissions, hierarchy)
  factory User.fromJson(Map<String, dynamic> json, [UserHierarchy? hierarchy]) {
    // If hierarchy is provided, use it (for auth responses)
    // Otherwise try to parse from json or use empty
    final userHierarchy =
        hierarchy ??
        (json.containsKey('hierarchy')
            ? UserHierarchy.fromJson(json['hierarchy'] as Map<String, dynamic>)
            : UserHierarchy.empty());

    return User(
      id: json['id'] as int,
      contactId: json['contactId'] as int,
      username: json['username'] as String,
      email: json['email'] as String?,
      fullName: json['fullName'] as String,
      avatar: (json['avatar'] as String?) ?? '', // Handle null avatar
      isActive: json['isActive'] as bool,
      roles: (json['roles'] as List<dynamic>)
          .map((role) => role as String)
          .toList(),
      permissions: json.containsKey('permissions')
          ? (json['permissions'] as List<dynamic>)
                .map((perm) => perm as String)
                .toList()
          : const [],
      hierarchy: userHierarchy,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contactId': contactId,
      'username': username,
      if (email != null) 'email': email,
      'fullName': fullName,
      'avatar': avatar,
      'isActive': isActive,
      'roles': roles,
      'permissions': permissions,
      'hierarchy': hierarchy.toJson(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'User(id: $id, name: $fullName, roles: $roles)';

  User copyWith({
    int? id,
    int? contactId,
    String? username,
    String? email,
    String? fullName,
    String? avatar,
    bool? isActive,
    List<String>? roles,
    List<String>? permissions,
    UserHierarchy? hierarchy,
  }) {
    return User(
      id: id ?? this.id,
      contactId: contactId ?? this.contactId,
      username: username ?? this.username,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      avatar: avatar ?? this.avatar,
      isActive: isActive ?? this.isActive,
      roles: roles ?? this.roles,
      permissions: permissions ?? this.permissions,
      hierarchy: hierarchy ?? this.hierarchy,
    );
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
    final hierarchy = json.containsKey('hierarchy') 
        ? UserHierarchy.fromJson(json['hierarchy'] as Map<String, dynamic>)
        : UserHierarchy.empty();
    final user = User.fromJson(json['user'] as Map<String, dynamic>, hierarchy);

    return AuthResponse(
      token: json['token'] as String,
      refreshToken: (json['refreshToken'] as String?) ?? '', // Handle missing refreshToken
      expiresIn: (json['expiresIn'] as int?) ?? 3600, // Default 1 hour if missing
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

  /// Get token expiry date
  DateTime get expiryDate {
    return DateTime.now().add(Duration(seconds: expiresIn));
  }

  /// Check if token is expired or will expire soon (within 5 minutes)
  bool get isExpiringSoon {
    final expiryTime = expiryDate;
    final now = DateTime.now();
    final difference = expiryTime.difference(now);
    return difference.inMinutes <= 5;
  }

  @override
  String toString() =>
      'AuthResponse(user: ${user.fullName}, expiresIn: ${expiresIn}s)';
}

/// Pagination model for list responses
class Pagination {
  final int total;
  final int limit;
  final int offset;
  final bool hasMore;

  const Pagination({
    required this.total,
    required this.limit,
    required this.offset,
    required this.hasMore,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      total: json['total'] as int,
      limit: json['limit'] as int,
      offset: json['offset'] as int,
      hasMore: json['hasMore'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'limit': limit,
      'offset': offset,
      'hasMore': hasMore,
    };
  }

  /// Calculate current page (1-indexed)
  int get currentPage => (offset ~/ limit) + 1;

  /// Calculate total pages
  int get totalPages => (total / limit).ceil();

  /// Check if there's a previous page
  bool get hasPrevious => offset > 0;

  /// Get next offset
  int get nextOffset => offset + limit;

  /// Get previous offset
  int get previousOffset => offset - limit;

  @override
  String toString() =>
      'Pagination(total: $total, page: $currentPage/$totalPages)';
}

/// Generic list response with users and pagination
class UserListResponse {
  final List<User> users;
  final Pagination pagination;

  const UserListResponse({required this.users, required this.pagination});

  /// Factory for simple user list endpoint (without hierarchy in response)
  factory UserListResponse.fromJson(Map<String, dynamic> json) {
    return UserListResponse(
      users: (json['users'] as List<dynamic>)
          .map(
            (userJson) => User.fromSimpleJson(userJson as Map<String, dynamic>),
          )
          .toList(),
      pagination: Pagination.fromJson(
        json['pagination'] as Map<String, dynamic>,
      ),
    );
  }

  /// Factory for user list with shared hierarchy
  factory UserListResponse.fromJsonWithHierarchy(
    Map<String, dynamic> json,
    UserHierarchy hierarchy,
  ) {
    return UserListResponse(
      users: (json['users'] as List<dynamic>)
          .map(
            (userJson) =>
                User.fromJson(userJson as Map<String, dynamic>, hierarchy),
          )
          .toList(),
      pagination: Pagination.fromJson(
        json['pagination'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'users': users.map((user) => user.toJson()).toList(),
      'pagination': pagination.toJson(),
    };
  }

  /// Check if list is empty
  bool get isEmpty => users.isEmpty;

  /// Check if list is not empty
  bool get isNotEmpty => users.isNotEmpty;

  /// Get total count
  int get totalCount => pagination.total;

  /// Find user by ID
  User? findUserById(int id) {
    try {
      return users.firstWhere((user) => user.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Filter users by role
  List<User> filterByRole(String role) {
    return users.where((user) => user.hasRole(role)).toList();
  }

  /// Get active users only
  List<User> get activeUsers => users.where((user) => user.isActive).toList();

  @override
  String toString() =>
      'UserListResponse(users: ${users.length}, pagination: $pagination)';
}
