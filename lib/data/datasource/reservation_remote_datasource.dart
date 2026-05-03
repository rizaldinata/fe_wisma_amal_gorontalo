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

          residentName: json['resident']['user']['name'] ?? 'unpaid',

          rentalType: json['rental_type'] ?? '',

          status: json['status'] ?? '',

          paymentStatus: json['payment_status'] ?? 'unpaid',

          startDate: json['start_date'].toString().substring(0, 10),

          endDate: json['end_date'].toString().substring(0, 10),
        );
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<ReservationEntity> createReservation({
    required int roomId,
    required String startDate,
    required int duration,
    required String rentalType,
  }) async {
    try {
      final response = await dioClient.post(
        '/rentals',
        data: {
          'room_id': roomId,
          'start_date': startDate,
          'duration': duration,
          'rental_type': rentalType,
        },
      );

      final json = response.data['data'];

      return ReservationEntity(
        id: json['id'],
        roomTitle: json['room']['title'] ?? '',
        roomNumber: json['room']['number'] ?? '',
        residentName: json['resident']['user']['name'] ?? '',
        rentalType: json['rental_type'] ?? '',
        status: json['status'] ?? '',
        paymentStatus: json['payment_status'] ?? 'unpaid',
        startDate: json['start_date'].toString().substring(0, 10),
        endDate: json['end_date'].toString().substring(0, 10),
      );
    } catch (e) {
      rethrow;
    }
  }
}
