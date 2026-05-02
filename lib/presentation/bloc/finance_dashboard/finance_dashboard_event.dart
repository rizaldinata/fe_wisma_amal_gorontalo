import 'package:equatable/equatable.dart';

abstract class FinanceDashboardEvent extends Equatable {
  const FinanceDashboardEvent();

  @override
  List<Object> get props => [];
}

class FetchDashboardData extends FinanceDashboardEvent {
  final int? month;
  final int? year;

  const FetchDashboardData({this.month, this.year});

  @override
  List<Object> get props => [
        if (month != null) month!,
        if (year != null) year!,
      ];
}
