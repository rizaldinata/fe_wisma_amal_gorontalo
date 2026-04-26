import 'package:equatable/equatable.dart';
import '../../../domain/entity/maintenance_request_entity.dart';

abstract class MaintenanceDetailState extends Equatable {
  const MaintenanceDetailState();

  @override
  List<Object?> get props => [];
}

class MaintenanceDetailInitial extends MaintenanceDetailState {}

class MaintenanceDetailLoading extends MaintenanceDetailState {}

class MaintenanceDetailLoaded extends MaintenanceDetailState {
  final MaintenanceRequestEntity request;

  const MaintenanceDetailLoaded(this.request);

  @override
  List<Object?> get props => [request];
}

class MaintenanceDetailError extends MaintenanceDetailState {
  final String message;

  const MaintenanceDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
