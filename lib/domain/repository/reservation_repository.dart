import 'package:frontend/domain/entity/reservation_entity.dart';

abstract class ReservationRepository {
  Future<List<ReservationEntity>> getReservations();

  Future<ReservationEntity> createReservation({
    required int roomId,
    required String startDate,
    required int duration,
    required String rentalType,
  });

  // Future<void> updateReservationStatus({
  //   required int reservationId,
  //   required String status,
  // });
}