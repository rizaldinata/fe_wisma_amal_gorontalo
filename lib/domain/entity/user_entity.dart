import 'package:frontend/domain/entity/permission_entity.dart';

class UserEntity {
  int? id;
  String name;
  String email;
  List<String> roles;
  Permissions? permissions;

  UserEntity({
    this.id,
    required this.name,
    required this.email,
    required this.roles,
    this.permissions,
  });

  UserEntity copyWith({
    int? id,
    String? name,
    String? email,
    List<String>? roles,
    Permissions? permissions,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      roles: roles ?? this.roles,
      permissions: permissions ?? this.permissions,
    );
  }

  @override
  toString() {
    return 'UserEntity{id: $id, name: $name, email: $email, roles: $roles, permissions: ${permissions?.raw}}';
  }
}
