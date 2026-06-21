import '../../entity/finance/fine_entity.dart';
import '../../repository/finance_repository.dart';

class GetAllFinesUseCase {
  final FinanceRepository repository;
  GetAllFinesUseCase(this.repository);

  Future<List<FineEntity>> execute({String? status, int? tenantUserId}) async {
    return await repository.getAllFines(status: status, tenantUserId: tenantUserId);
  }
}
