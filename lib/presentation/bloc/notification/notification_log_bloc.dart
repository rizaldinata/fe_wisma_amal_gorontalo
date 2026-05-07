import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/domain/entity/notification/notification_log_entity.dart';
import 'package:frontend/domain/usecase/notification/get_notification_logs_usecase.dart';

// ─── Events ───────────────────────────────────────────────────────────────────

abstract class NotificationLogEvent {}

class FetchNotificationLogs extends NotificationLogEvent {
  final int page;
  final int perPage;

  FetchNotificationLogs({this.page = 1, this.perPage = 15});
}

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

  NotificationLogBloc({required this.getNotificationLogsUseCase})
      : super(NotificationLogInitial()) {
    on<FetchNotificationLogs>(_onFetch);
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
}
