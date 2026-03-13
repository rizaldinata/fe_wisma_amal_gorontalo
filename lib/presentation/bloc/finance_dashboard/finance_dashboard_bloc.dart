import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecase/finance/get_due_invoices_usecase.dart';
import '../../../domain/usecase/finance/get_pending_payments_usecase.dart';
import '../../../domain/usecase/finance/get_kpi_summary_usecase.dart';
import '../../../domain/usecase/finance/get_revenue_chart_usecase.dart';
import '../../../domain/entity/finance/invoice_entity.dart';
import '../../../domain/entity/finance/payment_entity.dart';
import '../../../domain/entity/finance/kpi_entity.dart';
import '../../../domain/entity/finance/revenue_entity.dart';
import 'finance_dashboard_event.dart';
import 'finance_dashboard_state.dart';

class FinanceDashboardBloc
    extends Bloc<FinanceDashboardEvent, FinanceDashboardState> {
  final GetDueInvoicesUseCase _getDueInvoicesUseCase;
  final GetPendingPaymentsUseCase _getPendingPaymentsUseCase;
  final GetKpiSummaryUseCase _getKpiSummaryUseCase;
  final GetRevenueChartUseCase _getRevenueChartUseCase;

  FinanceDashboardBloc(
    this._getDueInvoicesUseCase,
    this._getPendingPaymentsUseCase,
    this._getKpiSummaryUseCase,
    this._getRevenueChartUseCase,
  ) : super(FinanceDashboardInitial()) {
    on<FetchDashboardData>(_onFetchDashboardData);
  }

  Future<void> _onFetchDashboardData(
    FetchDashboardData event,
    Emitter<FinanceDashboardState> emit,
  ) async {
    emit(FinanceDashboardLoading());
    try {
      // Kita panggil ke-4 API secara bersamaan agar sangat cepat!
      final results = await Future.wait([
        _getDueInvoicesUseCase.call(),
        _getPendingPaymentsUseCase.call(),
        _getKpiSummaryUseCase.call(),
        _getRevenueChartUseCase.call(),
      ]);

      emit(
        FinanceDashboardLoaded(
          dueInvoices: results[0] as List<InvoiceEntity>,
          pendingPayments: results[1] as List<PaymentEntity>,
          kpiSummary: results[2] as KpiEntity,
          revenueChart: results[3] as List<RevenueEntity>,
        ),
      );
    } catch (e) {
      emit(FinanceDashboardError(e.toString()));
    }
  }
}
