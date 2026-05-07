import 'package:frontend/domain/entity/guest/guest_entity.dart';
import 'package:frontend/domain/repository/guest_repository.dart';

class GetAdminGuestsUseCase {
  final GuestRepository _repository;

  GetAdminGuestsUseCase(this._repository);

  Future<GuestResponse> call({
    int page = 1,
    int perPage = 10,
    String? search,
  }) {
    return _repository.getAdminGuests(page: page, perPage: perPage, search: search);
  }
}
