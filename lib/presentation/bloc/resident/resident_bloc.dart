import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/domain/entity/resident/resident_entity.dart';

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
  ResidentBloc() : super(ResidentInitial()) {
    on<FetchResidents>((event, emit) async {
      emit(ResidentLoading());
      try {
        // TODO: Ganti Future.delayed ini dengan pemanggilan API Dio Anda
        // final response = await apiService.getAdminResidents();
        // emit(ResidentLoaded(response));

        await Future.delayed(const Duration(seconds: 1)); // Simulasi API
        
        // Simulasi Data Berhasil Diambil
        emit(ResidentLoaded(
          ResidentResponse(
            stats: ResidentStats(penghuniAktif: 48, kontrakPending: 3, kontrakBerakhir: 2, kamarTersedia: 12),
            residents: [
              ResidentItem(id: '1', nama: 'Dwi Rahmawati', kamar: 'AC203', kontak: '0812-3456-7890', detailBayar: 'Lunas', isBelumLunas: false, status: 'Aktif', isPending: false),
              ResidentItem(id: '2', nama: 'Ahmad Budi', kamar: 'VIP01', kontak: '0899-8888-7777', detailBayar: 'Belum Lunas', isBelumLunas: true, status: 'Pending', isPending: true),
            ],
          )
        ));
      } catch (e) {
        emit(ResidentError(e.toString()));
      }
    });
  }
}