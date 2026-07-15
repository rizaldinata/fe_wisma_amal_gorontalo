import 'package:equatable/equatable.dart';
import '../../../domain/entity/finance/fine_entity.dart';
import '../../../domain/entity/finance/invoice_entity.dart';
import '../../../domain/entity/finance/payment_entity.dart';
import '../../../domain/entity/finance/member_finance_summary_entity.dart';
import '../../../domain/entity/setting/bank_account_entity.dart';

enum MemberFinanceStatus { initial, loading, success, failure, paymentSuccess, extensionSuccess, finePaymentSuccess }

class MemberFinanceState extends Equatable {
  final MemberFinanceStatus status;
  final MemberFinanceSummaryEntity? summary;
  final List<InvoiceEntity> invoices;
  final List<PaymentEntity> payments;
  final List<FineEntity> myFines;
  final String? errorMessage;
  final String? snapToken;
  final Map<String, dynamic>? paymentData;
  final bool isMidtransEnabled;
  final List<BankAccountEntity> bankAccounts;
  final int? paymentInvoiceId;
  final double? paymentAmount;
  final double? paymentGrossAmount;
  final int? paymentMidtransFee;
  final String? paymentFeeBearer;

  const MemberFinanceState({
    this.status = MemberFinanceStatus.initial,
    this.summary,
    this.invoices = const [],
    this.payments = const [],
    this.myFines = const [],
    this.errorMessage,
    this.snapToken,
    this.paymentData,
    this.isMidtransEnabled = true,
    this.bankAccounts = const [],
    this.paymentInvoiceId,
    this.paymentAmount,
    this.paymentGrossAmount,
    this.paymentMidtransFee,
    this.paymentFeeBearer,
  });

  MemberFinanceState copyWith({
    MemberFinanceStatus? status,
    MemberFinanceSummaryEntity? summary,
    List<InvoiceEntity>? invoices,
    List<PaymentEntity>? payments,
    List<FineEntity>? myFines,
    String? errorMessage,
    String? snapToken,
    Map<String, dynamic>? paymentData,
    bool? isMidtransEnabled,
    List<BankAccountEntity>? bankAccounts,
    int? paymentInvoiceId,
    double? paymentAmount,
    double? paymentGrossAmount,
    int? paymentMidtransFee,
    String? paymentFeeBearer,
  }) {
    return MemberFinanceState(
      status: status ?? this.status,
      summary: summary ?? this.summary,
      invoices: invoices ?? this.invoices,
      payments: payments ?? this.payments,
      myFines: myFines ?? this.myFines,
      errorMessage: errorMessage ?? this.errorMessage,
      snapToken: snapToken ?? this.snapToken,
      paymentData: paymentData ?? this.paymentData,
      isMidtransEnabled: isMidtransEnabled ?? this.isMidtransEnabled,
      bankAccounts: bankAccounts ?? this.bankAccounts,
      paymentInvoiceId: paymentInvoiceId ?? this.paymentInvoiceId,
      paymentAmount: paymentAmount ?? this.paymentAmount,
      paymentGrossAmount: paymentGrossAmount ?? this.paymentGrossAmount,
      paymentMidtransFee: paymentMidtransFee ?? this.paymentMidtransFee,
      paymentFeeBearer: paymentFeeBearer ?? this.paymentFeeBearer,
    );
  }

  @override
  List<Object?> get props => [
        status, summary, invoices, payments, myFines, errorMessage, snapToken,
        paymentData, isMidtransEnabled, bankAccounts, paymentInvoiceId,
        paymentAmount, paymentGrossAmount, paymentMidtransFee, paymentFeeBearer,
      ];
}
