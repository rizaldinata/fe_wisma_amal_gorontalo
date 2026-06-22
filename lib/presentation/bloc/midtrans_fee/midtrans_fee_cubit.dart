import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entity/setting/midtrans_fee_config_entity.dart';
import '../../../domain/usecase/setting/get_midtrans_fee_config_usecase.dart';
import '../../../domain/usecase/setting/update_midtrans_fee_config_usecase.dart';

part 'midtrans_fee_state.dart';

class MidtransFeeCubit extends Cubit<MidtransFeeState> {
  final GetMidtransFeeConfigUseCase getUseCase;
  final UpdateMidtransFeeConfigUseCase updateUseCase;

  MidtransFeeCubit({required this.getUseCase, required this.updateUseCase})
      : super(const MidtransFeeInitial());

  Future<void> load() async {
    emit(const MidtransFeeLoading());
    try {
      final config = await getUseCase.execute();
      emit(MidtransFeeLoaded(config));
    } catch (e) {
      emit(MidtransFeeError(e.toString()));
    }
  }

  Future<void> save(MidtransFeeConfigEntity config) async {
    final current = _currentConfig() ?? config;
    emit(MidtransFeeSaving(current));
    try {
      final updated = await updateUseCase.execute(config);
      emit(MidtransFeeSaved(updated));
    } catch (e) {
      emit(MidtransFeeError(e.toString()));
    }
  }

  MidtransFeeConfigEntity? _currentConfig() {
    if (state is MidtransFeeLoaded) return (state as MidtransFeeLoaded).config;
    if (state is MidtransFeeSaving) return (state as MidtransFeeSaving).config;
    if (state is MidtransFeeSaved) return (state as MidtransFeeSaved).config;
    return null;
  }
}
