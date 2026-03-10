import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';

class ReservationState extends Equatable {
  final FormzSubmissionStatus status;
  final List<Map<String, dynamic>> reservations;
  final String? errorMessage;
  final String? successMessage;

  List<Map<String, dynamic>> get aktifReservations =>
      reservations.where((r) => r['status'] == 'Aktif').toList();
  List<Map<String, dynamic>> get pendingReservations =>
      reservations.where((r) => r['status'] == 'Pending').toList();
  List<Map<String, dynamic>> get selesaiReservations =>
      reservations.where((r) => r['status'] == 'Selesai').toList();

  const ReservationState({
    this.status = FormzSubmissionStatus.initial,
    this.reservations = const [],
    this.errorMessage,
    this.successMessage,
  });

  ReservationState copyWith({
    FormzSubmissionStatus? status,
    List<Map<String, dynamic>>? reservations,
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
  List<Object?> get props => [status, reservations, errorMessage, successMessage];
}