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
  // Kode metode Midtrans spesifik (qris, gopay, bca_va, dll) — null = Snap fallback
  final String? preferredPaymentType;

  const PayInvoiceEvent(
    this.invoiceId,
    this.paymentMethod, {
    this.paymentProofBytes,
    this.paymentProofName,
    this.preferredPaymentType,
  });

  @override
  List<Object?> get props => [invoiceId, paymentMethod, paymentProofBytes, paymentProofName, preferredPaymentType];
}

class FetchMyFines extends MemberFinanceEvent {}

class PayFinesEvent extends MemberFinanceEvent {
  final List<int> fineIds;
  final String paymentMethod;
  final Uint8List? paymentProofBytes;
  final String? paymentProofName;
  final String? preferredPaymentType;

  const PayFinesEvent(
    this.fineIds,
    this.paymentMethod, {
    this.paymentProofBytes,
    this.paymentProofName,
    this.preferredPaymentType,
  });

  @override
  List<Object?> get props => [fineIds, paymentMethod, paymentProofBytes, paymentProofName, preferredPaymentType];
}

class ExtendLeaseEvent extends MemberFinanceEvent {
  final int leaseId;
  final int duration;
  final String paymentMethod;
  final Uint8List? paymentProofBytes;
  final String? paymentProofName;
  final String? preferredPaymentType;

  const ExtendLeaseEvent(
    this.leaseId,
    this.duration,
    this.paymentMethod, {
    this.paymentProofBytes,
    this.paymentProofName,
    this.preferredPaymentType,
  });

  @override
  List<Object?> get props => [leaseId, duration, paymentMethod, paymentProofBytes, paymentProofName, preferredPaymentType];
}
