import 'package:frontend/domain/entity/guest/guest_entity.dart';

abstract class GuestRepository {
  Future<GuestResponse> getAdminGuests({
    int page = 1,
    int perPage = 10,
    String? search,
  });

  Future<List<MyGuestItem>> getMyGuests();

  Future<MyGuestItem> createGuest({
    required String name,
    required String checkInAt,
    required String checkOutAt,
    required String relationship,
  });

  Future<void> deleteGuest(int id);
}
