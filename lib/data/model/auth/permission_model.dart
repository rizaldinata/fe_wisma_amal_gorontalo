import 'package:frontend/domain/entity/permission_entity.dart';

class PermissionModel extends PermissionEntity {
  const PermissionModel({
    required super.id,
    required super.name,
    super.target,
    super.description,
  });

  factory PermissionModel.fromJson(Map<String, dynamic> json) {
    return PermissionModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      target: json['target'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'target': target, 'description': description};
  }

  factory PermissionModel.fromEntity(PermissionEntity entity) {
    return PermissionModel(
      id: entity.id,
      name: entity.name,
      target: entity.target,
      description: entity.description,
    );
  }

  PermissionEntity toEntity() => PermissionEntity(
    id: id,
    name: name,
    target: target,
    description: description,
  );
}
