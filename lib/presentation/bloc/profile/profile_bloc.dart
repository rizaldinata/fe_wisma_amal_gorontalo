import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/domain/entity/user/user_entity.dart';
import 'package:frontend/domain/usecase/profile/profile_usecases.dart';

// Events
abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
  @override
  List<Object?> get props => [];
}

class FetchProfile extends ProfileEvent {}

class UpdateProfile extends ProfileEvent {
  final String name;
  final String email;
  final String? phoneNumber;
  const UpdateProfile({required this.name, required this.email, this.phoneNumber});
  @override
  List<Object?> get props => [name, email, phoneNumber];
}

class ChangePassword extends ProfileEvent {
  final String oldPassword;
  final String newPassword;
  final String confirmPassword;
  const ChangePassword({
    required this.oldPassword,
    required this.newPassword,
    required this.confirmPassword,
  });
  @override
  List<Object?> get props => [oldPassword, newPassword, confirmPassword];
}

// States
abstract class ProfileState extends Equatable {
  const ProfileState();
  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}
class ProfileLoading extends ProfileState {}
class ProfileLoaded extends ProfileState {
  final UserEntity user;
  const ProfileLoaded(this.user);
  @override
  List<Object?> get props => [user];
}
class ProfileError extends ProfileState {
  final String message;
  const ProfileError(this.message);
  @override
  List<Object?> get props => [message];
}
class ProfileActionSuccess extends ProfileState {
  final String message;
  const ProfileActionSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

// Bloc
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfileUseCase getProfileUseCase;
  final UpdateProfileUseCase updateProfileUseCase;
  final ChangePasswordUseCase changePasswordUseCase;

  ProfileBloc({
    required this.getProfileUseCase,
    required this.updateProfileUseCase,
    required this.changePasswordUseCase,
  }) : super(ProfileInitial()) {
    on<FetchProfile>((event, emit) async {
      emit(ProfileLoading());
      try {
        final user = await getProfileUseCase();
        emit(ProfileLoaded(user));
      } catch (e) {
        emit(ProfileError(e.toString()));
      }
    });

    on<UpdateProfile>((event, emit) async {
      emit(ProfileLoading());
      try {
        final user = await updateProfileUseCase(
          name: event.name,
          email: event.email,
          phoneNumber: event.phoneNumber,
        );
        emit(ProfileLoaded(user));
        emit(const ProfileActionSuccess("Profil berhasil diperbarui"));
      } catch (e) {
        emit(ProfileError(e.toString()));
      }
    });

    on<ChangePassword>((event, emit) async {
      emit(ProfileLoading());
      try {
        await changePasswordUseCase(
          oldPassword: event.oldPassword,
          newPassword: event.newPassword,
          confirmPassword: event.confirmPassword,
        );
        emit(const ProfileActionSuccess("Password berhasil diubah"));
        add(FetchProfile());
      } catch (e) {
        emit(ProfileError(e.toString()));
      }
    });
  }
}
