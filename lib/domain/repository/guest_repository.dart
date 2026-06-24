import 'dart:typed_data';
import 'package:frontend/domain/entity/guest/guest_bill_entity.dart';
import 'package:frontend/domain/entity/guest/guest_entity.dart';

abstract class GuestRepository {
  Future<GuestResponse> getAdminGuests({
    int page = 1,
    int perPage = 10,
    String? search,
  });

  Future<List<MyGuestItem>> getMyGuests();

  Future<List<MyGuestItem>> createGuest({
    required List<Map<String, dynamic>> guests,
    required String checkInAt,
    required String checkOutAt,
  });

  Future<List<GuestItem>> createAdminGuest({
    required int scheduleId,
    required List<Map<String, dynamic>> guests,
    required String checkInAt,
    required String checkOutAt,
  });

  Future<void> deleteGuest(int id);
  Future<GuestItem> checkoutAdminGuest(int id);
  Future<MyGuestItem> checkoutMyGuest(int id);
  Future<void> extendAdminGuest(int id, String newCheckOutAt);
  Future<void> extendMyGuest(int id, String newCheckOutAt);

  // ─── Billing ─────────────────────────────────────────────────────────────

  Future<GuestBillItem> payGuestBill({
    required int guestId,
    required String paymentMethod,
    Uint8List? proofBytes,
    String? proofName,
  });

  Future<AdminGuestBillResponse> getAdminGuestBills({
    int page = 1,
    int perPage = 10,
    String? search,
  });

  Future<void> verifyGuestBill({
    required int billId,
    required bool isApproved,
    String? adminNotes,
  });
}
