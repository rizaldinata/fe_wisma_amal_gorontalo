import 'package:frontend/data/datasource/notification_datasource.dart';
import 'package:frontend/domain/entity/notification/notification_log_entity.dart';
import 'package:frontend/domain/repository/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationDatasource datasource;

  NotificationRepositoryImpl({required this.datasource});

  @override
  Future<NotificationLogResponse> getNotificationLogs({
    int page = 1,
    int perPage = 15,
  }) async {
    try {
      return await datasource.getNotificationLogs(
        page: page,
        perPage: perPage,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> markAllNotificationLogsRead() async {
    try {
      await datasource.markAllNotificationLogsRead();
    } catch (e) {
      rethrow;
    }
  }
}
