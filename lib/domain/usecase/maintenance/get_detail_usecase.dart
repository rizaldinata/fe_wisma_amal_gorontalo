import '../../entity/maintenance_request_entity.dart';
import '../../repository/maintenance_repository.dart';
import '../usecase.dart'; // Ensure correct import

class GetDetailUseCase implements UseCase<MaintenanceRequestEntity, int> {
  final MaintenanceRepository repository;

  GetDetailUseCase(this.repository);

  @override
  Future<MaintenanceRequestEntity> call(int params) {
    return repository.getReportById(params);
  }
}
