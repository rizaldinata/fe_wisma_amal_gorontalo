import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/domain/entity/permission_entity.dart';
import 'package:frontend/domain/entity/role/role_entity.dart';
import 'package:frontend/domain/usecase/role/role_usecases.dart';

// Events
abstract class RoleEvent extends Equatable {
  const RoleEvent();
  @override
  List<Object?> get props => [];
}

class FetchRolesAndPermissions extends RoleEvent {}

class CreateRole extends RoleEvent {
  final String name;
  final String? description;
  final List<String> permissions;

  const CreateRole({
    required this.name,
    this.description,
    required this.permissions,
  });

  @override
  List<Object?> get props => [name, description, permissions];
}

class UpdateRole extends RoleEvent {
  final int id;
  final String name;
  final String? description;
  final List<String> permissions;

  const UpdateRole({
    required this.id,
    required this.name,
    this.description,
    required this.permissions,
  });

  @override
  List<Object?> get props => [id, name, description, permissions];
}

class DeleteRole extends RoleEvent {
  final int id;
  const DeleteRole(this.id);
  @override
  List<Object?> get props => [id];
}

// States
abstract class RoleState extends Equatable {
  const RoleState();
  @override
  List<Object?> get props => [];
}

class RoleInitial extends RoleState {}

class RoleLoading extends RoleState {}

class RoleLoaded extends RoleState {
  final List<RoleEntity> roles;
  final List<PermissionEntity> permissions;

  const RoleLoaded({
    required this.roles,
    required this.permissions,
  });

  @override
  List<Object?> get props => [roles, permissions];
}

class RoleError extends RoleState {
  final String message;
  const RoleError(this.message);
  @override
  List<Object?> get props => [message];
}

class RoleActionSuccess extends RoleState {
  final String message;
  const RoleActionSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

// Bloc
class RoleBloc extends Bloc<RoleEvent, RoleState> {
  final GetAllRolesUseCase getAllRolesUseCase;
  final GetAllPermissionsUseCase getAllPermissionsUseCase;
  final CreateRoleUseCase createRoleUseCase;
  final UpdateRoleUseCase updateRoleUseCase;
  final DeleteRoleUseCase deleteRoleUseCase;

  RoleBloc({
    required this.getAllRolesUseCase,
    required this.getAllPermissionsUseCase,
    required this.createRoleUseCase,
    required this.updateRoleUseCase,
    required this.deleteRoleUseCase,
  }) : super(RoleInitial()) {
    on<FetchRolesAndPermissions>((event, emit) async {
      emit(RoleLoading());
      try {
        final roles = await getAllRolesUseCase();
        final permissions = await getAllPermissionsUseCase();
        emit(RoleLoaded(roles: roles, permissions: permissions));
      } catch (e) {
        emit(RoleError(e.toString()));
      }
    });

    on<CreateRole>((event, emit) async {
      emit(RoleLoading());
      try {
        await createRoleUseCase(
          name: event.name,
          description: event.description,
          permissions: event.permissions,
        );
        emit(const RoleActionSuccess("Berhasil membuat peran baru"));
        add(FetchRolesAndPermissions());
      } catch (e) {
        emit(RoleError(e.toString()));
      }
    });

    on<UpdateRole>((event, emit) async {
      emit(RoleLoading());
      try {
        await updateRoleUseCase(
          id: event.id,
          name: event.name,
          description: event.description,
          permissions: event.permissions,
        );
        emit(const RoleActionSuccess("Berhasil memperbarui peran"));
        add(FetchRolesAndPermissions());
      } catch (e) {
        emit(RoleError(e.toString()));
      }
    });

    on<DeleteRole>((event, emit) async {
      emit(RoleLoading());
      try {
        await deleteRoleUseCase(event.id);
        emit(const RoleActionSuccess("Berhasil menghapus peran"));
        add(FetchRolesAndPermissions());
      } catch (e) {
        emit(RoleError(e.toString()));
      }
    });
  }
}
