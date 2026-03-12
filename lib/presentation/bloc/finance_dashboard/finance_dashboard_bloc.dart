import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecase/finance/get_due_invoices_usecase.dart';
import '../../../domain/usecase/finance/get_pending_payments_usecase.dart';
import '../../../domain/entity/finance/invoice_entity.dart';
import '../../../domain/entity/finance/payment_entity.dart';
import 'finance_dashboard_event.dart';
import 'finance_dashboard_state.dart';

class FinanceDashboardBloc
    extends Bloc<FinanceDashboardEvent, FinanceDashboardState> {
  final GetDueInvoicesUseCase _getDueInvoicesUseCase;
  final GetPendingPaymentsUseCase _getPendingPaymentsUseCase;

  FinanceDashboardBloc(
    this._getDueInvoicesUseCase,
    this._getPendingPaymentsUseCase,
  ) : super(FinanceDashboardInitial()) {
    on<FetchDashboardData>(_onFetchDashboardData);
  }

  Future<void> _onFetchDashboardData(
    FetchDashboardData event,
    Emitter<FinanceDashboardState> emit,
  ) async {
    emit(FinanceDashboardLoading());
    try {
      final results = await Future.wait([
        _getDueInvoicesUseCase.call(),
        _getPendingPaymentsUseCase.call(),
      ]);

      emit(
        FinanceDashboardLoaded(
          dueInvoices: results[0] as List<InvoiceEntity>,
          pendingPayments: results[1] as List<PaymentEntity>,
        ),
      );
    } catch (e) {
      emit(FinanceDashboardError(e.toString()));
    }
  }
}
