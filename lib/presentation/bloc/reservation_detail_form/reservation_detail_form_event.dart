part of 'reservation_detail_form_bloc.dart';

abstract class ReservationDetailFormEvent extends Equatable {
  const ReservationDetailFormEvent();

  @override
  List<Object?> get props => [];
}

class InitReservationEvent extends ReservationDetailFormEvent {}

class RentTypeChanged extends ReservationDetailFormEvent {
  final String rentType;

  const RentTypeChanged(this.rentType);

  @override
  List<Object?> get props => [rentType];
}

class StartDateChanged extends ReservationDetailFormEvent {
  final DateTime date;

  const StartDateChanged(this.date);

  @override
  List<Object?> get props => [date];
}

class EndDateChanged extends ReservationDetailFormEvent {
  final DateTime date;

  const EndDateChanged(this.date);

  @override
  List<Object?> get props => [date];
}