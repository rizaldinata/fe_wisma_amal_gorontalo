import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecase/finance/get_member_finance_summary_usecase.dart';
import '../../../domain/usecase/finance/get_member_invoices_usecase.dart';
import '../../../domain/usecase/finance/get_member_payments_usecase.dart';
import '../../../domain/usecase/finance/pay_invoice_usecase.dart';
import '../../../domain/usecase/finance/extend_lease_usecase.dart';
import 'member_finance_event.dart';
import 'member_finance_state.dart';

class MemberFinanceBloc extends Bloc<MemberFinanceEvent, MemberFinanceState> {
  final GetMemberFinanceSummaryUseCase _getSummary;
  final GetMemberInvoicesUseCase _getInvoices;
  final GetMemberPaymentsUseCase _getPayments;
  final PayInvoiceUseCase _payInvoice;
  final ExtendLeaseUseCase _extendLease;

  MemberFinanceBloc({
    required GetMemberFinanceSummaryUseCase getSummary,
    required GetMemberInvoicesUseCase getInvoices,
    required GetMemberPaymentsUseCase getPayments,
    required PayInvoiceUseCase payInvoice,
    required ExtendLeaseUseCase extendLease,
  })  : _getSummary = getSummary,
        _getInvoices = getInvoices,
        _getPayments = getPayments,
        _payInvoice = payInvoice,
        _extendLease = extendLease,
        super(const MemberFinanceState()) {
    on<FetchMemberFinanceSummary>(_onFetchSummary);
    on<FetchMemberInvoices>(_onFetchInvoices);
    on<FetchMemberPayments>(_onFetchPayments);
    on<PayInvoiceEvent>(_onPayInvoice);
    on<ExtendLeaseEvent>(_onExtendLease);
  }

  Future<void> _onFetchSummary(
    FetchMemberFinanceSummary event,
    Emitter<MemberFinanceState> emit,
  ) async {
    emit(state.copyWith(status: MemberFinanceStatus.loading));
    try {
      final summary = await _getSummary.execute();
      emit(state.copyWith(
        status: MemberFinanceStatus.success,
        summary: summary,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: MemberFinanceStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onFetchInvoices(
    FetchMemberInvoices event,
    Emitter<MemberFinanceState> emit,
  ) async {
    emit(state.copyWith(status: MemberFinanceStatus.loading));
    try {
      final invoices = await _getInvoices.execute();
      emit(state.copyWith(
        status: MemberFinanceStatus.success,
        invoices: invoices,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: MemberFinanceStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onFetchPayments(
    FetchMemberPayments event,
    Emitter<MemberFinanceState> emit,
  ) async {
    emit(state.copyWith(status: MemberFinanceStatus.loading));
    try {
      final payments = await _getPayments.execute();
      emit(state.copyWith(
        status: MemberFinanceStatus.success,
        payments: payments,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: MemberFinanceStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onPayInvoice(
    PayInvoiceEvent event,
    Emitter<MemberFinanceState> emit,
  ) async {
    emit(state.copyWith(status: MemberFinanceStatus.loading));
    try {
      final payment = await _payInvoice.execute(event.invoiceId);
      emit(state.copyWith(
        status: MemberFinanceStatus.paymentSuccess,
        snapToken: payment.snapToken,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: MemberFinanceStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onExtendLease(
    ExtendLeaseEvent event,
    Emitter<MemberFinanceState> emit,
  ) async {
    emit(state.copyWith(status: MemberFinanceStatus.loading));
    try {
      await _extendLease.execute(event.leaseId, event.duration);
      emit(state.copyWith(status: MemberFinanceStatus.extensionSuccess));
      // Refresh summary
      add(FetchMemberFinanceSummary());
    } catch (e) {
      emit(state.copyWith(
        status: MemberFinanceStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}
