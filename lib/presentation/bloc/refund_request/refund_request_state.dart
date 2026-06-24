import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:frontend/domain/entity/refund_request_entity.dart';

class RefundRequestState extends Equatable {
  final FormzSubmissionStatus loadStatus;
  final FormzSubmissionStatus actionStatus;
  final List<RefundRequestEntity> requests;
  final String? errorMessage;
  final String? activeFilter;

  const RefundRequestState({
    this.loadStatus = FormzSubmissionStatus.initial,
    this.actionStatus = FormzSubmissionStatus.initial,
    this.requests = const [],
    this.errorMessage,
    this.activeFilter,
  });

  RefundRequestState copyWith({
    FormzSubmissionStatus? loadStatus,
    FormzSubmissionStatus? actionStatus,
    List<RefundRequestEntity>? requests,
    String? errorMessage,
    String? activeFilter,
    bool clearError = false,
  }) {
    return RefundRequestState(
      loadStatus: loadStatus ?? this.loadStatus,
      actionStatus: actionStatus ?? this.actionStatus,
      requests: requests ?? this.requests,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      activeFilter: activeFilter ?? this.activeFilter,
    );
  }

  @override
  List<Object?> get props =>
      [loadStatus, actionStatus, requests, errorMessage, activeFilter];
}
