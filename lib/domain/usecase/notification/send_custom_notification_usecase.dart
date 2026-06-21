import 'package:frontend/domain/repository/notification_repository.dart';

class SendCustomNotificationUseCase {
  final NotificationRepository _repository;

  SendCustomNotificationUseCase(this._repository);

  Future<void> call({
    int? userId,
    String? targetPhone,
    required String message,
  }) {
    return _repository.sendCustomNotification(
      userId: userId,
      targetPhone: targetPhone,
      message: message,
    );
  }
}
