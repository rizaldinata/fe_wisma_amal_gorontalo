import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:frontend/presentation/bloc/reservation_list/reservation_event.dart';
import 'package:frontend/presentation/bloc/reservation_list/reservation_state.dart';
import 'package:frontend/presentation/widget/core/snackbar/app_snackbar.dart';

class ReservationBloc extends Bloc<ReservationEvent, ReservationState> {
  ReservationBloc() : super(const ReservationState()) {
    on<GetReservationsEvent>(_onGetReservations);
  }

  Future<void> _onGetReservations(
    GetReservationsEvent event,
    Emitter<ReservationState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final dummyData = <Map<String, dynamic>>[
        {
          'guestName': 'Budi Santoso',
          'roomTitle': 'Kamar Deluxe A',
          'checkIn': '2025-01-01',
          'checkOut': '2025-02-01',
          'status': 'Aktif',
        },
        {
          'guestName': 'Siti Rahayu',
          'roomTitle': 'Kamar Standard B',
          'checkIn': '2025-01-15',
          'checkOut': '2025-03-15',
          'status': 'Pending',
        },
        {
          'guestName': 'Ahmad Fauzi',
          'roomTitle': 'Kamar VIP C',
          'checkIn': '2025-02-01',
          'checkOut': '2025-04-01',
          'status': 'Aktif',
        },
        {
          'guestName': 'Dewi Kusuma',
          'roomTitle': 'Kamar Standard D',
          'checkIn': '2024-10-01',
          'checkOut': '2024-12-01',
          'status': 'Selesai',
        },
      ];

      emit(state.copyWith(
        status: FormzSubmissionStatus.success,
        reservations: dummyData,
      ));
    } catch (e) {
      AppSnackbar.showError('Gagal memuat data reservasi: ${e.toString()}');
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}