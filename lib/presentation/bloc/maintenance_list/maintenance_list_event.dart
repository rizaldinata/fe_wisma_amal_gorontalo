import 'package:equatable/equatable.dart';

abstract class MaintenanceListEvent extends Equatable {
  const MaintenanceListEvent();

  @override
  List<Object?> get props => [];
}

class FetchMyMaintenanceRequests extends MaintenanceListEvent {}

class FetchAllMaintenanceRequests extends MaintenanceListEvent {
  final int page;
  final int perPage;

  const FetchAllMaintenanceRequests({this.page = 1, this.perPage = 10});

  @override
  List<Object?> get props => [page, perPage];
}
