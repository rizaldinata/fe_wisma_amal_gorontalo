import 'dart:typed_data';
import 'package:frontend/data/datasource/guest_datasource.dart';
import 'package:frontend/domain/entity/guest/guest_bill_entity.dart';
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
  Future<List<MyGuestItem>> createGuest({
    required List<Map<String, dynamic>> guests,
    required String checkInAt,
    required String checkOutAt,
  }) async {
    try {
      return await datasource.createGuest(
        guests: guests,
        checkInAt: checkInAt,
        checkOutAt: checkOutAt,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<GuestItem>> createAdminGuest({
    required int scheduleId,
    required List<Map<String, dynamic>> guests,
    required String checkInAt,
    required String checkOutAt,
  }) async {
    try {
      return await datasource.createAdminGuest(
        scheduleId: scheduleId,
        guests: guests,
        checkInAt: checkInAt,
        checkOutAt: checkOutAt,
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

  @override
  Future<GuestItem> checkoutAdminGuest(int id) async {
    try {
      return await datasource.checkoutAdminGuest(id);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<MyGuestItem> checkoutMyGuest(int id) async {
    try {
      return await datasource.checkoutMyGuest(id);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> extendAdminGuest(int id, String newCheckOutAt) async {
    try {
      await datasource.extendAdminGuest(id, newCheckOutAt);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> extendMyGuest(int id, String newCheckOutAt) async {
    try {
      await datasource.extendMyGuest(id, newCheckOutAt);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<GuestBillItem> payGuestBill({
    required int guestId,
    required String paymentMethod,
    Uint8List? proofBytes,
    String? proofName,
  }) async {
    try {
      return await datasource.payGuestBill(
        guestId: guestId,
        paymentMethod: paymentMethod,
        proofBytes: proofBytes,
        proofName: proofName,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AdminGuestBillResponse> getAdminGuestBills({
    int page = 1,
    int perPage = 10,
    String? search,
  }) async {
    try {
      return await datasource.getAdminGuestBills(
          page: page, perPage: perPage, search: search);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> verifyGuestBill({
    required int billId,
    required bool isApproved,
    String? adminNotes,
  }) async {
    try {
      await datasource.verifyGuestBill(
          billId: billId, isApproved: isApproved, adminNotes: adminNotes);
    } catch (e) {
      rethrow;
    }
  }
}
