import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import '../../../domain/usecase/setting/get_settings_usecase.dart';
import '../../../domain/usecase/setting/update_settings_usecase.dart';
import 'setting_event.dart';
import 'setting_state.dart';

class SettingBloc extends Bloc<SettingEvent, SettingState> {
  final GetSettingsUseCase getSettingsUseCase;
  final UpdateBulkSettingsUseCase updateBulkSettingsUseCase;

  SettingBloc({
    required this.getSettingsUseCase,
    required this.updateBulkSettingsUseCase,
  }) : super(SettingInitial()) {
    on<FetchSettingsEvent>(_onFetchSettings);
    on<UpdateSettingsEvent>(_onUpdateSettings);
  }

  Future<void> _onFetchSettings(FetchSettingsEvent event, Emitter<SettingState> emit) async {
    emit(SettingLoading());
    try {
      final settings = await getSettingsUseCase.execute();
      emit(SettingLoaded(settings));
    } catch (e) {
      if (e is DioException) {
        emit(SettingError(e.response?.data['message'] ?? e.message));
      } else {
        emit(SettingError('Terjadi kesalahan yang tidak terduga: ${e.toString()}'));
      }
    }
  }

  Future<void> _onUpdateSettings(UpdateSettingsEvent event, Emitter<SettingState> emit) async {
    emit(SettingLoading());
    try {
      final updated = await updateBulkSettingsUseCase.execute(event.updatedSettings);
      emit(SettingUpdateSuccess(updated));
    } catch (e) {
      if (e is DioException) {
        emit(SettingError(e.response?.data['message'] ?? e.message));
      } else {
        emit(SettingError('Gagal memperbarui pengaturan: ${e.toString()}'));
      }
    }
  }
}
