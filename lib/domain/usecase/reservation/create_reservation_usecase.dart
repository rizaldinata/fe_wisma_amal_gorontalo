import 'package:frontend/domain/entity/reservation_entity.dart';
import 'package:frontend/domain/repository/reservation_repository.dart';

class CreateReservationUseCase {
  final ReservationRepository repository;

  CreateReservationUseCase(this.repository);

  Future<ReservationEntity> execute({
    required int roomId,
    required String startDate,
    required int duration,
    required String rentalType,
  }) async {
    return await repository.createReservation(
      roomId: roomId,
      startDate: startDate,
      duration: duration,
      rentalType: rentalType,
    );
  }
}
