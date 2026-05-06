import 'package:equatable/equatable.dart';

abstract class MemberFinanceEvent extends Equatable {
  const MemberFinanceEvent();

  @override
  List<Object?> get props => [];
}

class FetchMemberFinanceSummary extends MemberFinanceEvent {}

class FetchMemberInvoices extends MemberFinanceEvent {}

class FetchMemberPayments extends MemberFinanceEvent {}

class PayInvoiceEvent extends MemberFinanceEvent {
  final int invoiceId;
  final String paymentMethod;
  final String? paymentProofPath;
  const PayInvoiceEvent(this.invoiceId, this.paymentMethod, {this.paymentProofPath});

  @override
  List<Object?> get props => [invoiceId, paymentMethod, paymentProofPath];
}

class ExtendLeaseEvent extends MemberFinanceEvent {
  final int leaseId;
  final int duration;
  const ExtendLeaseEvent(this.leaseId, this.duration);

  @override
  List<Object?> get props => [leaseId, duration];
}
