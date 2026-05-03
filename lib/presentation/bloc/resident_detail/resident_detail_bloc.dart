import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/services/network/exception.dart';
import 'package:frontend/domain/entity/resident/resident_detail_entity.dart';
import 'package:frontend/domain/usecase/resident/get_admin_resident_detail_usecase.dart';

abstract class ResidentDetailEvent {}

class FetchResidentDetail extends ResidentDetailEvent {
  final String id;

  FetchResidentDetail(this.id);
}

abstract class ResidentDetailState {}

class ResidentDetailInitial extends ResidentDetailState {}

class ResidentDetailLoading extends ResidentDetailState {}

class ResidentDetailLoaded extends ResidentDetailState {
  final ResidentDetailEntity data;

  ResidentDetailLoaded(this.data);
}

class ResidentDetailError extends ResidentDetailState {
  final String message;

  ResidentDetailError(this.message);
}

class ResidentDetailBloc extends Bloc<ResidentDetailEvent, ResidentDetailState> {
  final GetAdminResidentDetailUseCase getAdminResidentDetailUseCase;

  ResidentDetailBloc({required this.getAdminResidentDetailUseCase})
      : super(ResidentDetailInitial()) {
    on<FetchResidentDetail>(_onFetchDetail);
  }

  Future<void> _onFetchDetail(
    FetchResidentDetail event,
    Emitter<ResidentDetailState> emit,
  ) async {
    emit(ResidentDetailLoading());
    try {
      final result = await getAdminResidentDetailUseCase(event.id);
      emit(ResidentDetailLoaded(result));
    } on AppException catch (e) {
      emit(ResidentDetailError(e.message));
    } catch (e) {
      emit(ResidentDetailError(e.toString()));
    }
  }
}
