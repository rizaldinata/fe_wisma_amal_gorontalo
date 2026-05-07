import 'package:frontend/domain/entity/guest/guest_entity.dart';
import 'package:frontend/domain/repository/guest_repository.dart';

class CreateGuestUseCase {
  final GuestRepository _repository;

  CreateGuestUseCase(this._repository);

  Future<MyGuestItem> call({
    required String name,
    required String checkInAt,
    required String checkOutAt,
    required String relationship,
  }) =>
      _repository.createGuest(
        name: name,
        checkInAt: checkInAt,
        checkOutAt: checkOutAt,
        relationship: relationship,
      );
}
