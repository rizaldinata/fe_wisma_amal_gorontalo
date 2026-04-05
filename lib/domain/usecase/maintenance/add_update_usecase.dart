import '../../entity/maintenance_request_entity.dart';
import '../../repository/maintenance_repository.dart';
import '../usecase.dart';

class AddUpdateParams {
  final int requestId;
  final String description;
  final String? status;
  final List<String>? imagePaths;

  AddUpdateParams({
    required this.requestId,
    required this.description,
    this.status,
    this.imagePaths,
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
      imagePaths: params.imagePaths,
    );
  }
}
