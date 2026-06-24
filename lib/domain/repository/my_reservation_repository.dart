import 'package:frontend/domain/entity/reservation_entity.dart';

abstract class MyReservationRepository {
  Future<List<ReservationEntity>> getMyReservations();

  Future<void> ajukanPembatalanDp({
    required int scheduleId,
    required String bankName,
    required String accountNumber,
    required String accountHolderName,
  });
}