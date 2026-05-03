import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:formz/formz.dart';

import 'package:frontend/domain/usecase/my_reservation/get_my_reservations_usecase.dart';

import 'my_reservation_event.dart';

import 'my_reservation_state.dart';

class MyReservationBloc
    extends Bloc<
        MyReservationEvent,
        MyReservationState> {
  final GetMyReservationsUseCase
      getMyReservationsUseCase;

  MyReservationBloc({
    required this.getMyReservationsUseCase,
  }) : super(const MyReservationState()) {
    on<GetMyReservationsEvent>(
      _onGetMyReservations,
    );
  }

  Future<void> _onGetMyReservations(
    GetMyReservationsEvent event,

    Emitter<MyReservationState> emit,
  ) async {
    emit(
      state.copyWith(
        status:
            FormzSubmissionStatus.inProgress,
      ),
    );

    try {
      final reservations =
          await getMyReservationsUseCase();

      emit(
        state.copyWith(
          status:
              FormzSubmissionStatus.success,

          reservations: reservations,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status:
              FormzSubmissionStatus.failure,

          errorMessage: e.toString(),
        ),
      );
    }
  }
}