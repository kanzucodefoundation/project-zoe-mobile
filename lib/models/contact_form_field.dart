/// Contact Form Field Model
/// Represents a dynamic form field configuration from the API
class ContactFormField {
  final String name;
  final String label;
  final String type;
  final bool required;
  final String? placeholder;
  final List<String>? options;

  ContactFormField({
    required this.name,
    required this.label,
    required this.type,
    this.required = false,
    this.placeholder,
    this.options,
  });

  factory ContactFormField.fromJson(Map<String, dynamic> json) {
    return ContactFormField(
      name: json['name'] ?? '',
      label: json['label'] ?? '',
      type: json['type'] ?? 'text',
      required: json['required'] ?? false,
      placeholder: json['placeholder'],
      options: json['options'] != null
          ? List<String>.from(json['options'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'label': label,
      'type': type,
      'required': required,
      'placeholder': placeholder,
      'options': options,
    };
  }
}
