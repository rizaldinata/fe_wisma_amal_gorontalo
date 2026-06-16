abstract class MyReservationEvent {}

class GetMyReservationsEvent extends MyReservationEvent {}

class CancelMyReservationEvent extends MyReservationEvent {
  final int scheduleId;
  CancelMyReservationEvent(this.scheduleId);
}
