import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:frontend/core/constant/endpoint_constant.dart';
import 'package:frontend/core/services/network/dio_client.dart';
import 'package:frontend/data/model/base_response_model.dart';
import 'package:frontend/data/model/resident/resident_profile_model.dart';
import 'package:frontend/domain/entity/resident/resident_entity.dart';

class ResidentDatasource {
  final DioClient dioClient;

  ResidentDatasource({required this.dioClient});

  Future<ResidentResponse> getAdminResidents() async {
    try {
      final response = await dioClient.get(
        EndpointConstant.adminResidentsEndpoint,
      );
      return ResidentResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<BaseResponseModel<ResidentProfileModel>> getProfile() async {
    try {
      final response = await dioClient.get(
        EndpointConstant.residentProfileEndpoint,
      );
      return BaseResponseModel<ResidentProfileModel>.fromJson(
        response.data,
        (json) => ResidentProfileModel.fromJson(json),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<BaseResponseModel<ResidentProfileModel>> completeProfile({
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
      final formData = FormData.fromMap({
        'id_card_number': idCardNumber,
        'phone_number': phoneNumber,
        'gender': gender,
        'job': job,
        'address_ktp': addressKtp,
        'emergency_contact_name': emergencyContactName,
        'emergency_contact_phone': emergencyContactPhone,
      });

      if (ktpPhoto != null && ktpPhoto.bytes != null) {
        formData.files.add(
          MapEntry(
            'ktp_photo',
            MultipartFile.fromBytes(
              ktpPhoto.bytes!,
              filename: ktpPhoto.name,
              contentType: DioMediaType.parse('image/jpeg'),
            ),
          ),
        );
      }

      final response = await dioClient.post(
        EndpointConstant.residentProfileEndpoint,
        data: formData,
      );

      return BaseResponseModel<ResidentProfileModel>.fromJson(
        response.data,
        (json) => ResidentProfileModel.fromJson(json),
      );
    } catch (e) {
      rethrow;
    }
  }
}
