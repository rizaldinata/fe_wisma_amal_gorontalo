import 'package:frontend/domain/repository/reservation_repository.dart';

class CancelReservationUseCase {
  final ReservationRepository repository;

  CancelReservationUseCase({required this.repository});

  Future<void> execute(int leaseId) async {
    return await repository.cancelReservation(leaseId);
  }
}
