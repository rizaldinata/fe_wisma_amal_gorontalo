import '../../entity/finance/fine_entity.dart';
import '../../repository/finance_repository.dart';

class GetMyFinesUseCase {
  final FinanceRepository repository;
  GetMyFinesUseCase(this.repository);

  Future<List<FineEntity>> execute({String? status}) async {
    return await repository.getMyFines(status: status);
  }
}
