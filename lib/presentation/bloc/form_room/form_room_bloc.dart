import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:formz/formz.dart';
import 'package:frontend/core/utils/image_utils.dart';
import 'package:frontend/domain/usecase/room/create_room_usecase.dart';
import 'package:frontend/domain/usecase/room/delete_room_image_usecase.dart';
import 'package:frontend/domain/usecase/room/get_room_by_id_usecase.dart';
import 'package:frontend/domain/usecase/room/update_room_usecase.dart';
import 'package:frontend/domain/usecase/room/upload_room_image_usecase.dart';
import 'package:frontend/domain/entity/room_entity.dart';
import 'package:frontend/presentation/pages/room_form/form_room.dart';
import 'package:frontend/presentation/widget/core/image/image_carousel.dart';
import 'package:frontend/presentation/widget/core/snackbar/app_snackbar.dart';

import 'package:uuid/uuid.dart';
part 'form_room_event.dart';
part 'form_room_state.dart';

class FormRoomBloc extends Bloc<FormRoomEvent, FormRoomState> {
  final CreateRoomUseCase createRoomUseCase;
  final GetRoomByIdUseCase getRoomByIdUseCase;
  final UpdateRoomUseCase updateRoomUseCase;
  final DeleteRoomImageUseCase deleteRoomImageUseCase;
  final UploadRoomImageUseCase uploadRoomImageUseCase;

  FormRoomBloc({
    required this.createRoomUseCase,
    required this.getRoomByIdUseCase,
    required this.updateRoomUseCase,
    required this.deleteRoomImageUseCase,
    required this.uploadRoomImageUseCase,
  }) : super(const FormRoomState()) {
    on<LoadFormRoomEvent>(_onLoadFormRoom);
    on<SubmitFormRoomEvent>(_onSubmitFormRoom);
    on<EditFormRoomEvent>(_onEditFormRoom);
    on<AddFormRoomEvent>(_onAddFormRoom);
    on<PickRoomImagesEvent>(_onPickRoomImages);
    on<RemoveRoomImageEvent>(_onRemoveRoomImage);
    on<AddFacilityEvent>(_onAddFacility);
    on<RemoveFacilityEvent>(_onRemoveFacility);
    on<UploadRoomImagesEvent>(_onUploadRoomImages);
  }

  Future<void> _onUploadRoomImages(
    UploadRoomImagesEvent event,
    Emitter<FormRoomState> emit,
  ) async {
    try {} catch (e) {
      emit(
        state.copyWith(
          errorMessage: e.toString(),
          submitStatus: FormzSubmissionStatus.failure,
        ),
      );
    }
  }

  Future<void> _onAddFacility(
    AddFacilityEvent event,
    Emitter<FormRoomState> emit,
  ) async {
    try {
      final updatedFacilities = List<String>.from(state.facilities)
        ..add(event.facility);

      emit(state.copyWith(facilities: updatedFacilities));
      AppSnackbar.showSuccess('Facility added');
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onRemoveFacility(
    RemoveFacilityEvent event,
    Emitter<FormRoomState> emit,
  ) async {
    try {
      final facilities = List<String>.from(state.facilities);
      facilities.removeAt(event.index);

      emit(state.copyWith(facilities: facilities));
      AppSnackbar.showSuccess('Facility removeded');
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onRemoveRoomImage(
    RemoveRoomImageEvent event,
    Emitter<FormRoomState> emit,
  ) async {
    try {
      final updatedImages = state.imageFiles
          .where((image) => image.id != event.file.id)
          .toList();

      if (event.file.type == ImageSourceType.network &&
          event.file.url != null) {
        final imagesToDelete = List<ImageFile>.from(state.imageUrlsToDelete);
        imagesToDelete.add(event.file);
        print("adding image to delete:${event.file.id}");
        emit(state.copyWith(imageUrlsToDelete: imagesToDelete));
        print("total images to delete:${state.imageUrlsToDelete.length}");
      }

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
      final newRoom = await createRoomUseCase(event.roomData);
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
        final room = await getRoomByIdUseCase(event.roomId!);

        final imageFiles = room.imageUrl
            ?.map(
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
            facilities: room.facilities,
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
    } finally {
      // Future.delayed(const Duration(milliseconds: 500));
      // emit(state.copyWith(loadStatus: FormzSubmissionStatus.initial));
    }
  }

  Future<void> _onSubmitFormRoom(
    SubmitFormRoomEvent event,
    Emitter<FormRoomState> emit,
  ) async {
    try {
      emit(state.copyWith(submitStatus: FormzSubmissionStatus.inProgress));
      RoomEntity processedRoom;
      if (event.formMode == FormMode.edit) {
        processedRoom = await updateRoomUseCase(event.roomData);
      } else {
        processedRoom = await createRoomUseCase(
          event.roomData.copyWith(status: RoomStatusEnum.available),
        );
      }
      //delete images if any
      print(
        "total images to delete at submit:${state.imageUrlsToDelete.length}",
      );
      for (var image in state.imageUrlsToDelete) {
        if (image.id != null) {
          print("deleting image:${image.id}");
          await deleteRoomImageUseCase(
            DeleteRoomImageParams(
              roomId: processedRoom.id,
              imageId: int.parse(image.id!),
            ),
          );
        }
      }
      //upload new images if any
      final newImages = state.imageFiles
          .where(
            (image) =>
                image.type == ImageSourceType.memory && image.file != null,
          )
          .toList();
      if (newImages.isNotEmpty) {
        print("uploading new images");
        final files = newImages.map((e) => e.file!).toList();
        try {
          await uploadRoomImageUseCase(
            UploadRoomImageParams(
              roomId: processedRoom.id,
              files: files,
            ),
          );
        } catch (e) {
          print('Error uploading images: $e');
          // We still consider it a success if the room was saved,
          // but we might want to warn the user or rethrow depending on requirements.
          // For now, let's rethrow to show the error snackbar.
          throw Exception('Room saved, but image upload failed: $e');
        }
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
      final updatedRoom = await updateRoomUseCase(event.roomData);
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
