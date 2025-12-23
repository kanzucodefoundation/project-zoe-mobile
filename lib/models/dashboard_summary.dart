// Helper functions for safe parsing
int _parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is String) {
    // Handle decimal strings by parsing as double first then converting to int
    final parsed = double.tryParse(value);
    return parsed?.round() ?? 0;
  }
  if (value is double) return value.round();
  return 0;
}

int? _parseIntNullable(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is String) {
    if (value.isEmpty) return null;
    final parsed = double.tryParse(value);
    return parsed?.round();
  }
  if (value is double) return value.round();
  return null;
}

class DashboardSummary {
  final DashboardGroup group;
  final WeeklyStats thisWeek;
  final WeeklyStats lastWeek;
  final DashboardTrend trend;
  final List<String> pendingReports;
  final List<DashboardActivity> recentActivity;

  DashboardSummary({
    required this.group,
    required this.thisWeek,
    required this.lastWeek,
    required this.trend,
    required this.pendingReports,
    required this.recentActivity,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      group: DashboardGroup.fromJson(json['group'] as Map<String, dynamic>),
      thisWeek: WeeklyStats.fromJson(json['thisWeek'] as Map<String, dynamic>),
      lastWeek: WeeklyStats.fromJson(json['lastWeek'] as Map<String, dynamic>),
      trend: DashboardTrend.fromJson(json['trend'] as Map<String, dynamic>),
      pendingReports: (json['pendingReports'] as List).cast<String>(),
      recentActivity: (json['recentActivity'] as List)
          .map(
            (activity) =>
                DashboardActivity.fromJson(activity as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'group': group.toJson(),
      'thisWeek': thisWeek.toJson(),
      'lastWeek': lastWeek.toJson(),
      'trend': trend.toJson(),
      'pendingReports': pendingReports,
      'recentActivity': recentActivity
          .map((activity) => activity.toJson())
          .toList(),
    };
  }
}

class DashboardGroup {
  final int id;
  final String name;
  final String type;
  final int memberCount;
  final int activeMembers;

  DashboardGroup({
    required this.id,
    required this.name,
    required this.type,
    required this.memberCount,
    required this.activeMembers,
  });

  factory DashboardGroup.fromJson(Map<String, dynamic> json) {
    return DashboardGroup(
      id: _parseInt(json['id']),
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? '',
      memberCount: _parseInt(json['memberCount']),
      activeMembers: _parseInt(json['activeMembers']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'memberCount': memberCount,
      'activeMembers': activeMembers,
    };
  }
}

class WeeklyStats {
  final int attendance;
  final int visitors;
  final int? newMembers;
  final int? salvations;
  final int? baptisms;

  WeeklyStats({
    required this.attendance,
    required this.visitors,
    this.newMembers,
    this.salvations,
    this.baptisms,
  });

  factory WeeklyStats.fromJson(Map<String, dynamic> json) {
    return WeeklyStats(
      attendance: _parseInt(json['attendance']),
      visitors: _parseInt(json['visitors']),
      newMembers: _parseIntNullable(json['newMembers']),
      salvations: _parseIntNullable(json['salvations']),
      baptisms: _parseIntNullable(json['baptisms']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'attendance': attendance,
      'visitors': visitors,
      'newMembers': newMembers,
      'salvations': salvations,
      'baptisms': baptisms,
    };
  }
}

class DashboardTrend {
  final int attendanceChange;
  final int visitorsChange;

  DashboardTrend({
    required this.attendanceChange,
    required this.visitorsChange,
  });

  factory DashboardTrend.fromJson(Map<String, dynamic> json) {
    return DashboardTrend(
      attendanceChange: _parseInt(json['attendanceChange']),
      visitorsChange: _parseInt(json['visitorsChange']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'attendanceChange': attendanceChange,
      'visitorsChange': visitorsChange,
    };
  }
}

class DashboardActivity {
  final String type;
  final String description;
  final String timestamp;

  DashboardActivity({
    required this.type,
    required this.description,
    required this.timestamp,
  });

  factory DashboardActivity.fromJson(Map<String, dynamic> json) {
    return DashboardActivity(
      type: json['type'] as String? ?? '',
      description: json['description'] as String? ?? '',
      timestamp: json['timestamp'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'type': type, 'description': description, 'timestamp': timestamp};
  }
}
