import 'package:frontend/domain/repository/guest_repository.dart';

class ExtendMyGuestUseCase {
  final GuestRepository _repository;

  ExtendMyGuestUseCase(this._repository);

  Future<void> call(int id, String newCheckOutAt) {
    return _repository.extendMyGuest(id, newCheckOutAt);
  }
}
