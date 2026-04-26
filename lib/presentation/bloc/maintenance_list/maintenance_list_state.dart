import 'package:equatable/equatable.dart';
import '../../../domain/entity/maintenance_request_entity.dart';

abstract class MaintenanceListState extends Equatable {
  const MaintenanceListState();

  @override
  List<Object?> get props => [];
}

class MaintenanceListInitial extends MaintenanceListState {}

class MaintenanceListLoading extends MaintenanceListState {}

class MaintenanceListLoaded extends MaintenanceListState {
  final List<MaintenanceRequestEntity> requests;

  const MaintenanceListLoaded(this.requests);

  @override
  List<Object?> get props => [requests];
}

class MaintenanceListError extends MaintenanceListState {
  final String message;

  const MaintenanceListError(this.message);

  @override
  List<Object?> get props => [message];
}
