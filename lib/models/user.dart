/// User roles enum to define permission levels
enum UserRole { admin, restricted, moderator, viewer }

/// User model for authentication and authorization
class User {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String department;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.department,
  });

  /// Check if user has admin privileges
  bool get isAdmin => role == UserRole.admin;

  /// Check if user has restricted access
  bool get isRestricted => role == UserRole.restricted;

  /// Get role display name
  String get roleDisplayName {
    switch (role) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.restricted:
        return 'Restricted User';
      case UserRole.moderator:
        return 'Moderator';
      case UserRole.viewer:
        return 'Viewer';
    }
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: UserRole.values.firstWhere(
        (role) => role.name == json['role'],
        orElse: () => UserRole.restricted,
      ),
      department: json['department'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.name,
      'department': department,
    };
  }
}
