import 'package:frontend/domain/entity/reservation_entity.dart';
import 'package:frontend/domain/repository/reservation_repository.dart';

class CreateReservationUseCase {
  final ReservationRepository repository;

  CreateReservationUseCase(this.repository);

  Future<ReservationEntity> execute({
    required int roomId,
    required String startDate,
    required String endDate,
    required int agreedPrice,
    int? tenantUserId,
    String? tenantName,
    String? paymentScheme,
  }) async {
    return await repository.createReservation(
      roomId: roomId,
      startDate: startDate,
      endDate: endDate,
      agreedPrice: agreedPrice,
      tenantUserId: tenantUserId,
      tenantName: tenantName,
      paymentScheme: paymentScheme,
    );
  }
}
