import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:formz/formz.dart';
import 'package:frontend/core/services/network/exception.dart';
import 'package:frontend/domain/usecase/room/get_room_by_id_usecase.dart';
import 'package:frontend/domain/usecase/room/update_room_usecase.dart';
import 'package:frontend/domain/entity/room_entity.dart';
import 'package:frontend/presentation/widget/core/snackbar/app_snackbar.dart';

part 'detail_room_event.dart';
part 'detail_room_state.dart';

class DetailRoomBloc extends Bloc<DetailRoomEvent, DetailRoomState> {
  final GetRoomByIdUseCase getRoomByIdUseCase;
  final UpdateRoomUseCase updateRoomUseCase;

  DetailRoomBloc({
    required this.getRoomByIdUseCase,
    required this.updateRoomUseCase,
  }) : super(const DetailRoomState()) {
    on<LoadDetailRoomEvent>(_onLoadDetailRoom);
    on<UpdateRoomEvent>(_onUpdateRoom);
    // on<DeleteRoomEvent>(_onDeleteRoom);
  }

  Future<void> _onLoadDetailRoom(
    LoadDetailRoomEvent event,
    Emitter<DetailRoomState> emit,
  ) async {
    try {
      emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
      final room = await getRoomByIdUseCase(event.roomId);
      emit(state.copyWith(status: FormzSubmissionStatus.success, room: room));
    } on AppException catch (e) {
      AppSnackbar.showError('Gagal memuat detail kamar: ${e.message}');
      emit(
        state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: e.message,
        ),
      );
    } catch (e) {
      AppSnackbar.showError('Gagal memuat detail kamar: ${e.toString()}');
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
    Emitter<DetailRoomState> emit,
  ) async {
    try {} on AppException catch (e) {
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

  // Future<void> _onDeleteRoom(
  //   DeleteRoomEvent event,
  //   Emitter<DetailRoomState> emit,
  // ) async {
  //   try {
  //     emit(state.copyWith(deleteStatus: FormzSubmissionStatus.inProgress));
  //     await repository.deleteRoom(event.roomId);
  //     emit(state.copyWith(deleteStatus: FormzSubmissionStatus.success));
  //   } on AppException catch (e) {
  //     AppSnackbar.showError('Gagal menghapus kamar: ${e.message}');
  //     emit(
  //       state.copyWith(
  //         status: FormzSubmissionStatus.failure,
  //         errorMessage: e.message,
  //       ),
  //     );
  //   } catch (e) {
  //     AppSnackbar.showError('Gagal menghapus kamar: ${e.toString()}');
  //     emit(
  //       state.copyWith(
  //         status: FormzSubmissionStatus.failure,
  //         errorMessage: e.toString(),
  //       ),
  //     );
  //   }
  // }
}
