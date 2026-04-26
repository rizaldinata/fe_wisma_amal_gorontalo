import 'package:file_picker/file_picker.dart';
import 'package:frontend/domain/entity/resident/resident_profile_entity.dart';

abstract class ResidentRepository {
  Future<ResidentProfileEntity> getProfile();
  Future<ResidentProfileEntity> completeProfile({
    required String idCardNumber,
    required String phoneNumber,
    required String gender,
    String? job,
    required String addressKtp,
    String? emergencyContactName,
    String? emergencyContactPhone,
    PlatformFile? ktpPhoto,
  });
}
