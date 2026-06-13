import 'package:frontend/core/services/network/dio_client.dart';
import 'package:frontend/domain/entity/reservation_entity.dart';

class ReservationRemoteDatasource {
  final DioClient dioClient;

  ReservationRemoteDatasource({required this.dioClient});

  Future<List<ReservationEntity>> getReservations() async {
    try {
      final response = await dioClient.get('/v1/room-schedules', queryParams: {'type': 'sewa'});
      final data = response.data['data'] as List? ?? [];
      return data.map((json) => _scheduleToEntity(json as Map<String, dynamic>)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<ReservationEntity> createReservation({
    required int roomId,
    required String startDate,
    required String endDate,
    required int agreedPrice,
    int? tenantUserId,
    String? tenantName,
  }) async {
    // Step 1: buat schedule di Schedule module
    final scheduleResponse = await dioClient.post(
      '/v1/room-schedules',
      data: {
        'room_id': roomId,
        'type': 'sewa',
        'start_date': startDate,
        'end_date': endDate,
        'agreed_price': agreedPrice,
        if (tenantUserId != null) 'tenant_user_id': tenantUserId,
        if (tenantName != null) 'tenant_name': tenantName,
      },
    );

    final scheduleJson = scheduleResponse.data['data'] as Map<String, dynamic>;
    final scheduleId = scheduleJson['id'] as int;

    // Step 2: ambil invoice yang dibuat otomatis oleh Finance module
    int? invoiceId;
    double? invoiceAmount;
    try {
      final invoiceResponse = await dioClient.get(
        '/finance/me/invoices',
        queryParams: {'schedule_id': scheduleId, 'per_page': 1},
      );
      final invoiceData = invoiceResponse.data['data'] as List?;
      if (invoiceData != null && invoiceData.isNotEmpty) {
        final inv = invoiceData.first as Map<String, dynamic>;
        invoiceId = inv['id'] as int?;
        invoiceAmount = (inv['amount'] as num?)?.toDouble();
      }
    } catch (_) {
      // Invoice mungkin belum tersedia — lanjutkan tanpa invoice
    }

    final roomJson = scheduleJson['room'] as Map<String, dynamic>? ?? {};

    return ReservationEntity(
      id: scheduleId,
      roomTitle: roomJson['title']?.toString() ?? '',
      roomNumber: roomJson['number']?.toString() ?? '',
      residentName: tenantName ?? '',
      rentalType: 'monthly',
      status: scheduleJson['status']?.toString() ?? 'pending',
      paymentStatus: invoiceId != null ? 'unpaid' : 'no_invoice',
      startDate: scheduleJson['start_date']?.toString() ?? startDate,
      endDate: scheduleJson['end_date']?.toString() ?? endDate,
      invoiceId: invoiceId,
      invoiceAmount: invoiceAmount,
      paymentExpiresAt: null,
    );
  }

  Future<void> cancelReservation(int scheduleId) async {
    try {
      await dioClient.post('/v1/room-schedules/$scheduleId/batalkan');
    } catch (e) {
      rethrow;
    }
  }

  ReservationEntity _scheduleToEntity(Map<String, dynamic> json) {
    final tenantJson = json['tenant'] as Map<String, dynamic>? ?? {};
    final roomJson = json['room'] as Map<String, dynamic>? ?? {};
    return ReservationEntity(
      id: json['id'] as int,
      roomTitle: roomJson['title']?.toString() ?? '',
      roomNumber: roomJson['number']?.toString() ?? '',
      residentName: tenantJson['name']?.toString() ?? '',
      rentalType: 'monthly',
      status: json['status']?.toString() ?? '',
      paymentStatus: 'unknown',
      startDate: json['start_date']?.toString() ?? '',
      endDate: json['end_date']?.toString() ?? '',
      invoiceId: null,
      invoiceAmount: null,
      paymentExpiresAt: null,
    );
  }
}
