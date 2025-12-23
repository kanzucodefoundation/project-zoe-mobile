import 'package:project_zoe/models/reports_model.dart';

class Report {
  final int id;
  final String name;
  final String description;
  final String submissionFrequency;
  final bool active;
  final String status;
  final TargetGroupCategory targetGroupCategory;
  final int? fieldCount;
  final List<ReportField>? fields;

  Report({
    required this.id,
    required this.name,
    required this.description,
    required this.submissionFrequency,
    required this.active,
    required this.status,
    required this.targetGroupCategory,
    this.fieldCount,
    this.fields,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      submissionFrequency: json['submissionFrequency'] as String,
      active: json['active'] as bool,
      status: json['status'] as String,
      targetGroupCategory: TargetGroupCategory.fromJson(
        json['targetGroupCategory'] as Map<String, dynamic>,
      ),
      fieldCount: json['fieldCount'] as int?,
      fields: json['fields'] != null
          ? (json['fields'] as List<dynamic>)
                .map((e) => ReportField.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'submissionFrequency': submissionFrequency,
      'active': active,
      'status': status,
      'targetGroupCategory': targetGroupCategory.toJson(),
      if (fieldCount != null) 'fieldCount': fieldCount,
      if (fields != null) 'fields': fields!.map((e) => e.toJson()).toList(),
    };
  }
}
