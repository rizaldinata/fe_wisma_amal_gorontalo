import 'package:equatable/equatable.dart';
import '../../../../domain/entity/finance/payment_entity.dart';

abstract class PaymentVerificationState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PaymentVerificationInitial extends PaymentVerificationState {}
class PaymentVerificationLoading extends PaymentVerificationState {}

class PaymentVerificationLoaded extends PaymentVerificationState {
  final List<PaymentEntity> pendingPayments;
  
  PaymentVerificationLoaded(this.pendingPayments);
  
  @override
  List<Object?> get props => [pendingPayments];
}

class PaymentVerificationActionSuccess extends PaymentVerificationState {
  final String message;
  
  PaymentVerificationActionSuccess(this.message);
  
  @override
  List<Object?> get props => [message];
}

class PaymentVerificationError extends PaymentVerificationState {
  final String message;
  
  PaymentVerificationError(this.message);
  
  @override
  List<Object?> get props => [message];
}