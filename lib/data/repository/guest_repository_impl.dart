import 'package:frontend/data/datasource/guest_datasource.dart';
import 'package:frontend/domain/entity/guest/guest_entity.dart';
import 'package:frontend/domain/repository/guest_repository.dart';

class GuestRepositoryImpl implements GuestRepository {
  final GuestDatasource datasource;

  GuestRepositoryImpl({required this.datasource});

  @override
  Future<GuestResponse> getAdminGuests({
    int page = 1,
    int perPage = 10,
    String? search,
  }) async {
    try {
      return await datasource.getAdminGuests(page: page, perPage: perPage, search: search);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<MyGuestItem>> getMyGuests() async {
    try {
      return await datasource.getMyGuests();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<MyGuestItem> createGuest({
    required String name,
    required String checkInAt,
    required String checkOutAt,
    required String relationship,
  }) async {
    try {
      return await datasource.createGuest(
        name: name,
        checkInAt: checkInAt,
        checkOutAt: checkOutAt,
        relationship: relationship,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteGuest(int id) async {
    try {
      await datasource.deleteGuest(id);
    } catch (e) {
      rethrow;
    }
  }
}
