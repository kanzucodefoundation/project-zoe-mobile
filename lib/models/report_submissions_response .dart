// Models
import 'package:project_zoe/models/report_submission.dart';

class ReportSubmissionsResponse {
  final List<ReportSubmission> submissions;
  final Pagination pagination;

  ReportSubmissionsResponse({
    required this.submissions,
    required this.pagination,
  });

  factory ReportSubmissionsResponse.fromJson(Map<String, dynamic> json) {
    return ReportSubmissionsResponse(
      submissions: (json['submissions'] as List)
          .map((e) => ReportSubmission.fromJson(e))
          .toList(),
      pagination: Pagination.fromJson(json['pagination']),
    );
  }
}

class Submitter {
  final int id;
  final String name;

  Submitter({required this.id, required this.name});

  factory Submitter.fromJson(Map<String, dynamic> json) {
    return Submitter(id: json['id'], name: json['name']);
  }
}

class Pagination {
  final int total;
  final int limit;
  final int offset;
  final bool hasMore;

  Pagination({
    required this.total,
    required this.limit,
    required this.offset,
    required this.hasMore,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      total: json['total'],
      limit: json['limit'],
      offset: json['offset'],
      hasMore: json['hasMore'],
    );
  }
}
