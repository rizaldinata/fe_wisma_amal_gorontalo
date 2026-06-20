import 'package:frontend/domain/repository/notification_repository.dart';

class MarkAllNotificationLogsReadUseCase {
  final NotificationRepository repository;

  MarkAllNotificationLogsReadUseCase({required this.repository});

  Future<void> call() async {
    return await repository.markAllNotificationLogsRead();
  }
}
