import 'package:frontend/domain/entity/guest/guest_entity.dart';
import 'package:frontend/domain/repository/guest_repository.dart';

class CheckoutAdminGuestUseCase {
  final GuestRepository repository;

  CheckoutAdminGuestUseCase(this.repository);

  Future<GuestItem> call(int id) async {
    return await repository.checkoutAdminGuest(id);
  }
}
