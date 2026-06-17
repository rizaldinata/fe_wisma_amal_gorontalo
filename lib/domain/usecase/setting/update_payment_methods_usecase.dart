import '../../entity/setting/midtrans_method_entity.dart';
import '../../repository/setting_repository.dart';

class UpdatePaymentMethodsUseCase {
  final SettingRepository repository;

  UpdatePaymentMethodsUseCase(this.repository);

  Future<List<MidtransMethodEntity>> execute(List<String> enabledCodes) =>
      repository.updatePaymentMethods(enabledCodes);
}
