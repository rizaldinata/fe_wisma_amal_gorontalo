import 'package:frontend/data/datasource/my_reservation_remote_datasource.dart';
import 'package:frontend/domain/entity/reservation_entity.dart';
import 'package:frontend/domain/repository/my_reservation_repository.dart';

class MyReservationRepositoryImpl implements MyReservationRepository {
  final MyReservationRemoteDatasource remoteDatasource;

  MyReservationRepositoryImpl({required this.remoteDatasource});

  @override
  Future<List<ReservationEntity>> getMyReservations() async {
    return await remoteDatasource.getMyReservations();
  }

  @override
  Future<void> ajukanPembatalanDp({
    required int scheduleId,
    required String bankName,
    required String accountNumber,
    required String accountHolderName,
  }) async {
    return await remoteDatasource.ajukanPembatalanDp(
      scheduleId: scheduleId,
      bankName: bankName,
      accountNumber: accountNumber,
      accountHolderName: accountHolderName,
    );
  }
}