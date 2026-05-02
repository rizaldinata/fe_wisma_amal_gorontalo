import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:formz/formz.dart';

import 'package:frontend/domain/usecase/reservation/get_reservations_usecase.dart';

import 'package:frontend/domain/usecase/reservation/update_reservation_status_usecase.dart';

import 'package:frontend/domain/usecase/usecase.dart';

import 'package:frontend/presentation/bloc/reservation_list/reservation_event.dart';

import 'package:frontend/presentation/bloc/reservation_list/reservation_state.dart';

import 'package:frontend/presentation/widget/core/snackbar/app_snackbar.dart';

class ReservationBloc extends Bloc<ReservationEvent, ReservationState> {
  final GetReservationsUseCase getReservationsUseCase;

  final UpdateReservationStatusUseCase updateReservationStatusUseCase;

  ReservationBloc({
    required this.getReservationsUseCase,

    required this.updateReservationStatusUseCase,
  }) : super(const ReservationState()) {
    on<GetReservationsEvent>(_onGetReservations);

    on<SearchReservationEvent>(_onSearchReservation);

    on<FilterReservationDateEvent>(_onFilterReservationDate);

    on<SortReservationEvent>(_onSortReservation);

    on<UpdateReservationStatusEvent>(_onUpdateReservationStatus);
  }

  Future<void> _onGetReservations(
    GetReservationsEvent event,
    Emitter<ReservationState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));

    try {
      final reservations = await getReservationsUseCase(NoParams());

      emit(
        state.copyWith(
          status: FormzSubmissionStatus.success,

          reservations: reservations,
        ),
      );
    } catch (e) {
      AppSnackbar.showError('Gagal memuat data reservasi: ${e.toString()}');

      emit(
        state.copyWith(
          status: FormzSubmissionStatus.failure,

          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _onSearchReservation(
    SearchReservationEvent event,
    Emitter<ReservationState> emit,
  ) {
    emit(state.copyWith(searchQuery: event.query));
  }

  void _onFilterReservationDate(
    FilterReservationDateEvent event,
    Emitter<ReservationState> emit,
  ) {
    emit(
      state.copyWith(
        startDateFilter: event.startDate,

        endDateFilter: event.endDate,
      ),
    );
  }

  void _onSortReservation(
    SortReservationEvent event,
    Emitter<ReservationState> emit,
  ) {
    emit(state.copyWith(sortBy: event.sortBy));
  }

  Future<void> _onUpdateReservationStatus(
    UpdateReservationStatusEvent event,

    Emitter<ReservationState> emit,
  ) async {
    try {
      await updateReservationStatusUseCase(
        reservationId: event.reservationId,

        status: event.status,
      );

      AppSnackbar.showSuccess('Status reservasi berhasil diperbarui');

      add(GetReservationsEvent());
    } catch (e) {
      AppSnackbar.showError('Gagal update status reservasi');
    }
  }
}
