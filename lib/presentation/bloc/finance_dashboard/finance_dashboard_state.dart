import 'package:equatable/equatable.dart';
import '../../../domain/entity/finance/invoice_entity.dart';
import '../../../domain/entity/finance/payment_entity.dart';
import '../../../domain/entity/finance/kpi_entity.dart';
import '../../../domain/entity/finance/revenue_entity.dart';

abstract class FinanceDashboardState extends Equatable {
  const FinanceDashboardState();

  @override
  List<Object?> get props => [];
}

class FinanceDashboardInitial extends FinanceDashboardState {}

class FinanceDashboardLoading extends FinanceDashboardState {}

class FinanceDashboardLoaded extends FinanceDashboardState {
  final List<InvoiceEntity> dueInvoices;
  final List<PaymentEntity> pendingPayments;
  final KpiEntity kpiSummary;
  final List<RevenueEntity> revenueChart;

  const FinanceDashboardLoaded({
    required this.dueInvoices,
    required this.pendingPayments,
    required this.kpiSummary,
    required this.revenueChart,
  });

  @override
  List<Object?> get props => [
    dueInvoices,
    pendingPayments,
    kpiSummary,
    revenueChart,
  ];
}

class FinanceDashboardError extends FinanceDashboardState {
  final String message;

  const FinanceDashboardError(this.message);

  @override
  List<Object?> get props => [message];
}
