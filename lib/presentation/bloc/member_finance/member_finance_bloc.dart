import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecase/finance/get_member_finance_summary_usecase.dart';
import '../../../domain/usecase/finance/get_member_invoices_usecase.dart';
import '../../../domain/usecase/finance/get_member_payments_usecase.dart';
import '../../../domain/usecase/finance/pay_invoice_usecase.dart';
import '../../../domain/usecase/finance/extend_lease_usecase.dart';
import '../../../domain/usecase/setting/get_public_settings_usecase.dart';
import 'member_finance_event.dart';
import 'member_finance_state.dart';

class MemberFinanceBloc extends Bloc<MemberFinanceEvent, MemberFinanceState> {
  final GetMemberFinanceSummaryUseCase _getSummary;
  final GetMemberInvoicesUseCase _getInvoices;
  final GetMemberPaymentsUseCase _getPayments;
  final PayInvoiceUseCase _payInvoice;
  final ExtendLeaseUseCase _extendLease;
  final GetPublicSettingsUseCase _getSettings;

  MemberFinanceBloc({
    required GetMemberFinanceSummaryUseCase getSummary,
    required GetMemberInvoicesUseCase getInvoices,
    required GetMemberPaymentsUseCase getPayments,
    required PayInvoiceUseCase payInvoice,
    required ExtendLeaseUseCase extendLease,
    required GetPublicSettingsUseCase getSettings,
  })  : _getSummary = getSummary,
        _getInvoices = getInvoices,
        _getPayments = getPayments,
        _payInvoice = payInvoice,
        _extendLease = extendLease,
        _getSettings = getSettings,
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
      final settings = await _getSettings.execute();
      final isMidtrans = settings.getBool('feature_payment_midtrans');

      emit(state.copyWith(
        status: MemberFinanceStatus.success,
        summary: summary,
        isMidtransEnabled: isMidtrans,
        bankName: settings.getString('bank_name') ?? '',
        bankAccount: settings.getString('bank_account') ?? '',
        bankHolder: settings.getString('bank_holder') ?? '',
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
      final payment = await _payInvoice.execute(
        event.invoiceId,
        event.paymentMethod,
        paymentProofBytes: event.paymentProofBytes,
        paymentProofName: event.paymentProofName,
        preferredPaymentType: event.preferredPaymentType,
      );
      emit(state.copyWith(
        status: MemberFinanceStatus.paymentSuccess,
        snapToken: payment.snapToken,
        paymentData: payment.paymentData,
      ));
      // Refresh invoices and summary if manual (to show pending status)
      if (event.paymentMethod == 'manual') {
        add(FetchMemberInvoices());
        add(FetchMemberPayments());
      }
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
      final payment = await _extendLease.execute(
        event.leaseId,
        event.duration,
        event.paymentMethod,
        paymentProofBytes: event.paymentProofBytes,
        paymentProofName: event.paymentProofName,
        preferredPaymentType: event.preferredPaymentType,
      );
      if (payment.snapToken != null && payment.snapToken!.isNotEmpty ||
          payment.paymentData != null) {
        emit(state.copyWith(
          status: MemberFinanceStatus.paymentSuccess,
          snapToken: payment.snapToken,
          paymentData: payment.paymentData,
          paymentInvoiceId: payment.invoiceId,
          paymentAmount: payment.amount,
        ));
      } else {
        emit(state.copyWith(status: MemberFinanceStatus.extensionSuccess));
        add(FetchMemberFinanceSummary());
      }
    } catch (e) {
      emit(state.copyWith(
        status: MemberFinanceStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}
