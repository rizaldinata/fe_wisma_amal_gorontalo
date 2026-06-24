import 'package:frontend/domain/repository/my_reservation_repository.dart';

class AjukanPembatalanDpUseCase {
  final MyReservationRepository repository;

  AjukanPembatalanDpUseCase({required this.repository});

  Future<void> execute({
    required int scheduleId,
    required String bankName,
    required String accountNumber,
    required String accountHolderName,
  }) async {
    return await repository.ajukanPembatalanDp(
      scheduleId: scheduleId,
      bankName: bankName,
      accountNumber: accountNumber,
      accountHolderName: accountHolderName,
    );
  }
}
