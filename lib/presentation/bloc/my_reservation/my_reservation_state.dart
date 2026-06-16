import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:frontend/domain/entity/reservation_entity.dart';

class MyReservationState extends Equatable {
  final FormzSubmissionStatus status;
  final FormzSubmissionStatus cancelStatus;
  final List<ReservationEntity> reservations;
  final String? errorMessage;

  const MyReservationState({
    this.status = FormzSubmissionStatus.initial,
    this.cancelStatus = FormzSubmissionStatus.initial,
    this.reservations = const [],
    this.errorMessage,
  });

  MyReservationState copyWith({
    FormzSubmissionStatus? status,
    FormzSubmissionStatus? cancelStatus,
    List<ReservationEntity>? reservations,
    String? errorMessage,
  }) {
    return MyReservationState(
      status: status ?? this.status,
      cancelStatus: cancelStatus ?? this.cancelStatus,
      reservations: reservations ?? this.reservations,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, cancelStatus, reservations, errorMessage];
}
