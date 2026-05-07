import '../../repository/finance_repository.dart';
import '../../entity/finance/payment_entity.dart';

class GetAllPaymentsUseCase {
  final FinanceRepository repository;

  GetAllPaymentsUseCase(this.repository);

  Future<List<PaymentEntity>> call() async {
    return await repository.getAllPayments();
  }
}
