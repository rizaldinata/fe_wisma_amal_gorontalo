import 'package:file_picker/file_picker.dart';
import 'package:frontend/domain/entity/resident/resident_entity.dart';
import 'package:frontend/data/datasource/resident_datasource.dart';
import 'package:frontend/domain/entity/resident/resident_detail_entity.dart';
import 'package:frontend/domain/entity/resident/resident_profile_entity.dart';
import 'package:frontend/domain/repository/resident_repository.dart';

class ResidentRepositoryImpl implements ResidentRepository {
  final ResidentDatasource datasource;

  ResidentRepositoryImpl({required this.datasource});

  @override
  Future<ResidentResponse> getAdminResidents({
    int page = 1,
    int perPage = 10,
    String? search,
    String? status,
    String? payment,
  }) async {
    try {
      final response = await datasource.getAdminResidents(
        page: page,
        perPage: perPage,
        search: search,
        status: status,
        payment: payment,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ResidentDetailEntity> getAdminResidentDetail(String id) async {
    try {
      final response = await datasource.getAdminResidentDetail(id);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ResidentProfileEntity> getProfile() async {
    try {
      final response = await datasource.getProfile();
      return response;
    } catch (e) {
      rethrow;
    }
  }

  @override
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
      final response = await datasource.completeProfile(
        idCardNumber: idCardNumber,
        phoneNumber: phoneNumber,
        gender: gender,
        job: job,
        addressKtp: addressKtp,
        emergencyContactName: emergencyContactName,
        emergencyContactPhone: emergencyContactPhone,
        ktpPhoto: ktpPhoto,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}