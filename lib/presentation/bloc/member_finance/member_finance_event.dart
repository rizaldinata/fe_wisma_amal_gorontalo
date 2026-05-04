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
  const PayInvoiceEvent(this.invoiceId);

  @override
  List<Object?> get props => [invoiceId];
}

class ExtendLeaseEvent extends MemberFinanceEvent {
  final int leaseId;
  final int duration;
  const ExtendLeaseEvent(this.leaseId, this.duration);

  @override
  List<Object?> get props => [leaseId, duration];
}
