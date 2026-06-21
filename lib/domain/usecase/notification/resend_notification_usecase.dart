import 'package:frontend/domain/repository/notification_repository.dart';

class ResendNotificationUseCase {
  final NotificationRepository _repository;

  ResendNotificationUseCase(this._repository);

  Future<void> call(int id) {
    return _repository.resendNotification(id);
  }
}
