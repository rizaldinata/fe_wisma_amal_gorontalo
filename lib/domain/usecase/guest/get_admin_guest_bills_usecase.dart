import 'package:frontend/domain/entity/guest/guest_bill_entity.dart';
import 'package:frontend/domain/repository/guest_repository.dart';

class GetAdminGuestBillsUseCase {
  final GuestRepository _repository;

  GetAdminGuestBillsUseCase(this._repository);

  Future<AdminGuestBillResponse> call({
    int page = 1,
    int perPage = 10,
    String? search,
  }) =>
      _repository.getAdminGuestBills(page: page, perPage: perPage, search: search);
}
