class Group {
  final int id;
  final String name;
  final String type;
  final int categoryId;
  final String categoryName;
  final String? role;
  final String privacy;
  final String details;
  final int? parentId;
  final GroupParent? parent;
  final int memberCount;
  final int activeMembers;
  final GroupMetaData? metaData;
  final Map<String, dynamic>? address;

  Group({
    required this.id,
    required this.name,
    required this.type,
    required this.categoryId,
    required this.categoryName,
    this.role,
    required this.privacy,
    required this.details,
    this.parentId,
    this.parent,
    required this.memberCount,
    required this.activeMembers,
    this.metaData,
    this.address,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'Unknown Group',
      type: json['type'] as String? ?? 'Unknown Type',
      categoryId: json['categoryId'] as int? ?? 0,
      categoryName: json['categoryName'] as String? ?? 'Unknown Category',
      role: json['role'] as String?,
      privacy: json['privacy'] as String? ?? 'Private',
      details: json['details'] as String? ?? '',
      parentId: json['parentId'] as int?,
      parent: json['parent'] != null
          ? GroupParent.fromJson(json['parent'] as Map<String, dynamic>)
          : null,
      memberCount: json['memberCount'] as int? ?? 0,
      activeMembers: json['activeMembers'] as int? ?? 0,
      metaData: json['metaData'] != null
          ? GroupMetaData.fromJson(json['metaData'] as Map<String, dynamic>)
          : null,
      address: json['address'] as Map<String, dynamic>?,
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
      'details': details,
      'parentId': parentId,
      'parent': parent?.toJson(),
      'memberCount': memberCount,
      'activeMembers': activeMembers,
      'metaData': metaData?.toJson(),
    };
  }
}

class GroupParent {
  final int id;
  final String name;

  GroupParent({required this.id, required this.name});

  factory GroupParent.fromJson(Map<String, dynamic> json) {
    return GroupParent(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'Unknown Parent',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}

class GroupMetaData {
  final String? meetingDay;
  final String? meetingTime;

  GroupMetaData({this.meetingDay, this.meetingTime});

  factory GroupMetaData.fromJson(Map<String, dynamic> json) {
    return GroupMetaData(
      meetingDay: json['meetingDay'] as String?,
      meetingTime: json['meetingTime'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'meetingDay': meetingDay, 'meetingTime': meetingTime};
  }
}

class GroupsResponse {
  final List<Group> groups;
  final GroupsSummary summary;

  GroupsResponse({required this.groups, required this.summary});

  factory GroupsResponse.fromJson(Map<String, dynamic> json) {
    return GroupsResponse(
      groups: (json['groups'] as List)
          .map((group) => Group.fromJson(group as Map<String, dynamic>))
          .toList(),
      summary: GroupsSummary.fromJson(json['summary'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'groups': groups.map((group) => group.toJson()).toList(),
      'summary': summary.toJson(),
    };
  }
}

class GroupsSummary {
  final int totalGroups;
  final int totalMembers;

  GroupsSummary({required this.totalGroups, required this.totalMembers});

  factory GroupsSummary.fromJson(Map<String, dynamic> json) {
    return GroupsSummary(
      totalGroups: json['totalGroups'] as int? ?? 0,
      totalMembers: json['totalMembers'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'totalGroups': totalGroups, 'totalMembers': totalMembers};
  }
}

// Get my groups endpoint:
// final response = await http.get(Uri.parse('your-api/groups/me'));
// final groupsResponse = GroupsResponse.fromJson(jsonDecode(response.body));
// final myGroups = groupsResponse.groups;
// final totalGroups = groupsResponse.summary.totalGroups;
