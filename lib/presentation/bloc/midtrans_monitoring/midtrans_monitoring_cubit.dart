import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entity/finance/midtrans_monitoring_entity.dart';
import '../../../domain/usecase/finance/get_midtrans_monitoring_usecase.dart';

part 'midtrans_monitoring_state.dart';

class MidtransMonitoringCubit extends Cubit<MidtransMonitoringState> {
  final GetMidtransMonitoringUseCase getUseCase;

  MidtransMonitoringCubit({required this.getUseCase})
      : super(const MidtransMonitoringInitial());

  Future<void> load() async {
    emit(const MidtransMonitoringLoading());
    try {
      final data = await getUseCase.call();
      emit(MidtransMonitoringLoaded(data));
    } catch (e) {
      emit(MidtransMonitoringError(e.toString()));
    }
  }
}
