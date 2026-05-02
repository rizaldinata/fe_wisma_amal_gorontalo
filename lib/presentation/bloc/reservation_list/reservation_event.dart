import 'package:equatable/equatable.dart';

abstract class ReservationEvent extends Equatable {
  const ReservationEvent();

  @override
  List<Object?> get props => [];
}

class GetReservationsEvent extends ReservationEvent {}

class SearchReservationEvent extends ReservationEvent {
  final String query;

  const SearchReservationEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class FilterReservationDateEvent extends ReservationEvent {
  final DateTime? startDate;

  final DateTime? endDate;

  const FilterReservationDateEvent({this.startDate, this.endDate});

  @override
  List<Object?> get props => [startDate, endDate];
}

class SortReservationEvent extends ReservationEvent {
  final String sortBy;

  const SortReservationEvent(this.sortBy);

  @override
  List<Object?> get props => [sortBy];
}

class UpdateReservationStatusEvent extends ReservationEvent {
  final int reservationId;

  final String status;

  const UpdateReservationStatusEvent({
    required this.reservationId,

    required this.status,
  });

  @override
  List<Object?> get props => [reservationId, status];
}
