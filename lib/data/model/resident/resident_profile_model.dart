import 'package:frontend/domain/entity/resident/resident_profile_entity.dart';

class ResidentProfileModel extends ResidentProfileEntity {
  ResidentProfileModel({
    super.id,
    super.userId,
    required super.idCardNumber,
    required super.phoneNumber,
    required super.gender,
    super.job,
    required super.addressKtp,
    super.emergencyContactName,
    super.emergencyContactPhone,
    super.ktpPhotoUrl,
  });

  factory ResidentProfileModel.fromJson(Map<String, dynamic> json) {
    return ResidentProfileModel(
      id: json['id']?.toString(),
      userId: json['user_id']?.toString(),
      idCardNumber: json['id_card_number'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      gender: json['gender'] ?? '',
      job: json['job'],
      addressKtp: json['address_ktp'] ?? '',
      emergencyContactName: json['emergency_contact_name'],
      emergencyContactPhone: json['emergency_contact_phone'],
      ktpPhotoUrl: json['ktp_photo_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_card_number': idCardNumber,
      'phone_number': phoneNumber,
      'gender': gender,
      'job': job,
      'address_ktp': addressKtp,
      'emergency_contact_name': emergencyContactName,
      'emergency_contact_phone': emergencyContactPhone,
    };
  }
}
