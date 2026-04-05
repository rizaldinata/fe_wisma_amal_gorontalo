import '../../entity/maintenance_request_entity.dart';
import '../../repository/maintenance_repository.dart';
import '../usecase.dart';

class GetMyRequestsUseCase implements UseCase<List<MaintenanceRequestEntity>, NoParams> {
  final MaintenanceRepository repository;

  GetMyRequestsUseCase(this.repository);

  @override
  Future<List<MaintenanceRequestEntity>> call(NoParams params) {
    return repository.getMyRequests();
  }
}
