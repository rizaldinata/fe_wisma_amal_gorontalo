import 'package:equatable/equatable.dart';
import 'package:frontend/domain/entity/finance/invoice_entity.dart';

abstract class InvoiceState extends Equatable {
  const InvoiceState();
  
  @override
  List<Object> get props => [];
}

class InvoiceInitial extends InvoiceState {}

class InvoiceLoading extends InvoiceState {}

class InvoiceLoaded extends InvoiceState {
  final List<InvoiceEntity> invoices;

  const InvoiceLoaded(this.invoices);

  @override
  List<Object> get props => [invoices];
}

class InvoiceError extends InvoiceState {
  final String message;

  const InvoiceError(this.message);

  @override
  List<Object> get props => [message];
}
