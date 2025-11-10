import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/constant/storage_constant.dart';
import 'package:frontend/core/services/network/exception.dart';
import 'package:frontend/core/services/storage/shared_prefrence.dart';
import 'package:frontend/data/datasource/auth_datasource.dart';
import 'package:frontend/data/model/auth/auth_error_model.dart';
import 'package:frontend/data/model/auth/login_request.dart';
import 'package:frontend/data/model/auth/register_request.dart';
import 'package:frontend/data/model/auth/user_model.dart';
import 'package:frontend/presentation/bloc/auth/auth_event.dart';
import 'package:frontend/presentation/bloc/auth/auth_state.dart';
import 'package:frontend/presentation/widget/app_snackbar.dart';

import '../../../main.dart';

class AuthStateNotifier extends ChangeNotifier {
  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;

  set isLoggedIn(bool value) {
    if (_isLoggedIn != value) {
      _isLoggedIn = value;
      notifyListeners(); // Trigger router refresh
    }
  }
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthDatasource auth;
  final SharedPrefsStorage storage;
  final AuthStateNotifier loginStatusNotifier = AuthStateNotifier();

  AuthBloc({required this.auth, required this.storage})
    : super(const AuthState()) {
    on<InitLoginStatusEvent>(_onInitLoginStatus);
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<LogoutEvent>(_onLogout);
    on<GetUserInfoEvent>(_onGetUserInfo);
    on<ToggleObscureTextEvent>(_onToggleObscureText);
    on<ResetStateEvent>((event, emit) {
      emit(const AuthState());
    });

    // Initialize login status saat bloc dibuat
    add(const InitLoginStatusEvent());
  }

  Future<void> _onInitLoginStatus(
    InitLoginStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    final status = await auth.isLoggedIn();
    loginStatusNotifier.isLoggedIn = status;
    emit(state.copyWith(isLoggedIn: status));

    if (status) {
      add(const GetUserInfoEvent());
    }
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      final result = await auth.login(
        LoginRequestModel(email: event.email, password: event.password),
      );

      if (result == null) {
        emit(state.copyWith(isLoading: false, errorMessage: 'Login gagal'));
        return;
      }

      loginStatusNotifier.isLoggedIn = true;
      emit(
        state.copyWith(
          isLoggedIn: true,
          userInfo: result,
          isLoading: false,
          successMessage: 'Login berhasil!',
        ),
      );

      // Tampilkan pesan sukses
      AppSnackbar.showSuccess('Login berhasil!');
    } on AppException catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.message));
      AppSnackbar.showError(e.message);
    }
  }

  Future<void> _onRegister(RegisterEvent event, Emitter<AuthState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      final result = await auth.register(
        RegisterRequestModel(
          name: event.username,
          email: event.email,
          password: event.password,
          passwordConfirmation: event.passwordConfirm,
        ),
      );

      if (result == null) {
        emit(state.copyWith(isLoading: false, errorMessage: 'Register gagal'));
        return;
      }

      // loginStatusNotifier.isLoggedIn = true;
      emit(
        state.copyWith(
          // isLoggedIn: true,
          userInfo: result,
          isLoading: false,
          successMessage: 'Register berhasil!',
        ),
      );

      AppSnackbar.showSuccess('Register berhasil!');
    } on AppException catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.message));
      AppSnackbar.showError(e.message);
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    try {
      await auth.logout();
      emit(const AuthState()); // Reset to initial state
      loginStatusNotifier.isLoggedIn =
          false; // Update notifier setelah emit - trigger router refresh
    } catch (e) {
      emit(const AuthState()); // Reset to initial state even on error
      loginStatusNotifier.isLoggedIn =
          false; // Update notifier setelah emit - trigger router refresh
    }
  }

  void _onGetUserInfo(GetUserInfoEvent event, Emitter<AuthState> emit) {
    final email = storage.get(StorageConstant.email);
    final username = storage.get(StorageConstant.userName);
    final userId = storage.getInt(StorageConstant.userId);
    final role = storage.getList(StorageConstant.roleActive);
    final permissions = storage.getPermissions();

    final userInfo = UserModel(
      email: email ?? '',
      name: username ?? '',
      roles: role ?? [],
      id: (userId != null) ? userId : null,
      permissions: permissions ?? {},
    );

    emit(state.copyWith(userInfo: userInfo));
  }

  void _onToggleObscureText(
    ToggleObscureTextEvent event,
    Emitter<AuthState> emit,
  ) {
    emit(state.copyWith(obscureText: !state.obscureText));
  }

  @override
  Future<void> close() {
    loginStatusNotifier.dispose();
    return super.close();
  }
}
