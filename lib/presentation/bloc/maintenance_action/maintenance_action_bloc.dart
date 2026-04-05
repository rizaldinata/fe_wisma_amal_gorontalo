import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/network/exception.dart';
import '../../../../domain/usecase/maintenance/create_request_usecase.dart';
import '../../../../domain/usecase/maintenance/add_update_usecase.dart';
import 'maintenance_action_event.dart';
import 'maintenance_action_state.dart';

class MaintenanceActionBloc extends Bloc<MaintenanceActionEvent, MaintenanceActionState> {
  final CreateRequestUseCase createRequestUseCase;
  final AddUpdateUseCase addUpdateUseCase;

  MaintenanceActionBloc({
    required this.createRequestUseCase,
    required this.addUpdateUseCase,
  }) : super(MaintenanceActionInitial()) {
    on<SubmitMaintenanceRequest>(_onSubmitRequest);
    on<SubmitMaintenanceUpdate>(_onSubmitUpdate);
  }

  Future<void> _onSubmitRequest(
    SubmitMaintenanceRequest event,
    Emitter<MaintenanceActionState> emit,
  ) async {
    emit(MaintenanceActionSubmitting());
    try {
      await createRequestUseCase(
        CreateRequestParams(
          title: event.title,
          description: event.description,
          roomId: event.roomId,
          imagePaths: event.imagePaths,
        ),
      );
      emit(const MaintenanceActionSuccess('Laporan berhasil dibuat.'));
    } on AppException catch (e) {
      emit(MaintenanceActionFailure(e.message));
    } catch (e) {
      emit(MaintenanceActionFailure(e.toString()));
    }
  }

  Future<void> _onSubmitUpdate(
    SubmitMaintenanceUpdate event,
    Emitter<MaintenanceActionState> emit,
  ) async {
    emit(MaintenanceActionSubmitting());
    try {
      await addUpdateUseCase(
        AddUpdateParams(
          requestId: event.requestId,
          description: event.description,
          status: event.status,
          imagePaths: event.imagePaths,
        ),
      );
      emit(const MaintenanceActionSuccess('Update progres berhasil.'));
    } on AppException catch (e) {
      emit(MaintenanceActionFailure(e.message));
    } catch (e) {
      emit(MaintenanceActionFailure(e.toString()));
    }
  }
}
