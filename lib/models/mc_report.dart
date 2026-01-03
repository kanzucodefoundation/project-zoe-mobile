class McReport {
  final String id;
  final String title;
  final String description;
  final DateTime createdAt;

  McReport({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
  });

  factory McReport.fromJson(Map<String, dynamic> json) {
    return McReport(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}