import 'package:frontend/domain/entity/notification/notification_log_entity.dart';
import 'package:frontend/domain/repository/notification_repository.dart';

class GetNotificationSummaryUseCase {
  final NotificationRepository _repository;

  GetNotificationSummaryUseCase(this._repository);

  Future<NotificationSummaryEntity> call() {
    return _repository.getSummary();
  }
}
