import 'package:frontend/domain/entity/notification/notification_log_entity.dart';
import 'package:frontend/domain/repository/notification_repository.dart';

class GetNotificationRecipientsUseCase {
  final NotificationRepository _repository;

  GetNotificationRecipientsUseCase(this._repository);

  Future<List<NotificationRecipientEntity>> call() {
    return _repository.getRecipients();
  }
}
