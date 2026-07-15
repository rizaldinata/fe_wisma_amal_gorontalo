part of 'identity_form_bloc.dart';

sealed class IdentityFormEvent extends Equatable {
  const IdentityFormEvent();

  @override
  List<Object?> get props => [];
}

final class LoadIdentityFormEvent extends IdentityFormEvent {
  const LoadIdentityFormEvent();
}

final class PickProfileImageEvent extends IdentityFormEvent {}

final class SubmitIdentityFormEvent extends IdentityFormEvent {
  const SubmitIdentityFormEvent({
    required this.name,
    required this.email,
    required this.phone,
    required this.gender,
    required this.status,
  });

  final String name;
  final String email;
  final String phone;
  final String gender;
  final String status;

  @override
  List<Object> get props => [name, email, phone, gender, status];
}