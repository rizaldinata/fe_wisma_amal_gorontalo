import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/domain/entity/resident/resident_entity.dart';
import 'package:frontend/domain/usecase/resident/get_admin_residents_usecase.dart';

// --- EVENTS ---
abstract class ResidentEvent {}
class FetchResidents extends ResidentEvent {}

// --- STATES ---
abstract class ResidentState {}
class ResidentInitial extends ResidentState {}
class ResidentLoading extends ResidentState {}
class ResidentLoaded extends ResidentState {
  final ResidentResponse data;
  ResidentLoaded(this.data);
}
class ResidentError extends ResidentState {
  final String message;
  ResidentError(this.message);
}

// --- BLOC ---
class ResidentBloc extends Bloc<ResidentEvent, ResidentState> {
  final GetAdminResidentsUseCase getAdminResidentsUseCase;

  ResidentBloc({required this.getAdminResidentsUseCase}) : super(ResidentInitial()) {
    on<FetchResidents>((event, emit) async {
      emit(ResidentLoading());
      try {
        final response = await getAdminResidentsUseCase();
        emit(ResidentLoaded(response));
      } catch (e) {
        emit(ResidentError(e.toString()));
      }
    });
  }
}