import 'package:equatable/equatable.dart';

import 'package:formz/formz.dart';

import 'package:frontend/domain/entity/reservation_entity.dart';

class MyReservationState extends Equatable {
  final FormzSubmissionStatus status;

  final List<ReservationEntity> reservations;

  final String? errorMessage;

  const MyReservationState({
    this.status = FormzSubmissionStatus.initial,

    this.reservations = const [],

    this.errorMessage,
  });

  MyReservationState copyWith({
    FormzSubmissionStatus? status,

    List<ReservationEntity>? reservations,

    String? errorMessage,
  }) {
    return MyReservationState(
      status: status ?? this.status,

      reservations:
          reservations ?? this.reservations,

      errorMessage:
          errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,

        reservations,

        errorMessage,
      ];
}