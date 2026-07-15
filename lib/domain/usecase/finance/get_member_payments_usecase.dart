import '../../entity/finance/payment_entity.dart';
import '../../repository/finance_repository.dart';

class GetMemberPaymentsUseCase {
  final FinanceRepository repository;

  GetMemberPaymentsUseCase(this.repository);

  Future<List<PaymentEntity>> execute() async {
    return await repository.getMemberPayments();
  }
}
