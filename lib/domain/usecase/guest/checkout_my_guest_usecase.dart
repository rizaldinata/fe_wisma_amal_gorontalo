import 'package:frontend/domain/entity/guest/guest_entity.dart';
import 'package:frontend/domain/repository/guest_repository.dart';

class CheckoutMyGuestUseCase {
  final GuestRepository repository;

  CheckoutMyGuestUseCase(this.repository);

  Future<MyGuestItem> call(int id) async {
    return await repository.checkoutMyGuest(id);
  }
}
