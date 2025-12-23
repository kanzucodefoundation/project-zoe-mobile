class Group {
  final int id;
  final String name;
  final String type;
  final int categoryId;
  final String categoryName;
  final String role;
  final String privacy;
  final int? parentId;
  final int memberCount;
  final int activeMembers;
  final String? details;
  final Map<String, dynamic>? metaData;

  Group({
    required this.id,
    required this.name,
    required this.type,
    required this.categoryId,
    required this.categoryName,
    required this.role,
    required this.privacy,
    this.parentId,
    required this.memberCount,
    required this.activeMembers,
    this.details,
    this.metaData,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'] as int,
      name: json['name'] as String,
      type: json['type'] as String,
      categoryId: json['categoryId'] as int,
      categoryName: json['categoryName'] as String,
      role: json['role'] as String,
      privacy: json['privacy'] as String,
      parentId: json['parentId'] as int?,
      memberCount: json['memberCount'] as int,
      activeMembers: json['activeMembers'] as int,
      details: json['details'] as String?,
      metaData: json['metaData'] != null
          ? Map<String, dynamic>.from(json['metaData'] as Map)
          : null,
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
      'privacy': privacy,
      if (parentId != null) 'parentId': parentId,
      'memberCount': memberCount,
      'activeMembers': activeMembers,
      if (details != null) 'details': details,
      if (metaData != null) 'metaData': metaData,
    };
  }
}

// groups_summary.dart
class GroupsSummary {
  final int totalGroups;
  final int totalMembers;

  GroupsSummary({required this.totalGroups, required this.totalMembers});

  factory GroupsSummary.fromJson(Map<String, dynamic> json) {
    return GroupsSummary(
      totalGroups: json['totalGroups'] as int,
      totalMembers: json['totalMembers'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {'totalGroups': totalGroups, 'totalMembers': totalMembers};
  }
}

// groups_response.dart
class GroupsResponse {
  final List<Group> groups;
  final GroupsSummary summary;

  GroupsResponse({required this.groups, required this.summary});

  factory GroupsResponse.fromJson(Map<String, dynamic> json) {
    return GroupsResponse(
      groups: (json['groups'] as List<dynamic>)
          .map((e) => Group.fromJson(e as Map<String, dynamic>))
          .toList(),
      summary: GroupsSummary.fromJson(json['summary'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'groups': groups.map((e) => e.toJson()).toList(),
      'summary': summary.toJson(),
    };
  }
}

// Get my groups endpoint:
// final response = await http.get(Uri.parse('your-api/groups/me'));
// final groupsResponse = GroupsResponse.fromJson(jsonDecode(response.body));
// final myGroups = groupsResponse.groups;
// final totalGroups = groupsResponse.summary.totalGroups;
