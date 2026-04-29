import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:frontend/domain/usecase/reservation/get_reservations_usecase.dart';
import 'package:frontend/domain/usecase/usecase.dart';
import 'package:frontend/presentation/bloc/reservation_list/reservation_event.dart';
import 'package:frontend/presentation/bloc/reservation_list/reservation_state.dart';
import 'package:frontend/presentation/widget/core/snackbar/app_snackbar.dart';

class ReservationBloc extends Bloc<ReservationEvent, ReservationState> {
  final GetReservationsUseCase getReservationsUseCase;

  ReservationBloc({
    required this.getReservationsUseCase,
  }) : super(const ReservationState()) {
    on<GetReservationsEvent>(_onGetReservations);
  }

  Future<void> _onGetReservations(
    GetReservationsEvent event,
    Emitter<ReservationState> emit,
  ) async {
    emit(
      state.copyWith(
        status: FormzSubmissionStatus.inProgress,
      ),
    );

    try {
      final reservations =
          await getReservationsUseCase(NoParams());

      emit(
        state.copyWith(
          status: FormzSubmissionStatus.success,
          reservations: reservations,
        ),
      );
    } catch (e) {
      AppSnackbar.showError(
        'Gagal memuat data reservasi: ${e.toString()}',
      );

      emit(
        state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}