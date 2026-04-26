class ResidentProfileEntity {
  final String? id;
  final String? userId;
  final String idCardNumber;
  final String phoneNumber;
  final String gender;
  final String? job;
  final String addressKtp;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String? ktpPhotoUrl;

  ResidentProfileEntity({
    this.id,
    this.userId,
    required this.idCardNumber,
    required this.phoneNumber,
    required this.gender,
    this.job,
    required this.addressKtp,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.ktpPhotoUrl,
  });
}
