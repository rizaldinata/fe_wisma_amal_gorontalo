part of 'midtrans_fee_cubit.dart';

abstract class MidtransFeeState extends Equatable {
  const MidtransFeeState();
  @override
  List<Object?> get props => [];
}

class MidtransFeeInitial extends MidtransFeeState {
  const MidtransFeeInitial();
}

class MidtransFeeLoading extends MidtransFeeState {
  const MidtransFeeLoading();
}

class MidtransFeeLoaded extends MidtransFeeState {
  final MidtransFeeConfigEntity config;
  const MidtransFeeLoaded(this.config);
  @override
  List<Object?> get props => [config];
}

class MidtransFeeSaving extends MidtransFeeState {
  final MidtransFeeConfigEntity config;
  const MidtransFeeSaving(this.config);
  @override
  List<Object?> get props => [config];
}

class MidtransFeeSaved extends MidtransFeeState {
  final MidtransFeeConfigEntity config;
  const MidtransFeeSaved(this.config);
  @override
  List<Object?> get props => [config];
}

class MidtransFeeError extends MidtransFeeState {
  final String message;
  const MidtransFeeError(this.message);
  @override
  List<Object?> get props => [message];
}
