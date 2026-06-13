import 'package:frontend/data/datasource/reservation_remote_datasource.dart';
import 'package:frontend/domain/entity/reservation_entity.dart';
import 'package:frontend/domain/repository/reservation_repository.dart';

class ReservationRepositoryImpl implements ReservationRepository {
  final ReservationRemoteDatasource remoteDatasource;

  ReservationRepositoryImpl({required this.remoteDatasource});

  @override
  Future<List<ReservationEntity>> getReservations() async {
    return await remoteDatasource.getReservations();
  }

  @override
  Future<ReservationEntity> createReservation({
    required int roomId,
    required String startDate,
    required String endDate,
    required int agreedPrice,
    int? tenantUserId,
    String? tenantName,
  }) async {
    return await remoteDatasource.createReservation(
      roomId: roomId,
      startDate: startDate,
      endDate: endDate,
      agreedPrice: agreedPrice,
      tenantUserId: tenantUserId,
      tenantName: tenantName,
    );
  }

  @override
  Future<void> cancelReservation(int leaseId) async {
    return await remoteDatasource.cancelReservation(leaseId);
  }
}
