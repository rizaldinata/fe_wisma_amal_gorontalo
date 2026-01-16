import 'package:equatable/equatable.dart';
import 'package:frontend/data/model/auth/user_model.dart';
import 'package:frontend/domain/entity/user_entity.dart';
import 'package:formz/formz.dart';

class AuthState extends Equatable {
  final bool isLoggedIn;
  final UserEntity? userInfo;
  final bool obscureText;
  final FormzSubmissionStatus status;
  final String? errorMessage;

  const AuthState({
    this.isLoggedIn = false,
    this.userInfo,
    this.obscureText = true,
    this.status = FormzSubmissionStatus.initial,
    this.errorMessage,
  });

  AuthState copyWith({
    bool? isLoggedIn,
    UserEntity? userInfo,
    bool? obscureText,
    FormzSubmissionStatus? status,
    String? errorMessage,
    String? successMessage,
  }) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      userInfo: userInfo ?? this.userInfo,
      obscureText: obscureText ?? this.obscureText,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    isLoggedIn,
    userInfo,
    obscureText,
    status,
    errorMessage,
    
  ];
}
