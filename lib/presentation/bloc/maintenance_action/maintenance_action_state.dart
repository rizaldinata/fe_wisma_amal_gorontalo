import 'package:equatable/equatable.dart';

abstract class MaintenanceActionState extends Equatable {
  const MaintenanceActionState();

  @override
  List<Object?> get props => [];
}

class MaintenanceActionInitial extends MaintenanceActionState {}

class MaintenanceActionSubmitting extends MaintenanceActionState {}

class MaintenanceActionSuccess extends MaintenanceActionState {
  final String message;

  const MaintenanceActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class MaintenanceActionFailure extends MaintenanceActionState {
  final String message;

  const MaintenanceActionFailure(this.message);

  @override
  List<Object?> get props => [message];
}
