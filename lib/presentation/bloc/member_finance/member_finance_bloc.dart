import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecase/finance/get_member_finance_summary_usecase.dart';
import '../../../domain/usecase/finance/get_member_invoices_usecase.dart';
import '../../../domain/usecase/finance/get_member_payments_usecase.dart';
import '../../../domain/usecase/finance/get_my_fines_usecase.dart';
import '../../../domain/usecase/finance/pay_fines_usecase.dart';
import '../../../domain/usecase/finance/pay_invoice_usecase.dart';
import '../../../domain/usecase/finance/extend_lease_usecase.dart';
import '../../../domain/usecase/setting/get_public_settings_usecase.dart';
import '../../../domain/usecase/setting/get_public_bank_accounts_usecase.dart';
import 'member_finance_event.dart';
import 'member_finance_state.dart';

class MemberFinanceBloc extends Bloc<MemberFinanceEvent, MemberFinanceState> {
  final GetMemberFinanceSummaryUseCase _getSummary;
  final GetMemberInvoicesUseCase _getInvoices;
  final GetMemberPaymentsUseCase _getPayments;
  final GetMyFinesUseCase _getMyFines;
  final PayFinesUseCase _payFines;
  final PayInvoiceUseCase _payInvoice;
  final ExtendLeaseUseCase _extendLease;
  final GetPublicSettingsUseCase _getSettings;
  final GetPublicBankAccountsUseCase _getBankAccounts;

  MemberFinanceBloc({
    required GetMemberFinanceSummaryUseCase getSummary,
    required GetMemberInvoicesUseCase getInvoices,
    required GetMemberPaymentsUseCase getPayments,
    required GetMyFinesUseCase getMyFines,
    required PayFinesUseCase payFines,
    required PayInvoiceUseCase payInvoice,
    required ExtendLeaseUseCase extendLease,
    required GetPublicSettingsUseCase getSettings,
    required GetPublicBankAccountsUseCase getBankAccounts,
  })  : _getSummary = getSummary,
        _getInvoices = getInvoices,
        _getPayments = getPayments,
        _getMyFines = getMyFines,
        _payFines = payFines,
        _payInvoice = payInvoice,
        _extendLease = extendLease,
        _getSettings = getSettings,
        _getBankAccounts = getBankAccounts,
        super(const MemberFinanceState()) {
    on<FetchMemberFinanceSummary>(_onFetchSummary);
    on<FetchMemberInvoices>(_onFetchInvoices);
    on<FetchMemberPayments>(_onFetchPayments);
    on<FetchMyFines>(_onFetchMyFines);
    on<PayFinesEvent>(_onPayFines);
    on<PayInvoiceEvent>(_onPayInvoice);
    on<ExtendLeaseEvent>(_onExtendLease);
  }

  String _extractErrorMessage(Object e, String fallback) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map) {
        final errors = data['errors'] as Map<String, dynamic>?;
        if (errors != null && errors.isNotEmpty) {
          final first = errors.values.first;
          if (first is List && first.isNotEmpty) return first.first.toString();
        }
        return data['message']?.toString() ?? fallback;
      }
    }
    return fallback;
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
      final bankAccounts = await _getBankAccounts.execute();

      emit(state.copyWith(
        status: MemberFinanceStatus.success,
        summary: summary,
        isMidtransEnabled: isMidtrans,
        bankAccounts: bankAccounts,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: MemberFinanceStatus.failure,
        errorMessage: _extractErrorMessage(e, 'Gagal memuat data keuangan.'),
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
        errorMessage: _extractErrorMessage(e, 'Gagal memuat daftar tagihan.'),
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
        errorMessage: _extractErrorMessage(e, 'Gagal memuat riwayat pembayaran.'),
      ));
    }
  }

  Future<void> _onFetchMyFines(
    FetchMyFines event,
    Emitter<MemberFinanceState> emit,
  ) async {
    emit(state.copyWith(status: MemberFinanceStatus.loading));
    try {
      final fines = await _getMyFines.execute();
      emit(state.copyWith(status: MemberFinanceStatus.success, myFines: fines));
    } catch (e) {
      emit(state.copyWith(
        status: MemberFinanceStatus.failure,
        errorMessage: _extractErrorMessage(e, 'Gagal memuat daftar denda.'),
      ));
    }
  }

  Future<void> _onPayFines(
    PayFinesEvent event,
    Emitter<MemberFinanceState> emit,
  ) async {
    emit(state.copyWith(status: MemberFinanceStatus.loading));
    try {
      final payment = await _payFines.execute(
        event.fineIds,
        event.paymentMethod,
        paymentProofBytes: event.paymentProofBytes,
        paymentProofName: event.paymentProofName,
        preferredPaymentType: event.preferredPaymentType,
      );
      emit(state.copyWith(
        status: MemberFinanceStatus.finePaymentSuccess,
        snapToken: payment.snapToken,
        paymentData: payment.paymentData,
        paymentGrossAmount: payment.grossAmount,
        paymentMidtransFee: payment.midtransFee,
        paymentFeeBearer: payment.feeBearer,
      ));
      if (event.paymentMethod == 'manual') {
        add(FetchMyFines());
      }
    } catch (e) {
      emit(state.copyWith(
        status: MemberFinanceStatus.failure,
        errorMessage: _extractErrorMessage(e, 'Gagal memproses pembayaran denda.'),
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
        paymentGrossAmount: payment.grossAmount,
        paymentMidtransFee: payment.midtransFee,
        paymentFeeBearer: payment.feeBearer,
      ));
      if (event.paymentMethod == 'manual') {
        add(FetchMemberInvoices());
        add(FetchMemberPayments());
      }
    } catch (e) {
      emit(state.copyWith(
        status: MemberFinanceStatus.failure,
        errorMessage: _extractErrorMessage(e, 'Gagal memproses pembayaran.'),
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
          paymentGrossAmount: payment.grossAmount,
          paymentMidtransFee: payment.midtransFee,
          paymentFeeBearer: payment.feeBearer,
        ));
      } else {
        emit(state.copyWith(status: MemberFinanceStatus.extensionSuccess));
        add(FetchMemberFinanceSummary());
      }
    } catch (e) {
      emit(state.copyWith(
        status: MemberFinanceStatus.failure,
        errorMessage: _extractErrorMessage(e, 'Gagal memproses perpanjangan sewa.'),
      ));
    }
  }
}
