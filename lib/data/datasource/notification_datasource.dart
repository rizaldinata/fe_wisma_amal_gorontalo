import 'package:frontend/core/constant/endpoint_constant.dart';
import 'package:frontend/core/services/network/dio_client.dart';
import 'package:frontend/domain/entity/notification/notification_log_entity.dart';

class NotificationDatasource {
  final DioClient dioClient;

  NotificationDatasource({required this.dioClient});

  Future<NotificationLogResponse> getNotificationLogs({
    int page = 1,
    int perPage = 15,
  }) async {
    try {
      final response = await dioClient.get(
        EndpointConstant.notificationLogsEndpoint,
        queryParams: <String, dynamic>{
          'page': page,
          'per_page': perPage,
        },
      );
      return NotificationLogResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
