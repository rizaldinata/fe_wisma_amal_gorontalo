part of 'payment_method_setting_cubit.dart';

abstract class PaymentMethodSettingState extends Equatable {
  const PaymentMethodSettingState();
  @override
  List<Object?> get props => [];
}

class PaymentMethodSettingInitial extends PaymentMethodSettingState {
  const PaymentMethodSettingInitial();
}

class PaymentMethodSettingLoading extends PaymentMethodSettingState {
  const PaymentMethodSettingLoading();
}

class PaymentMethodSettingLoaded extends PaymentMethodSettingState {
  final List<MidtransMethodEntity> methods;
  const PaymentMethodSettingLoaded(this.methods);
  @override
  List<Object?> get props => [methods];
}

class PaymentMethodSettingSaving extends PaymentMethodSettingState {
  final List<MidtransMethodEntity> methods;
  const PaymentMethodSettingSaving(this.methods);
  @override
  List<Object?> get props => [methods];
}

class PaymentMethodSettingSaved extends PaymentMethodSettingState {
  final List<MidtransMethodEntity> methods;
  const PaymentMethodSettingSaved(this.methods);
  @override
  List<Object?> get props => [methods];
}

class PaymentMethodSettingError extends PaymentMethodSettingState {
  final String message;
  const PaymentMethodSettingError(this.message);
  @override
  List<Object?> get props => [message];
}
