import 'package:equatable/equatable.dart';
import '../../../domain/entity/finance/invoice_entity.dart';
import '../../../domain/entity/finance/payment_entity.dart';
import '../../../domain/entity/finance/member_finance_summary_entity.dart';

enum MemberFinanceStatus { initial, loading, success, failure, paymentSuccess, extensionSuccess }

class MemberFinanceState extends Equatable {
  final MemberFinanceStatus status;
  final MemberFinanceSummaryEntity? summary;
  final List<InvoiceEntity> invoices;
  final List<PaymentEntity> payments;
  final String? errorMessage;
  final String? snapToken;
  final Map<String, dynamic>? paymentData;
  final bool isMidtransEnabled;

  const MemberFinanceState({
    this.status = MemberFinanceStatus.initial,
    this.summary,
    this.invoices = const [],
    this.payments = const [],
    this.errorMessage,
    this.snapToken,
    this.paymentData,
    this.isMidtransEnabled = true,
  });

  MemberFinanceState copyWith({
    MemberFinanceStatus? status,
    MemberFinanceSummaryEntity? summary,
    List<InvoiceEntity>? invoices,
    List<PaymentEntity>? payments,
    String? errorMessage,
    String? snapToken,
    Map<String, dynamic>? paymentData,
    bool? isMidtransEnabled,
  }) {
    return MemberFinanceState(
      status: status ?? this.status,
      summary: summary ?? this.summary,
      invoices: invoices ?? this.invoices,
      payments: payments ?? this.payments,
      errorMessage: errorMessage ?? this.errorMessage,
      snapToken: snapToken ?? this.snapToken,
      paymentData: paymentData ?? this.paymentData,
      isMidtransEnabled: isMidtransEnabled ?? this.isMidtransEnabled,
    );
  }

  @override
  List<Object?> get props => [status, summary, invoices, payments, errorMessage, snapToken, paymentData, isMidtransEnabled];
}
