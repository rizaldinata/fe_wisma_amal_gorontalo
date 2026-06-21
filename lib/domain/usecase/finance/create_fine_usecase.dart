import '../../entity/finance/fine_entity.dart';
import '../../repository/finance_repository.dart';

class CreateFineUseCase {
  final FinanceRepository repository;
  CreateFineUseCase(this.repository);

  Future<FineEntity> execute({required int tenantUserId, required double amount, required String reason}) async {
    return await repository.createFine(tenantUserId: tenantUserId, amount: amount, reason: reason);
  }
}
