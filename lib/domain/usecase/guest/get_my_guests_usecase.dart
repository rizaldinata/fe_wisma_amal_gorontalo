import 'package:frontend/domain/entity/guest/guest_entity.dart';
import 'package:frontend/domain/repository/guest_repository.dart';

class GetMyGuestsUseCase {
  final GuestRepository _repository;

  GetMyGuestsUseCase(this._repository);

  Future<List<MyGuestItem>> call() => _repository.getMyGuests();
}
