import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object> get props => [];
}

class FetchAdminDashboard extends DashboardEvent {}

class FetchResidentDashboard extends DashboardEvent {}
