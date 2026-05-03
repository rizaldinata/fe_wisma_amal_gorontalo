import 'package:frontend/domain/entity/reservation_entity.dart';

abstract class MyReservationRepository {
  Future<List<ReservationEntity>> getMyReservations();
}