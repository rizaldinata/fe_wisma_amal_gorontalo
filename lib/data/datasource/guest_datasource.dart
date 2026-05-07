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

  Future<MyGuestItem> createGuest({
    required String name,
    required String checkInAt,
    required String checkOutAt,
    required String relationship,
  }) async {
    try {
      final response = await dioClient.post(
        EndpointConstant.myGuestsEndpoint,
        data: {
          'name': name,
          'check_in_at': checkInAt,
          'check_out_at': checkOutAt,
          'relationship': relationship,
        },
      );
      return MyGuestItem.fromJson(
          response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<GuestItem> createAdminGuest({
    required int leaseId,
    required String name,
    required String checkInAt,
    required String checkOutAt,
    required String relationship,
  }) async {
    try {
      final response = await dioClient.post(
        EndpointConstant.adminGuestsEndpoint,
        data: {
          'lease_id': leaseId,
          'name': name,
          'check_in_at': checkInAt,
          'check_out_at': checkOutAt,
          'relationship': relationship,
        },
      );
      final payload = response.data['data'];
      return GuestItem.fromJson(
          payload is Map<String, dynamic> ? payload : <String, dynamic>{});
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
