part of 'reservation_detail_form_bloc.dart';

abstract class ReservationDetailFormEvent extends Equatable {
  const ReservationDetailFormEvent();

  @override
  List<Object?> get props => [];
}

class InitReservationEvent extends ReservationDetailFormEvent {
  final RoomEntity room;

  const InitReservationEvent(this.room);

  @override
  List<Object?> get props => [room];
}

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

class DurationMonthsChanged extends ReservationDetailFormEvent {
  final int months;

  const DurationMonthsChanged(this.months);

  @override
  List<Object?> get props => [months];
}

class SubmitReservation extends ReservationDetailFormEvent {
  const SubmitReservation();
}

class PaymentMethodChanged extends ReservationDetailFormEvent {
  final String paymentMethod; // 'online' atau 'tunai'

  const PaymentMethodChanged(this.paymentMethod);

  @override
  List<Object?> get props => [paymentMethod];
}

class SelectedBankChanged extends ReservationDetailFormEvent {
  final String? selectedBank; // 'mandiri', 'bca', 'bri', atau null

  const SelectedBankChanged(this.selectedBank);

  @override
  List<Object?> get props => [selectedBank];
}