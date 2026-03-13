import '../../repository/finance_repository.dart';
import '../../entity/finance/payment_entity.dart';

class GetPendingPaymentsUseCase {
  final FinanceRepository repository;

  GetPendingPaymentsUseCase(this.repository);

  Future<List<PaymentEntity>> call() async {
    return await repository.getPendingPayments();
  }
}
