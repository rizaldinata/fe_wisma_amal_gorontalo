import 'package:frontend/domain/entity/reservation_entity.dart';

abstract class ReservationRepository {
  Future<List<ReservationEntity>> getReservations();

  Future<ReservationEntity> createReservation({
    required int roomId,
    required String startDate,
    required String endDate,
    required int agreedPrice,
    int? tenantUserId,
    String? tenantName,
  });

  Future<void> cancelReservation(int leaseId);
}
