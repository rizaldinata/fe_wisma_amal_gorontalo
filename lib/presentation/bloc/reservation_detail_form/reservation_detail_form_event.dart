part of 'reservation_detail_form_bloc.dart';

abstract class ReservationDetailFormEvent extends Equatable {
  const ReservationDetailFormEvent();

  @override
  List<Object?> get props => [];
}

class InitReservationEvent extends ReservationDetailFormEvent {
  final RoomEntity room;
  final bool isLoggedIn;
  final int? userId;
  final String? userName;

  const InitReservationEvent(this.room, {this.isLoggedIn = false, this.userId, this.userName});

  @override
  List<Object?> get props => [room, isLoggedIn, userId, userName];
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

class SelectedMidtransMethodChanged extends ReservationDetailFormEvent {
  final String? method; // kode metode Midtrans, e.g. 'qris', 'gopay', 'shopeepay'

  const SelectedMidtransMethodChanged(this.method);

  @override
  List<Object?> get props => [method];
}

class RefreshProfileStatusEvent extends ReservationDetailFormEvent {
  final bool thenConfirm;
  const RefreshProfileStatusEvent({this.thenConfirm = false});

  @override
  List<Object?> get props => [thenConfirm];
}

class ResetConfirmFlagEvent extends ReservationDetailFormEvent {
  const ResetConfirmFlagEvent();
}

class PaymentSchemeChanged extends ReservationDetailFormEvent {
  final String scheme; // 'full' | 'dp'

  const PaymentSchemeChanged(this.scheme);

  @override
  List<Object?> get props => [scheme];
}