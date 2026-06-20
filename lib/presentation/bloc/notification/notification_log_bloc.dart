import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/domain/entity/notification/notification_log_entity.dart';
import 'package:frontend/domain/usecase/notification/get_notification_logs_usecase.dart';
import 'package:frontend/domain/usecase/notification/mark_all_notification_logs_read_usecase.dart';

// ─── Events ───────────────────────────────────────────────────────────────────

abstract class NotificationLogEvent {}

class FetchNotificationLogs extends NotificationLogEvent {
  final int page;
  final int perPage;

  FetchNotificationLogs({this.page = 1, this.perPage = 15});
}

class MarkAllNotificationLogsRead extends NotificationLogEvent {}

// ─── States ───────────────────────────────────────────────────────────────────

abstract class NotificationLogState {}

class NotificationLogInitial extends NotificationLogState {}

class NotificationLogLoading extends NotificationLogState {}

class NotificationLogLoaded extends NotificationLogState {
  final NotificationLogResponse data;
  NotificationLogLoaded(this.data);
}

class NotificationLogError extends NotificationLogState {
  final String message;
  NotificationLogError(this.message);
}

// ─── Bloc ─────────────────────────────────────────────────────────────────────

class NotificationLogBloc extends Bloc<NotificationLogEvent, NotificationLogState> {
  final GetNotificationLogsUseCase getNotificationLogsUseCase;
  final MarkAllNotificationLogsReadUseCase markAllNotificationLogsReadUseCase;

  NotificationLogBloc({
    required this.getNotificationLogsUseCase,
    required this.markAllNotificationLogsReadUseCase,
  }) : super(NotificationLogInitial()) {
    on<FetchNotificationLogs>(_onFetch);
    on<MarkAllNotificationLogsRead>(_onMarkAllRead);
  }

  Future<void> _onFetch(
    FetchNotificationLogs event,
    Emitter<NotificationLogState> emit,
  ) async {
    emit(NotificationLogLoading());
    try {
      final data = await getNotificationLogsUseCase(
        page: event.page,
        perPage: event.perPage,
      );
      emit(NotificationLogLoaded(data));
    } catch (e) {
      emit(NotificationLogError(e.toString()));
    }
  }

  Future<void> _onMarkAllRead(
    MarkAllNotificationLogsRead event,
    Emitter<NotificationLogState> emit,
  ) async {
    try {
      await markAllNotificationLogsReadUseCase();
      // Setelah mark-all-read, refresh log agar is_read terupdate di UI
      final data = await getNotificationLogsUseCase();
      emit(NotificationLogLoaded(data));
    } catch (_) {
      // Gagal mark as read tidak perlu menampilkan error ke user
    }
  }
}
