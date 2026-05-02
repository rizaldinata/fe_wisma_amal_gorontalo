import 'package:frontend/domain/repository/reservation_repository.dart';

class UpdateReservationStatusUseCase {
  final ReservationRepository repository;

  UpdateReservationStatusUseCase(
    this.repository,
  );

  Future<void> call({
    required int reservationId,
    required String status,
  }) async {
    await repository.updateReservationStatus(
      reservationId: reservationId,
      status: status,
    );
  }
}