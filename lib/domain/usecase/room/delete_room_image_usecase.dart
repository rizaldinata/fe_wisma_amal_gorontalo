import 'package:frontend/domain/repository/room_repository.dart';
import 'package:frontend/domain/usecase/usecase.dart';

class DeleteRoomImageParams {
  final int roomId;
  final int imageId;

  DeleteRoomImageParams({required this.roomId, required this.imageId});
}

class DeleteRoomImageUseCase implements UseCase<bool, DeleteRoomImageParams> {
  final RoomRepository repository;

  DeleteRoomImageUseCase(this.repository);

  @override
  Future<bool> call(DeleteRoomImageParams params) async {
    return await repository.deleteRoomImage(params.roomId, params.imageId);
  }
}
