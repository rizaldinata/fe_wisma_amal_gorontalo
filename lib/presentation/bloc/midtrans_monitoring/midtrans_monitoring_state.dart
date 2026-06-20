part of 'midtrans_monitoring_cubit.dart';

abstract class MidtransMonitoringState extends Equatable {
  const MidtransMonitoringState();
  @override
  List<Object?> get props => [];
}

class MidtransMonitoringInitial extends MidtransMonitoringState {
  const MidtransMonitoringInitial();
}

class MidtransMonitoringLoading extends MidtransMonitoringState {
  const MidtransMonitoringLoading();
}

class MidtransMonitoringLoaded extends MidtransMonitoringState {
  final MidtransMonitoringEntity data;
  const MidtransMonitoringLoaded(this.data);
  @override
  List<Object?> get props => [data];
}

class MidtransMonitoringError extends MidtransMonitoringState {
  final String message;
  const MidtransMonitoringError(this.message);
  @override
  List<Object?> get props => [message];
}
