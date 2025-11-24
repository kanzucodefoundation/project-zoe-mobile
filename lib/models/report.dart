/// Report model representing different types of reports in the system
class Report {
  final String id;
  final String title;
  final String description;
  final ReportType type;
  final ReportStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String createdBy;
  final String? assignedTo;
  final List<String> tags;
  final Map<String, dynamic> data;
  final int priority;

  const Report({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.status,
    required this.createdAt,
    this.completedAt,
    required this.createdBy,
    this.assignedTo,
    required this.tags,
    required this.data,
    this.priority = 1,
  });

  /// Get status display name
  String get statusDisplayName {
    switch (status) {
      case ReportStatus.pending:
        return 'Pending';
      case ReportStatus.inProgress:
        return 'In Progress';
      case ReportStatus.completed:
        return 'Completed';
      case ReportStatus.cancelled:
        return 'Cancelled';
    }
  }

  /// Get type display name
  String get typeDisplayName {
    switch (type) {
      case ReportType.attendance:
        return 'Attendance Report';
      case ReportType.financial:
        return 'Financial Report';
      case ReportType.membership:
        return 'Membership Report';
      case ReportType.events:
        return 'Events Report';
      case ReportType.shepherds:
        return 'Shepherds Report';
      case ReportType.general:
        return 'General Report';
    }
  }

  /// Get priority display name
  String get priorityDisplayName {
    switch (priority) {
      case 1:
        return 'Low';
      case 2:
        return 'Medium';
      case 3:
        return 'High';
      case 4:
        return 'Critical';
      default:
        return 'Medium';
    }
  }

  /// Check if report is overdue (pending for more than 7 days)
  bool get isOverdue {
    if (status != ReportStatus.pending) return false;
    return DateTime.now().difference(createdAt).inDays > 7;
  }

  /// Get days since creation
  int get daysSinceCreated {
    return DateTime.now().difference(createdAt).inDays;
  }

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: ReportType.values.firstWhere(
        (type) => type.name == json['type'],
        orElse: () => ReportType.general,
      ),
      status: ReportStatus.values.firstWhere(
        (status) => status.name == json['status'],
        orElse: () => ReportStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      createdBy: json['createdBy'] ?? '',
      assignedTo: json['assignedTo'],
      tags: List<String>.from(json['tags'] ?? []),
      data: Map<String, dynamic>.from(json['data'] ?? {}),
      priority: json['priority'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'createdBy': createdBy,
      'assignedTo': assignedTo,
      'tags': tags,
      'data': data,
      'priority': priority,
    };
  }

  Report copyWith({
    String? id,
    String? title,
    String? description,
    ReportType? type,
    ReportStatus? status,
    DateTime? createdAt,
    DateTime? completedAt,
    String? createdBy,
    String? assignedTo,
    List<String>? tags,
    Map<String, dynamic>? data,
    int? priority,
  }) {
    return Report(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      createdBy: createdBy ?? this.createdBy,
      assignedTo: assignedTo ?? this.assignedTo,
      tags: tags ?? this.tags,
      data: data ?? this.data,
      priority: priority ?? this.priority,
    );
  }
}

/// Report types enum
enum ReportType {
  attendance,
  financial,
  membership,
  events,
  shepherds,
  general,
}

/// Report status enum
enum ReportStatus { pending, inProgress, completed, cancelled }
