import 'package:frontend/core/constant/endpoint_constant.dart';
import 'package:frontend/core/services/network/dio_client.dart';
import 'package:frontend/domain/entity/notification/notification_log_entity.dart';

class NotificationDatasource {
  final DioClient dioClient;

  NotificationDatasource({required this.dioClient});

  Future<NotificationLogResponse> getNotificationLogs({
    int page = 1,
    int perPage = 15,
    String? status,
    String? type,
    String? search,
  }) async {
    try {
      final params = <String, dynamic>{
        "page": page,
        "per_page": perPage,
      };
      if (status != null && status.isNotEmpty) params["status"] = status;
      if (type != null && type.isNotEmpty) params["type"] = type;
      if (search != null && search.isNotEmpty) params["search"] = search;

      final response = await dioClient.get(
        EndpointConstant.notificationLogsEndpoint,
        queryParams: params,
      );
      return NotificationLogResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> markAllNotificationLogsRead() async {
    try {
      await dioClient.patch(EndpointConstant.markAllNotificationLogsReadEndpoint);
    } catch (e) {
      rethrow;
    }
  }

  Future<NotificationSummaryEntity> getSummary() async {
    try {
      final response = await dioClient.get(EndpointConstant.notificationSummaryEndpoint);
      return NotificationSummaryEntity.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> resendNotification(int id) async {
    try {
      await dioClient.post(EndpointConstant.resendNotificationLogEndpoint(id));
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sendCustomNotification({
    int? userId,
    String? targetPhone,
    required String message,
  }) async {
    try {
      final body = <String, dynamic>{ "message_body": message };
      if (userId != null) {
        body["user_id"] = userId;
      } else {
        body["target_phone"] = targetPhone;
      }
      await dioClient.post(EndpointConstant.notificationSendEndpoint, data: body);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<NotificationRecipientEntity>> getRecipients() async {
    try {
      final response = await dioClient.get(EndpointConstant.notificationRecipientsEndpoint);
      final data = response.data;
      List<dynamic> items = [];
      if (data is Map<String, dynamic> && data["data"] is List) {
        items = data["data"] as List<dynamic>;
      } else if (data is List) {
        items = data;
      }
      return items
          .map((e) => NotificationRecipientEntity.fromJson(
              e is Map<String, dynamic> ? e : <String, dynamic>{}))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
