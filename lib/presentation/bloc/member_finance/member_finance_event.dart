import 'dart:typed_data';
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
  final Uint8List? paymentProofBytes;
  final String? paymentProofName;

  const PayInvoiceEvent(
    this.invoiceId,
    this.paymentMethod, {
    this.paymentProofBytes,
    this.paymentProofName,
  });

  @override
  List<Object?> get props => [invoiceId, paymentMethod, paymentProofBytes, paymentProofName];
}

class ExtendLeaseEvent extends MemberFinanceEvent {
  final int leaseId;
  final int duration;
  const ExtendLeaseEvent(this.leaseId, this.duration);

  @override
  List<Object?> get props => [leaseId, duration];
}
