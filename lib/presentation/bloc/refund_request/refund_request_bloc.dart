import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:frontend/data/datasource/refund_request_datasource.dart';
import 'package:frontend/domain/usecase/refund_request/get_refund_requests_usecase.dart';
import 'package:frontend/domain/usecase/refund_request/tolak_refund_usecase.dart';
import 'refund_request_event.dart';
import 'refund_request_state.dart';

class RefundRequestBloc extends Bloc<RefundRequestEvent, RefundRequestState> {
  final GetRefundRequestsUseCase getRefundRequestsUseCase;
  final TolakRefundUseCase tolakRefundUseCase;
  final RefundRequestDatasource datasource;

  RefundRequestBloc({
    required this.getRefundRequestsUseCase,
    required this.tolakRefundUseCase,
    required this.datasource,
  }) : super(const RefundRequestState()) {
    on<LoadRefundRequestsEvent>(_onLoad);
    on<ProsesRefundEvent>(_onProses);
    on<TolakRefundEvent>(_onTolak);
  }

  Future<void> _onLoad(
    LoadRefundRequestsEvent event,
    Emitter<RefundRequestState> emit,
  ) async {
    emit(state.copyWith(
      loadStatus: FormzSubmissionStatus.inProgress,
      activeFilter: event.status,
    ));
    try {
      final requests =
          await getRefundRequestsUseCase.execute(status: event.status);
      emit(state.copyWith(
        loadStatus: FormzSubmissionStatus.success,
        requests: requests,
      ));
    } catch (e) {
      emit(state.copyWith(
        loadStatus: FormzSubmissionStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onProses(
    ProsesRefundEvent event,
    Emitter<RefundRequestState> emit,
  ) async {
    emit(state.copyWith(actionStatus: FormzSubmissionStatus.inProgress));
    try {
      await datasource.prosesRefund(
        id: event.id,
        proof: event.proof,
        adminFee: event.adminFee,
        adminNotes: event.adminNotes,
      );
      emit(state.copyWith(
        actionStatus: FormzSubmissionStatus.success,
        clearError: true,
      ));
      add(LoadRefundRequestsEvent(status: state.activeFilter));
    } catch (e) {
      emit(state.copyWith(
        actionStatus: FormzSubmissionStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onTolak(
    TolakRefundEvent event,
    Emitter<RefundRequestState> emit,
  ) async {
    emit(state.copyWith(actionStatus: FormzSubmissionStatus.inProgress));
    try {
      await tolakRefundUseCase.execute(
        id: event.id,
        adminNotes: event.adminNotes,
      );
      emit(state.copyWith(
        actionStatus: FormzSubmissionStatus.success,
        clearError: true,
      ));
      add(LoadRefundRequestsEvent(status: state.activeFilter));
    } catch (e) {
      emit(state.copyWith(
        actionStatus: FormzSubmissionStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}
