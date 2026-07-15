import 'package:frontend/data/model/auth/permission_model.dart';
import 'package:frontend/domain/entity/role/role_entity.dart';

class RoleModel extends RoleEntity {
  const RoleModel({
    required super.id,
    required super.name,
    super.description,
    super.permissions = const [],
  });

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      permissions: json['permissions'] != null
          ? (json['permissions'] as List)
              .map((p) => PermissionModel.fromJson(p))
              .toList()
          : const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'permissions': permissions.map((p) => (p as PermissionModel).toJson()).toList(),
    };
  }
}
