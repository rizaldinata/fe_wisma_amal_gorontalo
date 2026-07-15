import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:frontend/core/constant/endpoint_constant.dart';
import 'package:frontend/core/services/network/dio_client.dart';
import 'package:frontend/domain/entity/guest/guest_bill_entity.dart';
import 'package:frontend/domain/entity/guest/guest_entity.dart';

class GuestDatasource {
  final DioClient dioClient;

  GuestDatasource({required this.dioClient});

  Future<GuestResponse> getAdminGuests({
    int page = 1,
    int perPage = 10,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'per_page': perPage,
      };
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final response = await dioClient.get(
        EndpointConstant.adminGuestsEndpoint,
        queryParams: queryParams,
      );
      return GuestResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<MyGuestItem>> getMyGuests() async {
    try {
      final response = await dioClient.get(EndpointConstant.myGuestsEndpoint);
      final data = response.data['data'] as List<dynamic>? ?? <dynamic>[];
      return data
          .map((e) => MyGuestItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // REVISI: Mendukung pendaftaran multi-tamu (maks 3) dalam satu request
  Future<List<MyGuestItem>> createGuest({
    required List<Map<String, dynamic>> guests,
    required List<Uint8List> identityImages,
    required List<String> identityImageNames,
    required String checkInAt,
    required String checkOutAt,
  }) async {
    try {
      final formData = FormData();
      formData.fields.add(MapEntry('check_in_at', checkInAt));
      formData.fields.add(MapEntry('check_out_at', checkOutAt));

      for (int i = 0; i < guests.length; i++) {
        formData.fields.add(MapEntry('guests[$i][name]', guests[i]['name']));
        formData.fields.add(MapEntry('guests[$i][relationship]', guests[i]['relationship']));
        if (i < identityImages.length && i < identityImageNames.length && identityImages[i].isNotEmpty) {
          formData.files.add(MapEntry(
            'guests[$i][identity_image]',
            MultipartFile.fromBytes(identityImages[i], filename: identityImageNames[i]),
          ));
        }
      }

      final response = await dioClient.post(
        EndpointConstant.myGuestsEndpoint,
        data: formData,
      );
      final payload = response.data['data'];
      if (payload is List) {
        return payload
            .map((e) => MyGuestItem.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      // Fallback: jika backend mengembalikan single object
      if (payload is Map<String, dynamic>) {
        return [MyGuestItem.fromJson(payload)];
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  // REVISI: Mendukung pendaftaran multi-tamu oleh admin
  Future<List<GuestItem>> createAdminGuest({
    required int scheduleId,
    required List<Map<String, dynamic>> guests,
    required String checkInAt,
    required String checkOutAt,
  }) async {
    try {
      final response = await dioClient.post(
        EndpointConstant.adminGuestsEndpoint,
        data: {
          'schedule_id': scheduleId,
          'guests': guests,
          'check_in_at': checkInAt,
          'check_out_at': checkOutAt,
        },
      );
      final payload = response.data['data'];
      if (payload is List) {
        return payload
            .map((e) => GuestItem.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      // Fallback: jika backend mengembalikan single object
      if (payload is Map<String, dynamic>) {
        return [GuestItem.fromJson(payload)];
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteGuest(int id) async {
    try {
      await dioClient.delete(EndpointConstant.deleteGuestEndpoint(id));
    } catch (e) {
      rethrow;
    }
  }

  Future<GuestItem> checkoutAdminGuest(int id) async {
    try {
      final response = await dioClient.post(EndpointConstant.checkoutAdminGuestEndpoint(id));
      final payload = response.data['data'];
      return GuestItem.fromJson(
          payload is Map<String, dynamic> ? payload : <String, dynamic>{});
    } catch (e) {
      rethrow;
    }
  }

  Future<MyGuestItem> checkoutMyGuest(int id) async {
    try {
      final response = await dioClient.post(EndpointConstant.checkoutMyGuestEndpoint(id));
      final payload = response.data['data'];
      return MyGuestItem.fromJson(
          payload is Map<String, dynamic> ? payload : <String, dynamic>{});
    } catch (e) {
      rethrow;
    }
  }

  Future<void> extendAdminGuest(int id, String newCheckOutAt) async {
    try {
      await dioClient.put(
        EndpointConstant.extendAdminGuestEndpoint(id),
        data: {'check_out_at': newCheckOutAt},
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> extendMyGuest(int id, String newCheckOutAt) async {
    try {
      await dioClient.put(
        EndpointConstant.extendMyGuestEndpoint(id),
        data: {'check_out_at': newCheckOutAt},
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<GuestBillItem> payGuestBill({
    required int guestId,
    required String paymentMethod,
    Uint8List? proofBytes,
    String? proofName,
  }) async {
    try {
      dynamic data;
      if (paymentMethod == 'manual' && proofBytes != null) {
        data = FormData.fromMap({
          'payment_method': paymentMethod,
          'payment_proof': MultipartFile.fromBytes(
            proofBytes,
            filename: proofName ?? 'payment_proof.jpg',
          ),
        });
      } else {
        data = {'payment_method': paymentMethod};
      }
      final response = await dioClient.post(
        EndpointConstant.payGuestBillEndpoint(guestId),
        data: data,
      );
      return GuestBillItem.fromJson(
          response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<AdminGuestBillResponse> getAdminGuestBills({
    int page = 1,
    int perPage = 10,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'per_page': perPage,
      };
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      final response = await dioClient.get(
        EndpointConstant.adminGuestBillsEndpoint,
        queryParams: queryParams,
      );
      return AdminGuestBillResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> verifyGuestBill({
    required int billId,
    required bool isApproved,
    String? adminNotes,
  }) async {
    try {
      await dioClient.post(
        EndpointConstant.verifyGuestBillEndpoint(billId),
        data: {
          'is_approved': isApproved,
          if (adminNotes != null) 'admin_notes': adminNotes,
        },
      );
    } catch (e) {
      rethrow;
    }
  }
}
