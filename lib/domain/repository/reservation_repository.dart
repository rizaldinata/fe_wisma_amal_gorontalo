import 'package:frontend/domain/entity/reservation_entity.dart';

abstract class ReservationRepository {
  Future<List<ReservationEntity>> getReservations();

  Future<void> updateReservationStatus({
    required int reservationId,
    required String status,
  });
}