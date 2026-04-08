import 'package:file_picker/file_picker.dart';
import 'package:frontend/domain/repository/room_repository.dart';
import 'package:frontend/domain/usecase/usecase.dart';

class UploadRoomImageParams {
  final int roomId;
  final List<PlatformFile> files;

  UploadRoomImageParams({required this.roomId, required this.files});
}

class UploadRoomImageUseCase implements UseCase<bool, UploadRoomImageParams> {
  final RoomRepository repository;

  UploadRoomImageUseCase(this.repository);

  @override
  Future<bool> call(UploadRoomImageParams params) async {
    return await repository.uploadRoomImage(params.roomId, params.files);
  }
}
