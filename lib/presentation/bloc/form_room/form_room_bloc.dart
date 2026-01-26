import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:formz/formz.dart';
import 'package:frontend/core/utils/image_utils.dart';
import 'package:frontend/data/repository/room_repository.dart';
import 'package:frontend/domain/entity/room_entity.dart';
import 'package:frontend/presentation/widget/core/image/image_carousel.dart';
import 'package:frontend/presentation/widget/core/snackbar/app_snackbar.dart';

import 'package:uuid/uuid.dart';
part 'form_room_event.dart';
part 'form_room_state.dart';

class FormRoomBloc extends Bloc<FormRoomEvent, FormRoomState> {
  RoomRepository repository;

  FormRoomBloc({required this.repository}) : super(const FormRoomState()) {
    on<LoadFormRoomEvent>(_onLoadFormRoom);
    on<SubmitFormRoomEvent>(_onSubmitFormRoom);
    on<EditFormRoomEvent>(_onEditFormRoom);
    on<AddFormRoomEvent>(_onAddFormRoom);
    on<PickRoomImagesEvent>(_onPickRoomImages);
    on<RemoveRoomImageEvent>(_onRemoveRoomImage);
  }

  Future<void> _onRemoveRoomImage(
    RemoveRoomImageEvent event,
    Emitter<FormRoomState> emit,
  ) async {
    try {
      final updatedImages = state.imageFiles
          .where((image) => image.id != event.index)
          .toList();

      emit(state.copyWith(imageFiles: updatedImages));
      AppSnackbar.showSuccess('Image removeded');
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onPickRoomImages(
    PickRoomImagesEvent event,
    Emitter<FormRoomState> emit,
  ) async {
    try {
      emit(state.copyWith(imagePickStatus: FormzSubmissionStatus.inProgress));
      final files = await ImageUtils.pickImagesWeb();

      final addedFiles = List<ImageFile>.from(state.imageFiles)
        ..addAll(
          files
              .map(
                (file) => ImageFile(
                  type: ImageSourceType.memory,
                  file: file,
                  id: Uuid().v4(),
                ),
              )
              .toList(),
        );

      if (files.isNotEmpty) {
        emit(
          state.copyWith(
            imageFiles: addedFiles,
            imagePickStatus: FormzSubmissionStatus.success,
          ),
        );
      } else {
        emit(
          state.copyWith(
            imagePickStatus: FormzSubmissionStatus.failure,
            errorMessage: 'No images selected',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          imagePickStatus: FormzSubmissionStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onAddFormRoom(
    AddFormRoomEvent event,
    Emitter<FormRoomState> emit,
  ) async {
    try {
      emit(state.copyWith(submitStatus: FormzSubmissionStatus.inProgress));
      final newRoom = await repository.createRoom(event.roomData);
      emit(
        state.copyWith(
          room: newRoom,
          submitStatus: FormzSubmissionStatus.success,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          errorMessage: e.toString(),
          submitStatus: FormzSubmissionStatus.failure,
        ),
      );
    }
  }

  Future<void> _onLoadFormRoom(
    LoadFormRoomEvent event,
    Emitter<FormRoomState> emit,
  ) async {
    try {
      if (event.roomId != null) {
        emit(state.copyWith(loadStatus: FormzSubmissionStatus.inProgress));
        final room = await repository.getRoomById(event.roomId!);

        final imageFiles = room.imageUrl
            .map(
              (url) => ImageFile(
                url: url.url,
                id: '${url.id}',
                type: ImageSourceType.network,
              ),
            )
            .toList();

        emit(
          state.copyWith(
            loadStatus: FormzSubmissionStatus.success,
            room: room,
            imageFiles: imageFiles,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          loadStatus: FormzSubmissionStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onSubmitFormRoom(
    SubmitFormRoomEvent event,
    Emitter<FormRoomState> emit,
  ) async {
    try {
      emit(state.copyWith(submitStatus: FormzSubmissionStatus.inProgress));
      RoomEntity processedRoom;
      if (event.roomData.description.isNotEmpty) {
        processedRoom = await repository.updateRoom(event.roomData);
      } else {
        processedRoom = await repository.createRoom(event.roomData);
      }
      emit(
        state.copyWith(
          room: processedRoom,
          submitStatus: FormzSubmissionStatus.success,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          errorMessage: e.toString(),
          submitStatus: FormzSubmissionStatus.failure,
        ),
      );
    }
  }

  Future<void> _onEditFormRoom(
    EditFormRoomEvent event,
    Emitter<FormRoomState> emit,
  ) async {
    try {
      emit(state.copyWith(editStatus: FormzSubmissionStatus.inProgress));
      final updatedRoom = await repository.updateRoom(event.roomData);
      emit(
        state.copyWith(
          room: updatedRoom,
          editStatus: FormzSubmissionStatus.success,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          errorMessage: e.toString(),
          editStatus: FormzSubmissionStatus.failure,
        ),
      );
    }
  }
}
