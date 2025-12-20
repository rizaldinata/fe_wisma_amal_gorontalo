import 'package:equatable/equatable.dart';
import 'package:frontend/data/model/auth/user_model.dart';
import 'package:frontend/domain/entity/user_entity.dart';

class AuthState extends Equatable {
  final bool isLoggedIn;
  final UserEntity? userInfo;
  final bool obscureText;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  const AuthState({
    this.isLoggedIn = false,
    this.userInfo,
    this.obscureText = true,
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  AuthState copyWith({
    bool? isLoggedIn,
    UserEntity? userInfo,
    bool? obscureText,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
  }) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      userInfo: userInfo ?? this.userInfo,
      obscureText: obscureText ?? this.obscureText,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [
    isLoggedIn,
    userInfo,
    obscureText,
    isLoading,
    errorMessage,
    successMessage,
  ];
}
