import '../../entity/maintenance_request_entity.dart';
import '../../repository/maintenance_repository.dart';

class GetAllRequestsUseCase {
  final MaintenanceRepository repository;

  GetAllRequestsUseCase(this.repository);

  Future<PaginatedMaintenanceRequests> call({int page = 1, int perPage = 10}) {
    return repository.getAllRequests(page, perPage);
  }
}
