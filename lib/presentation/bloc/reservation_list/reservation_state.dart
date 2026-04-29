import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:frontend/domain/entity/reservation_entity.dart';

class ReservationState extends Equatable {
  final FormzSubmissionStatus status;
  final List<ReservationEntity> reservations;
  final String? errorMessage;
  final String? successMessage;

  List<ReservationEntity> get activeReservations =>
      reservations.where((r) => r.status == 'active').toList();

  List<ReservationEntity> get pendingReservations =>
      reservations.where((r) => r.status == 'pending').toList();

  List<ReservationEntity> get cancelledReservations =>
      reservations.where((r) => r.status == 'cancelled').toList();

  const ReservationState({
    this.status = FormzSubmissionStatus.initial,
    this.reservations = const [],
    this.errorMessage,
    this.successMessage,
  });

  ReservationState copyWith({
    FormzSubmissionStatus? status,
    List<ReservationEntity>? reservations,
    String? errorMessage,
    String? successMessage,
  }) {
    return ReservationState(
      status: status ?? this.status,
      reservations: reservations ?? this.reservations,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        reservations,
        errorMessage,
        successMessage,
      ];
}