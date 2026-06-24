import 'package:frontend/domain/entity/guest/guest_entity.dart';
import 'package:frontend/domain/repository/guest_repository.dart';

class CreateAdminGuestUseCase {
  final GuestRepository _repository;

  CreateAdminGuestUseCase(this._repository);

  Future<List<GuestItem>> call({
    required int scheduleId,
    required List<Map<String, dynamic>> guests,
    required String checkInAt,
    required String checkOutAt,
  }) {
    return _repository.createAdminGuest(
      scheduleId: scheduleId,
      guests: guests,
      checkInAt: checkInAt,
      checkOutAt: checkOutAt,
    );
  }
}
