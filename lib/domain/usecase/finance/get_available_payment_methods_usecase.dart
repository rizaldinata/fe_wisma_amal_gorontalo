import '../../entity/setting/midtrans_method_entity.dart';
import '../../repository/finance_repository.dart';

class GetAvailablePaymentMethodsUseCase {
  final FinanceRepository repository;

  GetAvailablePaymentMethodsUseCase(this.repository);

  Future<List<MidtransMethodEntity>> execute() => repository.getAvailablePaymentMethods();
}
