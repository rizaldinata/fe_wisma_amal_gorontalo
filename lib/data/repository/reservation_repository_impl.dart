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

  // @override
  // Future<void> updateReservationStatus({
  //   required int reservationId,

  //   required String status,
  // }) async {
  //   await remoteDatasource.updateReservationStatus(
  //     reservationId: reservationId,

  //     status: status,
  //   );
  // }
}
