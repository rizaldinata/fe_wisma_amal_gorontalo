import 'package:frontend/data/model/auth/user_model.dart';
import 'package:frontend/domain/entity/permission_entity.dart';
import 'package:frontend/domain/entity/user_entity.dart';

class AuthResponseModel {
  final UserModel user;
  final String token;
  final String role;

  AuthResponseModel({
    required this.user,
    required this.token,
    required this.role,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      user: UserModel.fromJson(json['user']),
      token: json['token'],
      role: json['role'],
    );
  }

  UserEntity toEntity() {
    return UserEntity(
      id: user.id,
      name: user.name,
      email: user.email,
      roles: user.roles.map((role) => role.name).toList(),
      // permissions: Permissions(),
    );
  }
}
