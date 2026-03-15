import 'package:equatable/equatable.dart';

abstract class FinanceDashboardEvent extends Equatable {
  const FinanceDashboardEvent();

  @override
  List<Object> get props => [];
}

class FetchDashboardData extends FinanceDashboardEvent {}
