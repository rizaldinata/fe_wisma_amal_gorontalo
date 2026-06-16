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
    // Schedule API format: tenant{user_id, name, id_number, phone, id_photo}, room{id, number, title, price}
    final tenantJson = json['tenant'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final roomJson = json['room'] as Map<String, dynamic>? ?? <String, dynamic>{};

    return ResidentDetailModel(
      id: json['id']?.toString() ?? '-',
      status: json['status']?.toString() ?? '-',
      startDate: json['start_date']?.toString() ?? '-',
      endDate: json['end_date']?.toString() ?? '-',
      finishedAt: json['finished_at']?.toString(),
      paymentProofUrl: null,
      room: ResidentDetailRoom(
        id: _parseNullableInt(roomJson['id']),
        number: roomJson['number']?.toString() ?? '-',
        title: roomJson['title']?.toString() ?? '-',
        price: _parseNullableInt(roomJson['price']),
      ),
      resident: ResidentDetailPerson(
        id: tenantJson['user_id']?.toString(),
        name: tenantJson['name']?.toString() ?? '-',
        email: '-',
        idCardNumber: tenantJson['id_number']?.toString() ?? '-',
        phoneNumber: tenantJson['phone']?.toString() ?? '-',
        gender: '-',
        job: '-',
        addressKtp: '-',
        emergencyContactName: '-',
        emergencyContactPhone: '-',
        ktpPhotoUrl: tenantJson['id_photo']?.toString(),
      ),
    );
  }

  static int? _parseNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}
