import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:frontend/domain/usecase/my_reservation/ajukan_pembatalan_dp_usecase.dart';
import 'package:frontend/domain/usecase/my_reservation/get_my_reservations_usecase.dart';
import 'package:frontend/domain/usecase/reservation/cancel_reservation_usecase.dart';
import 'my_reservation_event.dart';
import 'my_reservation_state.dart';

class MyReservationBloc extends Bloc<MyReservationEvent, MyReservationState> {
  final GetMyReservationsUseCase getMyReservationsUseCase;
  final CancelReservationUseCase cancelReservationUseCase;
  final AjukanPembatalanDpUseCase ajukanPembatalanDpUseCase;

  MyReservationBloc({
    required this.getMyReservationsUseCase,
    required this.cancelReservationUseCase,
    required this.ajukanPembatalanDpUseCase,
  }) : super(const MyReservationState()) {
    on<GetMyReservationsEvent>(_onGetMyReservations);
    on<CancelMyReservationEvent>(_onCancelReservation);
    on<AjukanPembatalanDpEvent>(_onAjukanPembatalanDp);
  }

  Future<void> _onGetMyReservations(
    GetMyReservationsEvent event,
    Emitter<MyReservationState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    try {
      final reservations = await getMyReservationsUseCase();
      emit(state.copyWith(
        status: FormzSubmissionStatus.success,
        reservations: reservations,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onCancelReservation(
    CancelMyReservationEvent event,
    Emitter<MyReservationState> emit,
  ) async {
    emit(state.copyWith(cancelStatus: FormzSubmissionStatus.inProgress));
    try {
      await cancelReservationUseCase.execute(event.scheduleId);
      emit(state.copyWith(cancelStatus: FormzSubmissionStatus.success));
      add(GetMyReservationsEvent());
    } catch (e) {
      emit(state.copyWith(
        cancelStatus: FormzSubmissionStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onAjukanPembatalanDp(
    AjukanPembatalanDpEvent event,
    Emitter<MyReservationState> emit,
  ) async {
    emit(state.copyWith(pembatalanDpStatus: FormzSubmissionStatus.inProgress));
    try {
      await ajukanPembatalanDpUseCase.execute(
        scheduleId: event.scheduleId,
        bankName: event.bankName,
        accountNumber: event.accountNumber,
        accountHolderName: event.accountHolderName,
      );
      emit(state.copyWith(pembatalanDpStatus: FormzSubmissionStatus.success));
      add(GetMyReservationsEvent());
    } catch (e) {
      emit(state.copyWith(
        pembatalanDpStatus: FormzSubmissionStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}
