import 'package:frontend/domain/entity/notification/notification_log_entity.dart';

abstract class NotificationRepository {
  Future<NotificationLogResponse> getNotificationLogs({
    int page = 1,
    int perPage = 15,
    String? status,
    String? type,
    String? search,
  });

  Future<void> markAllNotificationLogsRead();

  Future<NotificationSummaryEntity> getSummary();

  Future<void> resendNotification(int id);

  Future<void> sendCustomNotification({
    int? userId,
    String? targetPhone,
    required String message,
  });

  Future<List<NotificationRecipientEntity>> getRecipients();
}
