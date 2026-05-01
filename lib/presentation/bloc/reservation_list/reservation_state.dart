import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:frontend/domain/entity/reservation_entity.dart';

class ReservationState extends Equatable {
  final FormzSubmissionStatus status;

  final List<ReservationEntity> reservations;

  final String? errorMessage;

  final String? successMessage;

  final String searchQuery;

  final DateTime? startDateFilter;

  final DateTime? endDateFilter;

  final String sortBy;

  const ReservationState({
    this.status = FormzSubmissionStatus.initial,
    this.reservations = const [],
    this.errorMessage,
    this.successMessage,
    this.searchQuery = '',
    this.startDateFilter,
    this.endDateFilter,
    this.sortBy = 'all',
  });

  List<ReservationEntity> get activeReservations =>
      reservations.where((r) => r.status == 'active').toList();

  List<ReservationEntity> get pendingReservations =>
      reservations.where((r) => r.status == 'pending').toList();

  List<ReservationEntity> get cancelledReservations =>
      reservations.where((r) => r.status == 'cancelled').toList();

  List<ReservationEntity> get filteredReservations {
    List<ReservationEntity> filtered = List.from(reservations);

    // SEARCH FILTER
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((reservation) {
        final residentName = reservation.residentName.toLowerCase();

        final roomNumber = reservation.roomNumber.toLowerCase();

        final query = searchQuery.toLowerCase();

        return residentName.contains(query) || roomNumber.contains(query);
      }).toList();
    }

    // START DATE FILTER
    if (startDateFilter != null) {
      filtered = filtered.where((reservation) {
        final reservationStartDate = DateTime.tryParse(reservation.startDate);

        if (reservationStartDate == null) {
          return false;
        }

        return reservationStartDate.isAfter(startDateFilter!) ||
            reservationStartDate.isAtSameMomentAs(startDateFilter!);
      }).toList();
    }

    // END DATE FILTER
    if (endDateFilter != null) {
      filtered = filtered.where((reservation) {
        final reservationEndDate = DateTime.tryParse(reservation.endDate);

        if (reservationEndDate == null) {
          return false;
        }

        return reservationEndDate.isBefore(endDateFilter!) ||
            reservationEndDate.isAtSameMomentAs(endDateFilter!);
      }).toList();
    }

    // SORT / STATUS FILTER
    if (sortBy != 'all') {
      filtered = filtered.where((reservation) {
        return reservation.status.toLowerCase() == sortBy.toLowerCase();
      }).toList();
    }

    return filtered;
  }

  ReservationState copyWith({
    FormzSubmissionStatus? status,
    List<ReservationEntity>? reservations,
    String? errorMessage,
    String? successMessage,
    String? searchQuery,
    DateTime? startDateFilter,
    DateTime? endDateFilter,
    String? sortBy,
  }) {
    return ReservationState(
      status: status ?? this.status,

      reservations: reservations ?? this.reservations,

      errorMessage: errorMessage ?? this.errorMessage,

      successMessage: successMessage ?? this.successMessage,

      searchQuery: searchQuery ?? this.searchQuery,

      startDateFilter: startDateFilter ?? this.startDateFilter,

      endDateFilter: endDateFilter ?? this.endDateFilter,

      sortBy: sortBy ?? this.sortBy,
    );
  }

  @override
  List<Object?> get props => [
    status,

    reservations,

    errorMessage,

    successMessage,

    searchQuery,

    startDateFilter,

    endDateFilter,

    sortBy,
  ];
}
