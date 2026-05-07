import 'package:frontend/domain/entity/notification/notification_log_entity.dart';
import 'package:frontend/domain/repository/notification_repository.dart';

class GetNotificationLogsUseCase {
  final NotificationRepository _repository;

  GetNotificationLogsUseCase(this._repository);

  Future<NotificationLogResponse> call({
    int page = 1,
    int perPage = 15,
  }) {
    return _repository.getNotificationLogs(page: page, perPage: perPage);
  }
}
