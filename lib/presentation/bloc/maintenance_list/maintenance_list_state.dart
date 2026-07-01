import 'package:equatable/equatable.dart';
import '../../../domain/entity/maintenance_request_entity.dart';
import '../../../domain/entity/pagination_meta.dart';

abstract class MaintenanceListState extends Equatable {
  const MaintenanceListState();

  @override
  List<Object?> get props => [];
}

class MaintenanceListInitial extends MaintenanceListState {}

class MaintenanceListLoading extends MaintenanceListState {}

class MaintenanceListLoaded extends MaintenanceListState {
  final List<MaintenanceRequestEntity> requests;
  final PaginationMeta? meta;

  const MaintenanceListLoaded(this.requests, {this.meta});

  @override
  List<Object?> get props => [requests, meta];
}

class MaintenanceListError extends MaintenanceListState {
  final String message;

  const MaintenanceListError(this.message);

  @override
  List<Object?> get props => [message];
}
