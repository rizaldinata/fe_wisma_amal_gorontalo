abstract class MyReservationEvent {}

class GetMyReservationsEvent extends MyReservationEvent {}

class CancelMyReservationEvent extends MyReservationEvent {
  final int scheduleId;
  CancelMyReservationEvent(this.scheduleId);
}

class AjukanPembatalanDpEvent extends MyReservationEvent {
  final int scheduleId;
  final String bankName;
  final String accountNumber;
  final String accountHolderName;

  AjukanPembatalanDpEvent({
    required this.scheduleId,
    required this.bankName,
    required this.accountNumber,
    required this.accountHolderName,
  });
}
