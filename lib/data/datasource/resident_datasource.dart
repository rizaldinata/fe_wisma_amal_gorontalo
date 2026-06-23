import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:frontend/core/services/network/dio_client.dart';
import 'package:frontend/domain/entity/resident/resident_entity.dart';
import 'package:frontend/domain/entity/resident/resident_detail_entity.dart';
import 'package:frontend/domain/entity/resident/resident_profile_entity.dart';
import 'package:frontend/data/model/resident/resident_detail_model.dart';
import 'package:frontend/data/model/resident/resident_profile_model.dart';

class ResidentDatasource {
  final DioClient dioClient;

  ResidentDatasource({required this.dioClient});

  /// Mengambil daftar semua penghuni untuk halaman Admin (berserta paginasi dan filter)
  Future<ResidentResponse> getAdminResidents({
    int page = 1,
    int perPage = 10,
    String? search,
    String? status,
    String? payment,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page,
        'per_page': perPage,
      };

      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (status != null) queryParams['status'] = status;
      if (payment != null) queryParams['payment'] = payment;

      final response = await dioClient.get(
        '/v1/room-schedules',
        queryParams: queryParams,
      );

      return ResidentResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Mengambil detail spesifik dari satu penghuni
  Future<ResidentDetailEntity> getAdminResidentDetail(String id) async {
    try {
      // Sesuaikan URL ini jika endpoint detail di backend berbeda
      final response = await dioClient.get('/v1/room-schedules/$id');
      return ResidentDetailModel.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  /// Mengambil data profil milik penghuni yang sedang login
  Future<ResidentProfileEntity> getProfile() async {
    try {
      // Diambil dari endpoint Auth Module backend yang sudah Anda miliki
      final response = await dioClient.get('/v1/resident/profile');
      return ResidentProfileModel.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  /// Melengkapi profil data diri penghuni (termasuk upload foto KTP)
  Future<ResidentProfileEntity> completeProfile({
    required String idCardNumber,
    required String phoneNumber,
    required String gender,
    String? job,
    required String addressKtp,
    String? emergencyContactName,
    String? emergencyContactPhone,
    PlatformFile? ktpPhoto,
  }) async {
    try {
      // Menggunakan FormData karena ada potensi pengiriman file (Multipart/form-data)
      FormData formData = FormData.fromMap({
        'id_card_number': idCardNumber,
        'phone_number': phoneNumber,
        'gender': gender,
        'address_ktp': addressKtp,
        if (job != null) 'job': job,
        if (emergencyContactName != null)
          'emergency_contact_name': emergencyContactName,
        if (emergencyContactPhone != null)
          'emergency_contact_phone': emergencyContactPhone,
      });

      // Menyisipkan file KTP jika user memilih file
      if (ktpPhoto != null && ktpPhoto.path != null) {
        formData.files.add(
          MapEntry(
            'ktp_photo',
            await MultipartFile.fromFile(
              ktpPhoto.path!,
              filename: ktpPhoto.name,
            ),
          ),
        );
      }

      final response = await dioClient.post(
        '/v1/resident/profile',
        data: formData,
      );
      return ResidentProfileModel.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }
}
