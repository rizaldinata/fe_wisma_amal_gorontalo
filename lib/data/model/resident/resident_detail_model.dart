import 'package:frontend/domain/entity/resident/resident_detail_entity.dart';

class ResidentDetailModel extends ResidentDetailEntity {
  ResidentDetailModel({
    required super.id,
    required super.status,
    required super.startDate,
    required super.endDate,
    required super.finishedAt,
    required super.paymentProofUrl,
    required super.room,
    required super.resident,
  });

  factory ResidentDetailModel.fromJson(Map<String, dynamic> json) {
    final roomJson = json['room'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final residentJson =
        json['resident'] as Map<String, dynamic>? ?? <String, dynamic>{};

    return ResidentDetailModel(
      id: json['id']?.toString() ?? '-',
      status: json['status'] ?? '-',
      startDate: json['start_date']?.toString() ?? '-',
      endDate: json['end_date']?.toString() ?? '-',
      finishedAt: json['finished_at']?.toString(),
      paymentProofUrl: json['payment_proof_url']?.toString(),
      room: ResidentDetailRoom(
        id: roomJson['id'],
        number: roomJson['number']?.toString() ?? '-',
        title: roomJson['title']?.toString() ?? '-',
        price: _parseNullableInt(roomJson['price']),
      ),
      resident: ResidentDetailPerson(
        id: residentJson['id']?.toString(),
        name: residentJson['name']?.toString() ?? '-',
        email: residentJson['email']?.toString() ?? '-',
        idCardNumber: residentJson['id_card_number']?.toString() ?? '-',
        phoneNumber: residentJson['phone_number']?.toString() ?? '-',
        gender: residentJson['gender']?.toString() ?? '-',
        job: residentJson['job']?.toString() ?? '-',
        addressKtp: residentJson['address_ktp']?.toString() ?? '-',
        emergencyContactName:
            residentJson['emergency_contact_name']?.toString() ?? '-',
        emergencyContactPhone:
            residentJson['emergency_contact_phone']?.toString() ?? '-',
        ktpPhotoUrl: residentJson['ktp_photo_url']?.toString(),
      ),
    );
  }

  static int? _parseNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}
