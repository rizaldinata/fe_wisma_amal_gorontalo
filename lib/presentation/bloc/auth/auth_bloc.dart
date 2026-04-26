import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:frontend/core/constant/storage_constant.dart';
import 'package:frontend/core/services/network/exception.dart';
import 'package:frontend/core/services/storage/shared_prefrence.dart';
import 'package:frontend/data/model/auth/auth_request_model.dart';
import 'package:frontend/domain/usecase/auth/check_session_usecase.dart';
import 'package:frontend/domain/usecase/auth/get_permissions_usecase.dart';
import 'package:frontend/domain/usecase/auth/is_logged_in_usecase.dart';
import 'package:frontend/domain/usecase/auth/login_usecase.dart';
import 'package:frontend/domain/usecase/auth/logout_usecase.dart';
import 'package:frontend/domain/usecase/auth/register_usecase.dart';
import 'package:frontend/domain/usecase/usecase.dart';
import 'package:frontend/domain/entity/permission_entity.dart';
import 'package:frontend/domain/entity/user_entity.dart';
import 'package:frontend/presentation/bloc/auth/auth_event.dart';
import 'package:frontend/presentation/bloc/auth/auth_state.dart';
import 'package:frontend/presentation/widget/core/snackbar/app_snackbar.dart';

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
  final CheckSessionUseCase checkSessionUseCase;
  final GetPermissionsUseCase getPermissionsUseCase;
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final IsLoggedInUseCase isLoggedInUseCase;
  final SharedPrefsStorage storage;
  final AuthStateNotifier loginStatusNotifier = AuthStateNotifier();
  Timer? _sessionTimer;

  AuthBloc({
    required this.checkSessionUseCase,
    required this.getPermissionsUseCase,
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.isLoggedInUseCase,
    required this.storage,
  }) : super(const AuthState()) {
    on<InitLoginStatusEvent>(_onInitLoginStatus);
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<LogoutEvent>(_onLogout);
    on<GetUserInfoEvent>(_onGetUserInfo);
    on<GetPermissionsEvent>(_onGetPermissions);
    on<ToggleObscureTextEvent>(_onToggleObscureText);
    on<SessionExpiredEvent>(_onSessionExpired);
    on<ResetStateEvent>((event, emit) {
      emit(const AuthState());
    });
    add(const InitLoginStatusEvent());
    on<CheckSessionEvent>((event, emit) async {
      _sessionTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
        print('Checking session validity...');
        _checkSession();
      });
    });
  }

  Future<void> _onGetPermissions(
    GetPermissionsEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      // Ambil ulang permissions dari server dan simpan ke SharedPreferences
      await getPermissionsUseCase(NoParams());

      // Setelah tersimpan di storage, sinkronkan kembali ke state.userInfo
      final currentUser = state.userInfo;
      if (currentUser != null) {
        final permissions = Permissions(
          storage.getPermissions()?.toSet() ?? {},
        );
        final updatedUser = currentUser.copyWith(permissions: permissions);
        emit(state.copyWith(userInfo: updatedUser));
      }
    } on AppException catch (e) {
      debugPrint('Error fetching permissions: ${e.message}');
      AppSnackbar.showError('Gagal mendapatkan izin: ${e.message}');
    } catch (e) {
      debugPrint('Unexpected error fetching permissions: $e');
      AppSnackbar.showError(
        'Terjadi kesalahan tak terduga saat mendapatkan izin.',
      );
    }
  }

  Future<void> _checkSession() async {
    try {
      final isValid = await checkSessionUseCase(NoParams());
      if (!isValid) {
        add(const LogoutEvent());
        AppSnackbar.showError('Sesi telah berakhir. Silakan login kembali.');
      }
    } on AppException catch (e) {
      print('Error checking session: ${e.message}');
      AppSnackbar.showError('Gagal memeriksa sesi: ${e.message}');
    } catch (e) {
      print('Unexpected error checking session: $e');
      AppSnackbar.showError(
        'Terjadi kesalahan tak terduga saat memeriksa sesi.',
      );
    }
  }

  void _onInitLoginStatus(
    InitLoginStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    print('Initializing login status...');
    final status = await isLoggedInUseCase(NoParams());

    // Endpoint permission bisa diakses tanpa atau dengan token,
    // jadi aman untuk selalu refresh di awal.
    try {
      await getPermissionsUseCase(NoParams());
    } catch (e) {
      debugPrint('Failed to refresh permissions on init: $e');
    }

    loginStatusNotifier.isLoggedIn = status;
    print('Login status initialized: $status');

    if (status) {
      final email = storage.get(StorageConstant.email);
      final username = storage.get(StorageConstant.userName);
      final userId = storage.getInt(StorageConstant.userId);
      final role = storage.getList(StorageConstant.roleActive);
      final permissions = Permissions(storage.getPermissions()?.toSet() ?? {});

      final userInfo = UserEntity(
        email: email ?? '',
        name: username ?? '',
        id: userId ?? 0,
        roles: role ?? [],
        permissions: permissions,
      );
      emit(state.copyWith(isLoggedIn: status, userInfo: userInfo));
    } else {
      final permissions = Permissions(storage.getPermissions()?.toSet() ?? {});
      final guestUser = UserEntity(
        id: null,
        name: 'Guest',
        email: '',
        roles: const [],
        permissions: permissions,
      );
      emit(state.copyWith(isLoggedIn: status, userInfo: guestUser));
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
      final result = await loginUseCase(
        AuthRequestModel(email: event.email, password: event.password),
      );

      final isLoggedIn = await isLoggedInUseCase(NoParams());

      if (isLoggedIn) {
        add(const GetUserInfoEvent());
        emit(
          state.copyWith(
            isLoggedIn: true,
            userInfo: result,
            status: FormzSubmissionStatus.success,
            successMessage: 'Login berhasil!',
          ),
        );
      }
      AppSnackbar.showSuccess('Login berhasil!');
    } on AppException catch (e) {
      emit(
        state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: e.message,
        ),
      );
      AppSnackbar.showError('Gagal login: ${e.message}');
    } catch (e) {
      emit(
        state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: e.toString(),
        ),
      );
      AppSnackbar.showError('Gagal login: ${e.toString()}');
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
      final result = await registerUseCase(
        AuthRequestModel(
          email: event.email,
          password: event.password,
          username: event.username,
          passwordConfirmation: event.passwordConfirm,
          phoneNumber: event.phoneNumber,
        ),
      );

      final isLoggedIn = await isLoggedInUseCase(NoParams());

      if (isLoggedIn) {
        add(const GetUserInfoEvent());
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
      AppSnackbar.showError('Gagal register: ${e.message}');
      emit(
        state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: e.message,
        ),
      );
    } catch (e) {
      AppSnackbar.showError('Gagal register: ${e.toString()}');
      emit(
        state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    try {
      emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
      await logoutUseCase(NoParams());
      emit(
        const AuthState(
          status: FormzSubmissionStatus.initial,
          isLoggedIn: false,
        ),
      );
    } on AppException catch (e) {
      AppSnackbar.showError('Gagal logout: ${e.message}');
      emit(
        state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: e.message,
          isLoggedIn: false,
        ),
      );
    } catch (e) {
      AppSnackbar.showError('Gagal logout: ${e.toString()}');
      emit(
        state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: e.toString(),
          isLoggedIn: false,
        ),
      );
    }
  }

  Future<void> _onSessionExpired(
    SessionExpiredEvent event,
    Emitter<AuthState> emit,
  ) async {
    print('Handling Session Expired Event...');
    try {
      // 1. Clear local storage & token directly to be sure
      await storage.clear();
      // insecure but since secureStorage is internal to repository, we use repository via logoutUseCase or similar
      // Actually, better to use the repository functionality if possible
      // but logoutUseCase might call the API.
      // Let's just reset the state and let the session initialization handle it.
      
      // Emit guest state
      emit(
        const AuthState(
          status: FormzSubmissionStatus.initial,
          isLoggedIn: false,
        ),
      );
      
      loginStatusNotifier.isLoggedIn = false;
      
      // Update permissions as guest
      await getPermissionsUseCase(NoParams());
      
      AppSnackbar.showError('Sesi sudah habis. Silakan login kembali.');
    } catch (e) {
      print('Error during session expiration handling: $e');
    }
  }

  void _onGetUserInfo(GetUserInfoEvent event, Emitter<AuthState> emit) {
    try {
      final email = storage.get(StorageConstant.email);
      final username = storage.get(StorageConstant.userName);
      final userId = storage.getInt(StorageConstant.userId);
      final role = storage.getList(StorageConstant.roleActive);
      final permissions = Permissions(storage.getPermissions()?.toSet() ?? {});

      final userInfo = UserEntity(
        email: email ?? '',
        name: username ?? '',
        id: userId ?? 0,
        roles: role ?? [],
        permissions: permissions,
      );

      emit(state.copyWith(userInfo: userInfo));
    } on AppException catch (e) {
      AppSnackbar.showError(
        'gagal mendapatkan informasi pengguna: ${e.message}',
      );
      emit(
        state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: e.message,
          isLoggedIn: false,
        ),
      );
    } catch (e) {
      AppSnackbar.showError(
        'gagal mendapatkan informasi pengguna: ${e.toString()}',
      );
      emit(
        state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: e.toString(),
          isLoggedIn: false,
        ),
      );
    }
  }

  void _onToggleObscureText(
    ToggleObscureTextEvent event,
    Emitter<AuthState> emit,
  ) {
    emit(state.copyWith(obscureText: !state.obscureText));
  }

  @override
  Future<void> close() {
    _sessionTimer?.cancel();
    loginStatusNotifier.dispose();
    return super.close();
  }
}
