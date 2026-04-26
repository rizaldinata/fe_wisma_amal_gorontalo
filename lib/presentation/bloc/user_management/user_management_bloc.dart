import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/domain/entity/user/user_entity.dart';
import 'package:frontend/domain/usecase/user/get_all_users_usecase.dart';
import 'package:frontend/domain/usecase/user/update_user_usecase.dart';
import 'package:frontend/domain/usecase/user/delete_user_usecase.dart';
import 'package:frontend/domain/usecase/user/create_user_usecase.dart';

// Events
abstract class UserManagementEvent extends Equatable {
  const UserManagementEvent();
  @override
  List<Object?> get props => [];
}

class FetchUsers extends UserManagementEvent {}

class CreateUser extends UserManagementEvent {
  final String name;
  final String email;
  final String password;
  final String role;
  final String? phoneNumber;

  const CreateUser({
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    this.phoneNumber,
  });

  @override
  List<Object?> get props => [name, email, password, role, phoneNumber];
}

class UpdateUserDetails extends UserManagementEvent {
  final int id;
  final String? name;
  final String? email;
  final String? role;

  const UpdateUserDetails({
    required this.id,
    this.name,
    this.email,
    this.role,
  });

  @override
  List<Object?> get props => [id, name, email, role];
}

class UpdateUserRole extends UserManagementEvent {
  final int id;
  final String role;
  const UpdateUserRole(this.id, this.role);
  @override
  List<Object?> get props => [id, role];
}

class DeleteUser extends UserManagementEvent {
  final int id;
  const DeleteUser(this.id);
  @override
  List<Object?> get props => [id];
}

// States
abstract class UserManagementState extends Equatable {
  const UserManagementState();
  @override
  List<Object?> get props => [];
}

class UserManagementInitial extends UserManagementState {}
class UserManagementLoading extends UserManagementState {}
class UserManagementLoaded extends UserManagementState {
  final List<UserEntity> users;
  const UserManagementLoaded(this.users);
  @override
  List<Object?> get props => [users];
}
class UserManagementError extends UserManagementState {
  final String message;
  const UserManagementError(this.message);
  @override
  List<Object?> get props => [message];
}
class UserManagementActionSuccess extends UserManagementState {
  final String message;
  const UserManagementActionSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

// Bloc
class UserManagementBloc extends Bloc<UserManagementEvent, UserManagementState> {
  final GetAllUsersUseCase getAllUsersUseCase;
  final UpdateUserUseCase updateUserUseCase;
  final DeleteUserUseCase deleteUserUseCase;
  final CreateUserUseCase createUserUseCase;

  UserManagementBloc({
    required this.getAllUsersUseCase,
    required this.updateUserUseCase,
    required this.deleteUserUseCase,
    required this.createUserUseCase,
  }) : super(UserManagementInitial()) {
    on<FetchUsers>((event, emit) async {
      emit(UserManagementLoading());
      try {
        final users = await getAllUsersUseCase();
        emit(UserManagementLoaded(users));
      } catch (e) {
        emit(UserManagementError(e.toString()));
      }
    });

    on<CreateUser>((event, emit) async {
      emit(UserManagementLoading());
      try {
        await createUserUseCase(
          name: event.name,
          email: event.email,
          password: event.password,
          role: event.role,
          phoneNumber: event.phoneNumber,
        );
        emit(const UserManagementActionSuccess("Berhasil menambah pengguna baru"));
        add(FetchUsers());
      } catch (e) {
        emit(UserManagementError(e.toString()));
      }
    });

    on<UpdateUserDetails>((event, emit) async {
      emit(UserManagementLoading());
      try {
        await updateUserUseCase(
          event.id,
          name: event.name,
          email: event.email,
          role: event.role,
        );
        emit(const UserManagementActionSuccess("Berhasil memperbarui data pengguna"));
        add(FetchUsers());
      } catch (e) {
        emit(UserManagementError(e.toString()));
      }
    });

    on<UpdateUserRole>((event, emit) async {
      emit(UserManagementLoading());
      try {
        await updateUserUseCase(event.id, role: event.role);
        emit(const UserManagementActionSuccess("Berhasil mengubah role pengguna"));
        add(FetchUsers());
      } catch (e) {
        emit(UserManagementError(e.toString()));
      }
    });

    on<DeleteUser>((event, emit) async {
      emit(UserManagementLoading());
      try {
        await deleteUserUseCase(event.id);
        emit(const UserManagementActionSuccess("Berhasil menghapus pengguna"));
        add(FetchUsers());
      } catch (e) {
        emit(UserManagementError(e.toString()));
      }
    });
  }
}
