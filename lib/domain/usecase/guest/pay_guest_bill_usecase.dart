import 'dart:typed_data';
import 'package:frontend/domain/entity/guest/guest_bill_entity.dart';
import 'package:frontend/domain/repository/guest_repository.dart';

class PayGuestBillUseCase {
  final GuestRepository _repository;

  PayGuestBillUseCase(this._repository);

  Future<GuestBillItem> call({
    required int guestId,
    required String paymentMethod,
    Uint8List? proofBytes,
    String? proofName,
  }) =>
      _repository.payGuestBill(
        guestId: guestId,
        paymentMethod: paymentMethod,
        proofBytes: proofBytes,
        proofName: proofName,
      );
}
