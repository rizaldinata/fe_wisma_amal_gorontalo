import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class InitLoginStatusEvent extends AuthEvent {
  const InitLoginStatusEvent();
}

class GetPermissionsEvent extends AuthEvent {
  const GetPermissionsEvent();
}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  const LoginEvent({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class RegisterEvent extends AuthEvent {
  final String username;
  final String email;
  final String password;
  final String passwordConfirm;

  const RegisterEvent({
    required this.username,
    required this.email,
    required this.password,
    required this.passwordConfirm,
  });

  @override
  List<Object?> get props => [username, email, password, passwordConfirm];
}

class LogoutEvent extends AuthEvent {
  const LogoutEvent();
}

class GetUserInfoEvent extends AuthEvent {
  const GetUserInfoEvent();
}

class ToggleObscureTextEvent extends AuthEvent {
  const ToggleObscureTextEvent();
}

class ResetStateEvent extends AuthEvent {
  const ResetStateEvent();
}

class CheckSessionEvent extends AuthEvent {
  const CheckSessionEvent();
}
