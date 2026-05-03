import 'package:frontend/domain/entity/reservation_entity.dart';
import 'package:frontend/domain/repository/my_reservation_repository.dart';

class GetMyReservationsUseCase {
  final MyReservationRepository repository;

  GetMyReservationsUseCase(this.repository);

  Future<List<ReservationEntity>> call() async {
    return await repository.getMyReservations();
  }
}