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
}
