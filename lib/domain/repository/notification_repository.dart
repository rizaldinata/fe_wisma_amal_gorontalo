import 'package:frontend/domain/entity/notification/notification_log_entity.dart';

abstract class NotificationRepository {
  Future<NotificationLogResponse> getNotificationLogs({
    int page = 1,
    int perPage = 15,
  });
}
