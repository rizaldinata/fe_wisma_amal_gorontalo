import 'package:equatable/equatable.dart';
import 'package:frontend/domain/entity/permission_entity.dart';

abstract class PermissionEvent extends Equatable {
  const PermissionEvent();
  @override
  List<Object?> get props => [];
}

class GetPermissionsEvent extends PermissionEvent {}

class AddPermissionEvent extends PermissionEvent {
  final PermissionEntity permission;
  const AddPermissionEvent(this.permission);
}

class UpdatePermissionEvent extends PermissionEvent {
  final PermissionEntity permission;
  const UpdatePermissionEvent(this.permission);
}

class DeletePermissionEvent extends PermissionEvent {
  final int id;
  const DeletePermissionEvent(this.id);
}
