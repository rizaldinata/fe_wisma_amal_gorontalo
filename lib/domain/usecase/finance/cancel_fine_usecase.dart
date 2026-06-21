import '../../entity/finance/fine_entity.dart';
import '../../repository/finance_repository.dart';

class CancelFineUseCase {
  final FinanceRepository repository;
  CancelFineUseCase(this.repository);

  Future<FineEntity> execute(int fineId) async {
    return await repository.cancelFine(fineId);
  }
}
