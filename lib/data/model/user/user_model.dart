import 'package:frontend/domain/entity/user/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    super.role,
    super.createdAt,
    super.phoneNumber,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    String? roleName;
    if (json['roles'] != null && (json['roles'] as List).isNotEmpty) {
      // Assuming we take the first role as the primary one
      roleName = json['roles'][0]['name'];
    }
    
    return UserModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: roleName,
      createdAt: json['created_at'],
      phoneNumber: json['phone_number'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'phone_number': phoneNumber,
    };
  }
}
