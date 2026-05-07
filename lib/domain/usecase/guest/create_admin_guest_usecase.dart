import 'package:frontend/domain/entity/guest/guest_entity.dart';
import 'package:frontend/domain/repository/guest_repository.dart';

class CreateAdminGuestUseCase {
  final GuestRepository _repository;

  CreateAdminGuestUseCase(this._repository);

  Future<GuestItem> call({
    required int leaseId,
    required String name,
    required String checkInAt,
    required String checkOutAt,
    required String relationship,
  }) {
    return _repository.createAdminGuest(
      leaseId: leaseId,
      name: name,
      checkInAt: checkInAt,
      checkOutAt: checkOutAt,
      relationship: relationship,
    );
  }
}
