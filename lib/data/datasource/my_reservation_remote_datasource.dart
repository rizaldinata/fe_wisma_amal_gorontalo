import 'package:frontend/core/services/network/dio_client.dart';
import 'package:frontend/domain/entity/reservation_entity.dart';

class MyReservationRemoteDatasource {
  final DioClient dioClient;

  MyReservationRemoteDatasource({
    required this.dioClient,
  });

  Future<List<ReservationEntity>> getMyReservations() async {
    try {
      final response = await dioClient.get('/rentals/my');

      final data = response.data['data'] as List;

      return data.map((json) {
        return ReservationEntity(
          id: json['id'],

          roomTitle: json['room']['title'] ?? '',

          roomNumber: json['room']['number'] ?? '',

          residentName: '',

          rentalType: json['rental_type'] ?? '',

          status: json['status'] ?? '',

          paymentStatus: json['payment_status'] ?? 'unpaid',

          startDate: json['start_date']
              .toString()
              .substring(0, 10),

          endDate: json['end_date']
              .toString()
              .substring(0, 10),
        );
      }).toList();
    } catch (e) {
      rethrow;
    }
  }
}