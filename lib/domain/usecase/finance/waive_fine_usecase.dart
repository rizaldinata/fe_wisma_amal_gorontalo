import '../../entity/finance/fine_entity.dart';
import '../../repository/finance_repository.dart';

class WaiveFineUseCase {
  final FinanceRepository repository;
  WaiveFineUseCase(this.repository);

  Future<FineEntity> execute(int fineId, String waiveReason) async {
    return await repository.waiveFine(fineId, waiveReason);
  }
}
