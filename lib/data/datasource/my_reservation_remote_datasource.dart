import 'package:frontend/core/services/network/dio_client.dart';
import 'package:frontend/domain/entity/reservation_entity.dart';

class MyReservationRemoteDatasource {
  final DioClient dioClient;

  MyReservationRemoteDatasource({
    required this.dioClient,
  });

  Future<void> ajukanPembatalanDp({
    required int scheduleId,
    required String bankName,
    required String accountNumber,
    required String accountHolderName,
  }) async {
    try {
      await dioClient.post(
        '/finance/me/schedules/$scheduleId/ajukan-pembatalan-dp',
        data: {
          'bank_name': bankName,
          'account_number': accountNumber,
          'account_holder_name': accountHolderName,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ReservationEntity>> getMyReservations() async {
    try {
      final response = await dioClient.get(
        '/v1/room-schedules/my',
        queryParams: {'type': 'sewa'},
      );

      final data = response.data['data'] as List? ?? [];

      return data.map((json) {
        final roomJson = json['room'] as Map<String, dynamic>? ?? {};
        final tenantJson = json['tenant'] as Map<String, dynamic>? ?? {};

        final rawStart = json['start_date']?.toString() ?? '';
        final rawEnd = json['end_date']?.toString() ?? '';

        return ReservationEntity(
          id: json['id'] as int,
          roomTitle: roomJson['title']?.toString() ?? '',
          roomNumber: roomJson['number']?.toString() ?? '',
          residentName: tenantJson['name']?.toString() ?? '',
          rentalType: 'monthly',
          status: json['status']?.toString() ?? '',
          paymentStatus: 'unknown',
          startDate: rawStart.length >= 10 ? rawStart.substring(0, 10) : rawStart,
          endDate: rawEnd.length >= 10 ? rawEnd.substring(0, 10) : rawEnd,
          paymentScheme: json['payment_scheme']?.toString(),
          dpAmount: (json['dp_amount'] as num?)?.toDouble(),
          dpPaidAt: json['dp_paid_at']?.toString(),
          dpRefundEligible: json['dp_refund_eligible'] as bool?,
        );
      }).toList();
    } catch (e) {
      rethrow;
    }
  }
}
