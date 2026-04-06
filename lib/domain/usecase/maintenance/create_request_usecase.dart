import 'package:file_picker/file_picker.dart';
import '../../entity/maintenance_request_entity.dart';
import '../../repository/maintenance_repository.dart';
import '../usecase.dart';

class CreateRequestParams {
  final String title;
  final String description;
  final int? roomId;
  final List<PlatformFile>? images;

  CreateRequestParams({
    required this.title,
    required this.description,
    this.roomId,
    this.images,
  });
}

class CreateRequestUseCase implements UseCase<MaintenanceRequestEntity, CreateRequestParams> {
  final MaintenanceRepository repository;

  CreateRequestUseCase(this.repository);

  @override
  Future<MaintenanceRequestEntity> call(CreateRequestParams params) {
    return repository.createReport(
      title: params.title,
      description: params.description,
      roomId: params.roomId,
      images: params.images,
    );
  }
}
