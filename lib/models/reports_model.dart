// target_group_category.dart

class TargetGroupCategory {
  final int id;
  final String name;

  TargetGroupCategory({required this.id, required this.name});

  factory TargetGroupCategory.fromJson(Map<String, dynamic> json) {
    return TargetGroupCategory(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}

// report_field.dart
class ReportField {
  final int id;
  final String name;
  final String type;
  final String label;
  final bool required;
  final bool hidden;
  final List<dynamic>? options;
  final int order;

  ReportField({
    required this.id,
    required this.name,
    required this.type,
    required this.label,
    required this.required,
    required this.hidden,
    this.options,
    this.order = 0,
  });

  factory ReportField.fromJson(Map<String, dynamic> json) {
    return ReportField(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? '',
      label: json['label'] as String? ?? '',
      required: json['required'] as bool? ?? false,
      hidden: json['hidden'] as bool? ?? false,
      options: json['options'] != null
          ? List<dynamic>.from(json['options'] as List)
          : null,
      order: json['order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'label': label,
      'required': required,
      'hidden': hidden,
      'options': options,
      'order': order,
    };
  }
}
// Example usage:
// 
// List endpoint:
// final response = await http.get(Uri.parse('your-api/reports'));
// final reportsResponse = ReportsResponse.fromJson(jsonDecode(response.body));
// final reportsList = reportsResponse.reports;
//
// Single report endpoint (with fields):
// final response = await http.get(Uri.parse('your-api/reports/1'));
// final report = Report.fromJson(jsonDecode(response.body));
// final fields = report.fields; // List<ReportField>?