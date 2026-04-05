import 'package:file_picker/file_picker.dart';
import '../../entity/maintenance_request_entity.dart';
import '../../repository/maintenance_repository.dart';
import '../usecase.dart';

class AddUpdateParams {
  final int requestId;
  final String description;
  final String? status;
  final List<PlatformFile>? images;

  AddUpdateParams({
    required this.requestId,
    required this.description,
    this.status,
    this.images,
  });
}

class AddUpdateUseCase implements UseCase<MaintenanceTimelineEntity, AddUpdateParams> {
  final MaintenanceRepository repository;

  AddUpdateUseCase(this.repository);

  @override
  Future<MaintenanceTimelineEntity> call(AddUpdateParams params) {
    return repository.addUpdateReply(
      requestId: params.requestId,
      description: params.description,
      status: params.status,
      images: params.images,
    );
  }
}
