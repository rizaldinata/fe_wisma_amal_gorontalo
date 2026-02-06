import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:frontend/core/services/network/exception.dart';
import 'package:frontend/data/repository/permission_repository.dart';
import 'package:frontend/presentation/bloc/permission/permission_event.dart';
import 'package:frontend/presentation/bloc/permission/permission_state.dart';
import 'package:frontend/presentation/widget/core/snackbar/app_snackbar.dart';

class PermissionBloc extends Bloc<PermissionEvent, PermissionState> {
  final PermissionRepository repository;

  PermissionBloc(this.repository) : super(const PermissionState()) {
    on<GetPermissionsEvent>(_onGetPermissions);
    on<AddPermissionEvent>(_onAddPermission);
    on<UpdatePermissionEvent>(_onUpdatePermission);
    on<DeletePermissionEvent>(_onDeletePermission);
  }

  Future<void> _onGetPermissions(
    GetPermissionsEvent event,
    Emitter<PermissionState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    try {
      final result = await repository.getPermissions();
      emit(
        state.copyWith(
          status: FormzSubmissionStatus.success,
          permissions: result,
        ),
      );
    } on AppException catch (e) {
      AppSnackbar.showError('Gagal memuat izin: ${e.message}');
      emit(
        state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: e.message,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onAddPermission(
    AddPermissionEvent event,
    Emitter<PermissionState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    try {
      await repository.createPermission(event.permission);
      emit(
        state.copyWith(
          status: FormzSubmissionStatus.success,
          successMessage: "Berhasil menambah izin",
        ),
      );
      add(GetPermissionsEvent()); // Refresh data setelah tambah
    } on AppException catch (e) {
      AppSnackbar.showError('Gagal menambah izin: ${e.message}');
      emit(
        state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: e.message,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onUpdatePermission(
    UpdatePermissionEvent event,
    Emitter<PermissionState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    try {
      await repository.updatePermission(event.permission);
      emit(
        state.copyWith(
          status: FormzSubmissionStatus.success,
          successMessage: "Berhasil memperbarui izin",
        ),
      );
      add(GetPermissionsEvent()); // Refresh data setelah update
    } on AppException catch (e) {
      AppSnackbar.showError('Gagal memperbarui izin: ${e.message}');
      emit(
        state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: e.message,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onDeletePermission(
    DeletePermissionEvent event,
    Emitter<PermissionState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    try {
      final success = await repository.deletePermission(event.id);
      if (success) {
        emit(
          state.copyWith(
            status: FormzSubmissionStatus.success,
            successMessage: "Berhasil menghapus izin",
          ),
        );
        add(GetPermissionsEvent()); // Refresh data setelah hapus
      }
    } on AppException catch (e) {
      AppSnackbar.showError('Gagal menghapus izin: ${e.message}');
      emit(
        state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: e.message,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
