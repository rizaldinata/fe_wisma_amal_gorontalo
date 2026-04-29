import 'package:frontend/domain/entity/reservation_entity.dart';
import 'package:frontend/domain/repository/reservation_repository.dart';
import 'package:frontend/domain/usecase/usecase.dart';

class GetReservationsUseCase
    implements UseCase<List<ReservationEntity>, NoParams> {

  final ReservationRepository repository;

  GetReservationsUseCase(this.repository);

  @override
  Future<List<ReservationEntity>> call(NoParams params) async {
    return await repository.getReservations();
  }
}