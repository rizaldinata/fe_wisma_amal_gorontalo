import '../../entity/setting/midtrans_method_entity.dart';
import '../../repository/setting_repository.dart';

class GetPaymentMethodsUseCase {
  final SettingRepository repository;

  GetPaymentMethodsUseCase(this.repository);

  Future<List<MidtransMethodEntity>> execute() => repository.getPaymentMethods();
}
