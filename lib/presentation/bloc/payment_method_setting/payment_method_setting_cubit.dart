import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entity/setting/midtrans_method_entity.dart';
import '../../../domain/usecase/setting/get_payment_methods_usecase.dart';
import '../../../domain/usecase/setting/update_payment_methods_usecase.dart';

part 'payment_method_setting_state.dart';

class PaymentMethodSettingCubit extends Cubit<PaymentMethodSettingState> {
  final GetPaymentMethodsUseCase getUseCase;
  final UpdatePaymentMethodsUseCase updateUseCase;

  PaymentMethodSettingCubit({
    required this.getUseCase,
    required this.updateUseCase,
  }) : super(const PaymentMethodSettingInitial());

  Future<void> load() async {
    emit(const PaymentMethodSettingLoading());
    try {
      final methods = await getUseCase.execute();
      emit(PaymentMethodSettingLoaded(methods));
    } catch (e) {
      emit(PaymentMethodSettingError(e.toString()));
    }
  }

  Future<void> save(List<String> enabledCodes) async {
    final current = state is PaymentMethodSettingLoaded
        ? (state as PaymentMethodSettingLoaded).methods
        : <MidtransMethodEntity>[];

    emit(PaymentMethodSettingSaving(current));
    try {
      final updated = await updateUseCase.execute(enabledCodes);
      emit(PaymentMethodSettingSaved(updated));
    } catch (e) {
      emit(PaymentMethodSettingError(e.toString()));
    }
  }
}
