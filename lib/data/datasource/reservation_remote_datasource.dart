import 'package:frontend/core/services/network/dio_client.dart';
import 'package:frontend/domain/entity/reservation_entity.dart';

class ReservationRemoteDatasource {
  final DioClient dioClient;

  ReservationRemoteDatasource({required this.dioClient});

  Future<List<ReservationEntity>> getReservations() async {
    try {
      final response = await dioClient.get('/rentals');

      final data = response.data['data'] as List;

      return data.map((json) {
        return ReservationEntity(
          id: json['id'],

          roomTitle: json['room']['title'] ?? '',

          roomNumber: json['room']['number'] ?? '',

          residentName: json['resident']['user']['name'] ?? 'Unknown',

          rentalType: json['rental_type'] ?? '',

          status: json['status'] ?? '',

          startDate: json['start_date'].toString().substring(0, 10),

          endDate: json['end_date'].toString().substring(0, 10),
        );
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateReservationStatus({
    required int reservationId,
    required String status,
  }) async {
    try {
      await dioClient.patch(
        '/rentals/$reservationId/status',
        data: {'status': status},
      );
    } catch (e) {
      rethrow;
    }
  }
}
