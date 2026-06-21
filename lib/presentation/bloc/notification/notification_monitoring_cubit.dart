import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/domain/entity/notification/notification_log_entity.dart';
import 'package:frontend/domain/usecase/notification/get_notification_logs_usecase.dart';
import 'package:frontend/domain/usecase/notification/get_notification_recipients_usecase.dart';
import 'package:frontend/domain/usecase/notification/get_notification_summary_usecase.dart';
import 'package:frontend/domain/usecase/notification/resend_notification_usecase.dart';
import 'package:frontend/domain/usecase/notification/send_custom_notification_usecase.dart';

// ─── Status enum ─────────────────────────────────────────────────────────────

enum NotificationMonitoringStatus { initial, loading, loaded, failure }

// ─── State ────────────────────────────────────────────────────────────────────

class NotificationMonitoringState {
  final NotificationMonitoringStatus status;
  final NotificationSummaryEntity? summary;
  final List<NotificationLogItem> logs;
  final NotificationLogPagination? pagination;
  final String? errorMessage;
  final String? successMessage;
  // Active filters
  final String? statusFilter;
  final String? typeFilter;
  final String searchQuery;
  final int currentPage;
  // Async ops state
  final Set<int> resendingIds;
  final bool isSending;

  const NotificationMonitoringState({
    this.status = NotificationMonitoringStatus.initial,
    this.summary,
    this.logs = const [],
    this.pagination,
    this.errorMessage,
    this.successMessage,
    this.statusFilter,
    this.typeFilter,
    this.searchQuery = "",
    this.currentPage = 1,
    this.resendingIds = const {},
    this.isSending = false,
  });

  NotificationMonitoringState copyWith({
    NotificationMonitoringStatus? status,
    NotificationSummaryEntity? summary,
    List<NotificationLogItem>? logs,
    NotificationLogPagination? pagination,
    String? errorMessage,
    String? successMessage,
    String? statusFilter,
    bool clearStatusFilter = false,
    String? typeFilter,
    bool clearTypeFilter = false,
    String? searchQuery,
    int? currentPage,
    Set<int>? resendingIds,
    bool? isSending,
    bool clearMessages = false,
  }) {
    return NotificationMonitoringState(
      status: status ?? this.status,
      summary: summary ?? this.summary,
      logs: logs ?? this.logs,
      pagination: pagination ?? this.pagination,
      errorMessage: clearMessages ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearMessages ? null : (successMessage ?? this.successMessage),
      statusFilter: clearStatusFilter ? null : (statusFilter ?? this.statusFilter),
      typeFilter: clearTypeFilter ? null : (typeFilter ?? this.typeFilter),
      searchQuery: searchQuery ?? this.searchQuery,
      currentPage: currentPage ?? this.currentPage,
      resendingIds: resendingIds ?? this.resendingIds,
      isSending: isSending ?? this.isSending,
    );
  }
}

// ─── Cubit ────────────────────────────────────────────────────────────────────

class NotificationMonitoringCubit extends Cubit<NotificationMonitoringState> {
  final GetNotificationSummaryUseCase _getSummary;
  final GetNotificationLogsUseCase _getLogs;
  final ResendNotificationUseCase _resend;
  final SendCustomNotificationUseCase _sendCustom;
  final GetNotificationRecipientsUseCase _getRecipients;

  NotificationMonitoringCubit({
    required GetNotificationSummaryUseCase getSummary,
    required GetNotificationLogsUseCase getLogs,
    required ResendNotificationUseCase resend,
    required SendCustomNotificationUseCase sendCustom,
    required GetNotificationRecipientsUseCase getRecipients,
  })  : _getSummary = getSummary,
        _getLogs = getLogs,
        _resend = resend,
        _sendCustom = sendCustom,
        _getRecipients = getRecipients,
        super(const NotificationMonitoringState());

  Future<void> load() async {
    emit(state.copyWith(status: NotificationMonitoringStatus.loading, clearMessages: true));
    try {
      final summary = await _getSummary();
      final logsResponse = await _getLogs(
        page: state.currentPage,
        perPage: 15,
        status: state.statusFilter,
        type: state.typeFilter,
        search: state.searchQuery.isEmpty ? null : state.searchQuery,
      );
      emit(state.copyWith(
        status: NotificationMonitoringStatus.loaded,
        summary: summary,
        logs: logsResponse.logs,
        pagination: logsResponse.pagination,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: NotificationMonitoringStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> applyFilter({
    String? statusFilter,
    bool clearStatus = false,
    String? typeFilter,
    bool clearType = false,
    String? searchQuery,
  }) async {
    emit(state.copyWith(
      statusFilter: statusFilter,
      clearStatusFilter: clearStatus,
      typeFilter: typeFilter,
      clearTypeFilter: clearType,
      searchQuery: searchQuery ?? state.searchQuery,
      currentPage: 1,
    ));
    await load();
  }

  Future<void> nextPage() async {
    final pagination = state.pagination;
    if (pagination == null) return;
    if (state.currentPage >= pagination.lastPage) return;
    emit(state.copyWith(currentPage: state.currentPage + 1));
    await _fetchLogs();
  }

  Future<void> prevPage() async {
    if (state.currentPage <= 1) return;
    emit(state.copyWith(currentPage: state.currentPage - 1));
    await _fetchLogs();
  }

  Future<void> resend(int logId) async {
    final newResending = Set<int>.from(state.resendingIds)..add(logId);
    emit(state.copyWith(resendingIds: newResending, clearMessages: true));
    try {
      await _resend(logId);
      final done = Set<int>.from(state.resendingIds)..remove(logId);
      emit(state.copyWith(
        resendingIds: done,
        successMessage: "Notifikasi berhasil dikirim ulang.",
      ));
      await _fetchLogs();
    } catch (e) {
      final done = Set<int>.from(state.resendingIds)..remove(logId);
      emit(state.copyWith(
        resendingIds: done,
        errorMessage: "Gagal mengirim ulang: ${e.toString()}",
      ));
    }
  }

  Future<void> sendCustom({
    int? userId,
    String? targetPhone,
    required String message,
  }) async {
    emit(state.copyWith(isSending: true, clearMessages: true));
    try {
      await _sendCustom(userId: userId, targetPhone: targetPhone, message: message);
      emit(state.copyWith(
        isSending: false,
        successMessage: "Notifikasi berhasil dikirim.",
      ));
      await load();
    } catch (e) {
      emit(state.copyWith(
        isSending: false,
        errorMessage: "Gagal mengirim notifikasi: ${e.toString()}",
      ));
    }
  }

  Future<List<NotificationRecipientEntity>> loadRecipients() async {
    return await _getRecipients();
  }

  Future<void> _fetchLogs() async {
    try {
      final logsResponse = await _getLogs(
        page: state.currentPage,
        perPage: 15,
        status: state.statusFilter,
        type: state.typeFilter,
        search: state.searchQuery.isEmpty ? null : state.searchQuery,
      );
      emit(state.copyWith(
        logs: logsResponse.logs,
        pagination: logsResponse.pagination,
      ));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }
}
