import '../entities/user.dart';

class UserModel extends UserEntity {
  UserModel({required super.id, required super.name, required super.email});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'].toString(),
      name: json['name'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'email': email};
}
