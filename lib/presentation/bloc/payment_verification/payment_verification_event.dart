import 'package:equatable/equatable.dart';

abstract class PaymentVerificationEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchPendingPayments extends PaymentVerificationEvent {}

class VerifyPaymentEvent extends PaymentVerificationEvent {
  final int paymentId;
  final bool isApproved;
  final String? adminNotes;

  VerifyPaymentEvent({
    required this.paymentId,
    required this.isApproved,
    this.adminNotes
  });

  @override
  List<Object?> get props => [paymentId, isApproved, adminNotes];
}

class RefundPaymentEvent extends PaymentVerificationEvent {
  final int paymentId;
  final String reason;

  RefundPaymentEvent({
    required this.paymentId,
    required this.reason,
  });

  @override
  List<Object?> get props => [paymentId, reason];
}