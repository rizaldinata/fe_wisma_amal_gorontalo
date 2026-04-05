import '../../entity/maintenance_request_entity.dart';
import '../../repository/maintenance_repository.dart';
import '../usecase.dart';

class GetAllRequestsUseCase
    implements UseCase<List<MaintenanceRequestEntity>, NoParams> {
  final MaintenanceRepository repository;

  GetAllRequestsUseCase(this.repository);

  @override
  Future<List<MaintenanceRequestEntity>> call(NoParams params) {
    return repository.getAllRequests();
  }
}
