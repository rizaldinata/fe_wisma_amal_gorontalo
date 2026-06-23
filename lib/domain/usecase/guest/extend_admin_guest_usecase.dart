import 'package:frontend/domain/repository/guest_repository.dart';

class ExtendAdminGuestUseCase {
  final GuestRepository _repository;

  ExtendAdminGuestUseCase(this._repository);

  Future<void> call(int id, String newCheckOutAt) {
    return _repository.extendAdminGuest(id, newCheckOutAt);
  }
}
