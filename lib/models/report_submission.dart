class ReportSubmission {
  final int id;
  final int reportId;
  final String reportName;
  final int groupId;
  final String groupName;
  final String submittedAt;
  final SubmittedBy submittedBy;
  final Map<String, dynamic> data;
  final bool canEdit;

  ReportSubmission({
    required this.id,
    required this.reportId,
    required this.reportName,
    required this.groupId,
    required this.groupName,
    required this.submittedAt,
    required this.submittedBy,
    required this.data,
    required this.canEdit,
  });

  factory ReportSubmission.fromJson(Map<String, dynamic> json) {
    return ReportSubmission(
      id: json['id'] as int? ?? 0,
      reportId: json['reportId'] as int? ?? 0,
      reportName: json['reportName'] as String? ?? '',
      groupId: json['groupId'] as int? ?? 0,
      groupName: json['groupName'] as String? ?? '',
      submittedAt: json['submittedAt'] as String? ?? '',
      submittedBy: json['submittedBy'] != null
          ? SubmittedBy.fromJson(
              json['submittedBy'] as Map<String, dynamic>,
            )
          : SubmittedBy(id: 0, name: 'Unknown'),
      data: json['data'] != null
          ? Map<String, dynamic>.from(json['data'] as Map)
          : {},
      canEdit: json['canEdit'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reportId': reportId,
      'reportName': reportName,
      'groupId': groupId,
      'groupName': groupName,
      'submittedAt': submittedAt,
      'submittedBy': submittedBy.toJson(),
      'data': data,
      'canEdit': canEdit,
    };
  }
}

class SubmittedBy {
  final int id;
  final String name;

  SubmittedBy({required this.id, required this.name});

  factory SubmittedBy.fromJson(Map<String, dynamic> json) {
    return SubmittedBy(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'Unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}
