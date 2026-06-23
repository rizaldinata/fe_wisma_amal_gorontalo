import 'package:frontend/domain/entity/guest/guest_entity.dart';
import 'package:frontend/domain/repository/guest_repository.dart';

class CreateAdminGuestUseCase {
  final GuestRepository _repository;

  CreateAdminGuestUseCase(this._repository);

  Future<GuestItem> call({
    required int scheduleId,
    required String name,
    required String checkInAt,
    required String checkOutAt,
    required String relationship,
  }) {
    return _repository.createAdminGuest(
      scheduleId: scheduleId,
      name: name,
      checkInAt: checkInAt,
      checkOutAt: checkOutAt,
      relationship: relationship,
    );
  }
}
