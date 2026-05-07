import 'package:frontend/domain/repository/guest_repository.dart';

class VerifyGuestBillUseCase {
  final GuestRepository _repository;

  VerifyGuestBillUseCase(this._repository);

  Future<void> call({
    required int billId,
    required bool isApproved,
    String? adminNotes,
  }) =>
      _repository.verifyGuestBill(
        billId: billId,
        isApproved: isApproved,
        adminNotes: adminNotes,
      );
}
