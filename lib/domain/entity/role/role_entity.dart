import 'package:equatable/equatable.dart';
import 'package:frontend/domain/entity/permission_entity.dart';

class RoleEntity extends Equatable {
  final int id;
  final String name;
  final String? description;
  final List<PermissionEntity> permissions;

  const RoleEntity({
    required this.id,
    required this.name,
    this.description,
    this.permissions = const [],
  });

  @override
  List<Object?> get props => [id, name, description, permissions];
}
