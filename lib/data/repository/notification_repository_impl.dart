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
    String? status,
    String? type,
    String? search,
  }) async {
    try {
      return await datasource.getNotificationLogs(
        page: page,
        perPage: perPage,
        status: status,
        type: type,
        search: search,
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

  @override
  Future<NotificationSummaryEntity> getSummary() async {
    try {
      return await datasource.getSummary();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> resendNotification(int id) async {
    try {
      await datasource.resendNotification(id);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> sendCustomNotification({
    int? userId,
    String? targetPhone,
    required String message,
  }) async {
    try {
      await datasource.sendCustomNotification(
        userId: userId,
        targetPhone: targetPhone,
        message: message,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<NotificationRecipientEntity>> getRecipients() async {
    try {
      return await datasource.getRecipients();
    } catch (e) {
      rethrow;
    }
  }
}
