import 'package:equatable/equatable.dart';

abstract class MaintenanceListEvent extends Equatable {
  const MaintenanceListEvent();

  @override
  List<Object?> get props => [];
}

class FetchMyMaintenanceRequests extends MaintenanceListEvent {}

class FetchAllMaintenanceRequests extends MaintenanceListEvent {}
