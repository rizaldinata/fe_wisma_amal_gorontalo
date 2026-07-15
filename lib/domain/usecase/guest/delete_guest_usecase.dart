import 'package:frontend/domain/repository/guest_repository.dart';

class DeleteGuestUseCase {
  final GuestRepository _repository;

  DeleteGuestUseCase(this._repository);

  Future<void> call(int id) => _repository.deleteGuest(id);
}
