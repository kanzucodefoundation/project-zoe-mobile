import 'package:project_zoe/models/report.dart';

class ReportsResponse {
  final List<Report> reports;

  ReportsResponse({required this.reports});

  factory ReportsResponse.fromJson(Map<String, dynamic> json) {
    return ReportsResponse(
      reports: (json['reports'] as List<dynamic>)
          .map((e) => Report.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'reports': reports.map((e) => e.toJson()).toList()};
  }
}
