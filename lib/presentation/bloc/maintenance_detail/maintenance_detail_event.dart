import 'package:equatable/equatable.dart';

abstract class MaintenanceDetailEvent extends Equatable {
  const MaintenanceDetailEvent();

  @override
  List<Object?> get props => [];
}

class FetchMaintenanceDetail extends MaintenanceDetailEvent {
  final int id;

  const FetchMaintenanceDetail(this.id);

  @override
  List<Object?> get props => [id];
}
