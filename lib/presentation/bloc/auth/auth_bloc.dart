import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:frontend/core/constant/storage_constant.dart';
import 'package:frontend/core/services/network/exception.dart';
import 'package:frontend/core/services/storage/shared_prefrence.dart';
import 'package:frontend/data/model/auth/auth_request_model.dart';
import 'package:frontend/data/repository/auth_repository.dart';
import 'package:frontend/domain/entity/user_entity.dart';
import 'package:frontend/presentation/bloc/auth/auth_event.dart';
import 'package:frontend/presentation/bloc/auth/auth_state.dart';
import 'package:frontend/presentation/widget/core/app_snackbar.dart';

class AuthStateNotifier extends ChangeNotifier {
  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;

  set isLoggedIn(bool value) {
    if (_isLoggedIn != value) {
      _isLoggedIn = value;
      notifyListeners();
    }
  }
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository auth;
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
    add(const InitLoginStatusEvent());
  }

  void _onInitLoginStatus(InitLoginStatusEvent event, Emitter<AuthState> emit) {
    final status = auth.isLoggedIn();
    loginStatusNotifier.isLoggedIn = status;
    emit(state.copyWith(isLoggedIn: status));

    if (status) {
      add(const GetUserInfoEvent());
    }
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(
      state.copyWith(
        status: FormzSubmissionStatus.inProgress,
        errorMessage: null,
      ),
    );

    try {
      final result = await auth.login(
        AuthRequestModel(email: event.email, password: event.password),
      );

      if (auth.isLoggedIn()) {
        emit(
          state.copyWith(
            isLoggedIn: true,
            userInfo: result,
            status: FormzSubmissionStatus.success,
            successMessage: 'Login berhasil!',
          ),
        );
      }

      // Tampilkan pesan sukses
      AppSnackbar.showSuccess('Login berhasil!');
    } on AppException catch (e) {
      emit(
        state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: e.message,
        ),
      );
    }
  }

  Future<void> _onRegister(RegisterEvent event, Emitter<AuthState> emit) async {
    emit(
      state.copyWith(
        status: FormzSubmissionStatus.inProgress,
        errorMessage: null,
      ),
    );

    try {
      final result = await auth.register(
        AuthRequestModel(
          email: event.email,
          password: event.password,
          username: event.username,
        ),
      );

      if (auth.isLoggedIn()) {
        emit(
          state.copyWith(
            isLoggedIn: true,
            userInfo: result,
            status: FormzSubmissionStatus.success,
            successMessage: 'Register berhasil!',
          ),
        );
      }
      AppSnackbar.showSuccess('Register berhasil!');
    } on AppException catch (e) {
      emit(
        state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: e.message,
        ),
      );
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    try {
      emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
      await auth.logout();
      emit(
        const AuthState(
          status: FormzSubmissionStatus.initial,
          isLoggedIn: false,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: FormzSubmissionStatus.failure));
    }
  }

  void _onGetUserInfo(GetUserInfoEvent event, Emitter<AuthState> emit) {
    final email = storage.get(StorageConstant.email);
    final username = storage.get(StorageConstant.userName);
    final userId = storage.getInt(StorageConstant.userId);
    final role = storage.getList(StorageConstant.roleActive);
    final permissions = storage.getPermissions()?.toList();

    final userInfo = UserEntity(
      email: email ?? '',
      name: username ?? '',
      id: userId ?? 0,
      roles: role ?? [],
      permissions: permissions,
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
