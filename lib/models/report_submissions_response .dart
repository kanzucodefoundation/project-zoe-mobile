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
    final submissionsList = json['submissions'] as List? ?? [];
    final paginationData = json['pagination'] as Map<String, dynamic>?;
    
    return ReportSubmissionsResponse(
      submissions: submissionsList
          .map((e) => ReportSubmission.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: paginationData != null
          ? Pagination.fromJson(paginationData)
          : Pagination(total: 0, limit: 10, offset: 0, hasMore: false),
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
      total: json['total'] as int? ?? 0,
      limit: json['limit'] as int? ?? 10,
      offset: json['offset'] as int? ?? 0,
      hasMore: json['hasMore'] as bool? ?? false,
    );
  }
}
