import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:frontend/core/services/network/exception.dart';
import 'package:frontend/data/repository/room_repository.dart';
import 'package:frontend/presentation/bloc/room_list/room_event.dart';
import 'package:frontend/presentation/bloc/room_list/room_state.dart';
import 'package:frontend/presentation/widget/core/snackbar/app_snackbar.dart';

class RoomBloc extends Bloc<RoomEvent, RoomState> {
  final RoomRepository repository;

  RoomBloc(this.repository) : super(const RoomState()) {
    on<GetRoomsEvent>(_onGetRooms);
    on<AddRoomEvent>(_onAddRoom);
    on<UpdateRoomEvent>(_onUpdateRoom);
    on<DeleteRoomEvent>(_onDeleteRoom);
    on<SelectRoomEvent>((event, emit) {
      emit(state.copyWith(selectedRoom: event.room));
    });
  }

  Future<void> _onGetRooms(GetRoomsEvent event, Emitter<RoomState> emit) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    try {
      final rooms = await repository.getRooms();
      emit(
        state.copyWith(
          status: FormzSubmissionStatus.success,
          rooms: rooms,
          successMessage: null,
        ),
      );
    } catch (e) {
      AppSnackbar.showError('Gagal memuat data kamar: ${e.toString()}');
      emit(
        state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onAddRoom(AddRoomEvent event, Emitter<RoomState> emit) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    try {
      await repository.createRoom(event.room);
      emit(
        state.copyWith(
          status: FormzSubmissionStatus.success,
          successMessage: "Berhasil menambah kamar",
        ),
      );
      add(GetRoomsEvent());
    } on AppException catch (e) {
      AppSnackbar.showError('Gagal menambah kamar: ${e.message}');
      emit(
        state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: e.message,
        ),
      );
    } catch (e) {
      AppSnackbar.showError('Gagal menambah kamar: ${e.toString()}');
      emit(
        state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onUpdateRoom(
    UpdateRoomEvent event,
    Emitter<RoomState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    try {
      await repository.updateRoom(event.room);
      emit(
        state.copyWith(
          status: FormzSubmissionStatus.success,
          successMessage: "Berhasil mengupdate kamar",
        ),
      );
      add(GetRoomsEvent());
    } on AppException catch (e) {
      AppSnackbar.showError('Gagal mengupdate kamar: ${e.message}');
      emit(
        state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: e.message,
        ),
      );
    } catch (e) {
      AppSnackbar.showError('Gagal mengupdate kamar: ${e.toString()}');
      emit(
        state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onDeleteRoom(
    DeleteRoomEvent event,
    Emitter<RoomState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    try {
      await repository.deleteRoom(event.id);
      emit(
        state.copyWith(
          status: FormzSubmissionStatus.success,
          successMessage: "Berhasil menghapus kamar",
        ),
      );
      add(GetRoomsEvent());
    } on AppException catch (e) {
      AppSnackbar.showError('Gagal menghapus kamar: ${e.message}');
      emit(
        state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: e.message,
        ),
      );
    } catch (e) {
      AppSnackbar.showError('Gagal menghapus kamar: ${e.toString()}');
      emit(
        state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
