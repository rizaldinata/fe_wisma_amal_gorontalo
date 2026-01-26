part of 'form_room_bloc.dart';

class ImageFile {
  final String? url;
  final PlatformFile? file;
  final ImageSourceType type;
  final String? id;

  const ImageFile({this.url, required this.type, this.id, this.file});
}

class FormRoomState extends Equatable {
  final FormzSubmissionStatus loadStatus;
  final FormzSubmissionStatus editStatus;
  final FormzSubmissionStatus submitStatus;
  final FormzSubmissionStatus imagePickStatus;
  final String? errorMessage;
  final String? successMessage;
  final List<ImageFile> imageUrlsToDelete;
  final RoomEntity room;
  final List<ImageFile> imageFiles;

  const FormRoomState({
    this.loadStatus = FormzSubmissionStatus.initial,
    this.submitStatus = FormzSubmissionStatus.initial,
    this.editStatus = FormzSubmissionStatus.initial,
    this.imagePickStatus = FormzSubmissionStatus.initial,
    this.imageUrlsToDelete = const [],
    this.errorMessage,
    this.successMessage,
    this.room = const RoomEntity.empty(),
    this.imageFiles = const [],
  });

  FormRoomState copyWith({
    FormzSubmissionStatus? loadStatus,
    FormzSubmissionStatus? submitStatus,
    FormzSubmissionStatus? editStatus,
    FormzSubmissionStatus? imagePickStatus,
    List<ImageFile>? imageUrlsToDelete,
    String? errorMessage,
    String? successMessage,
    RoomEntity? room,
    List<ImageFile>? imageFiles,
  }) {
    return FormRoomState(
      loadStatus: loadStatus ?? this.loadStatus,
      submitStatus: submitStatus ?? this.submitStatus,
      editStatus: editStatus ?? this.editStatus,
      imagePickStatus: imagePickStatus ?? this.imagePickStatus,
      imageUrlsToDelete: imageUrlsToDelete ?? this.imageUrlsToDelete,
      errorMessage: errorMessage,
      successMessage: successMessage,
      room: room ?? this.room,
      imageFiles: imageFiles ?? this.imageFiles,
    );
  }

  @override
  List<Object?> get props => [
    loadStatus,
    submitStatus,
    editStatus,
    imagePickStatus,
    room,
    errorMessage,
    successMessage,
    imageUrlsToDelete,
    imageFiles,
  ];
}
