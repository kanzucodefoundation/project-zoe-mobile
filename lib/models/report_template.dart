// /// Model for report template with fields and configuration
// class ReportTemplate {
//   final int id;
//   final String name;
//   final String description;
//   final String functionName;
//   final String viewType;
//   final String? sqlQuery;
//   final List<DisplayColumn> displayColumns;
//   final String? footer;
//   final String? labels;
//   final String? dataPoints;
//   final String submissionFrequency;
//   final bool active;
//   final String status;
//   final List<ReportField> fields;

//   ReportTemplate({
//     required this.id,
//     required this.name,
//     required this.description,
//     required this.functionName,
//     required this.viewType,
//     this.sqlQuery,
//     required this.displayColumns,
//     this.footer,
//     this.labels,
//     this.dataPoints,
//     required this.submissionFrequency,
//     required this.active,
//     required this.status,
//     required this.fields,
//   });

//   factory ReportTemplate.fromJson(Map<String, dynamic> json) {
//     return ReportTemplate(
//       id: json['id'],
//       name: json['name'],
//       description: json['description'],
//       functionName: json['functionName'],
//       viewType: json['viewType'],
//       sqlQuery: json['sqlQuery'],
//       displayColumns: (json['displayColumns'] as List)
//           .map((col) => DisplayColumn.fromJson(col))
//           .toList(),
//       footer: json['footer'],
//       labels: json['labels'],
//       dataPoints: json['dataPoints'],
//       submissionFrequency: json['submissionFrequency'],
//       active: json['active'],
//       status: json['status'],
//       fields: (json['fields'] as List)
//           .map((field) => ReportField.fromJson(field))
//           .toList(),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'name': name,
//       'description': description,
//       'functionName': functionName,
//       'viewType': viewType,
//       'sqlQuery': sqlQuery,
//       'displayColumns': displayColumns.map((col) => col.toJson()).toList(),
//       'footer': footer,
//       'labels': labels,
//       'dataPoints': dataPoints,
//       'submissionFrequency': submissionFrequency,
//       'active': active,
//       'status': status,
//       'fields': fields.map((field) => field.toJson()).toList(),
//     };
//   }
// }

// /// Model for display column configuration
// class DisplayColumn {
//   final String name;
//   final String label;

//   DisplayColumn({required this.name, required this.label});

//   factory DisplayColumn.fromJson(Map<String, dynamic> json) {
//     return DisplayColumn(name: json['name'], label: json['label']);
//   }

//   Map<String, dynamic> toJson() {
//     return {'name': name, 'label': label};
//   }
// }

// /// Model for report field configuration
// class ReportField {
//   final int id;
//   final String name;
//   final String type;
//   final String label;
//   final bool required;
//   final bool hidden;
//   final String? options;

//   ReportField({
//     required this.id,
//     required this.name,
//     required this.type,
//     required this.label,
//     required this.required,
//     required this.hidden,
//     this.options,
//   });

//   factory ReportField.fromJson(Map<String, dynamic> json) {
//     return ReportField(
//       id: json['id'],
//       name: json['name'],
//       type: json['type'],
//       label: json['label'],
//       required: json['required'],
//       hidden: json['hidden'],
//       options: json['options'],
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'name': name,
//       'type': type,
//       'label': label,
//       'required': required,
//       'hidden': hidden,
//       'options': options,
//     };
//   }
// }
