import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'reservation_detail_form_event.dart';
part 'reservation_detail_form_state.dart';

class ReservationDetailFormBloc extends Bloc<
    ReservationDetailFormEvent,
    ReservationDetailFormState> {
  ReservationDetailFormBloc()
      : super(const ReservationDetailFormState()) {
    on<InitReservationEvent>(_onInit);
    on<RentTypeChanged>(_onRentTypeChanged);
    on<StartDateChanged>(_onStartDateChanged);
    on<EndDateChanged>(_onEndDateChanged);
  }

  void _onInit(
    InitReservationEvent event,
    Emitter<ReservationDetailFormState> emit,
  ) {
    emit(state);
  }

  void _onRentTypeChanged(
    RentTypeChanged event,
    Emitter<ReservationDetailFormState> emit,
  ) {
    int price;

    switch (event.rentType) {
      case 'Bulanan':
        price = 1500000;
        break;
      case 'Tahunan':
        price = 18000000;
        break;
      default:
        price = 150000;
    }

    emit(state.copyWith(
      rentType: event.rentType,
      pricePerDay: price,
    ));

    _calculate(emit);
  }

  void _onStartDateChanged(
    StartDateChanged event,
    Emitter<ReservationDetailFormState> emit,
  ) {
    emit(state.copyWith(startDate: event.date));
    _calculate(emit);
  }

  void _onEndDateChanged(
    EndDateChanged event,
    Emitter<ReservationDetailFormState> emit,
  ) {
    emit(state.copyWith(endDate: event.date));
    _calculate(emit);
  }

  void _calculate(Emitter<ReservationDetailFormState> emit) {
    final start = state.startDate;
    final end = state.endDate;

    if (start != null && end != null) {
      final duration = end.difference(start).inDays;

      if (duration > 0) {
        final total = duration * state.pricePerDay;

        emit(state.copyWith(
          duration: duration,
          totalPrice: total, 
        ));
      }
    }
  }
}