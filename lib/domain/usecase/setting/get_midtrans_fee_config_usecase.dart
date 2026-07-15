import '../../entity/setting/midtrans_fee_config_entity.dart';
import '../../repository/setting_repository.dart';

class GetMidtransFeeConfigUseCase {
  final SettingRepository repository;
  const GetMidtransFeeConfigUseCase(this.repository);

  Future<MidtransFeeConfigEntity> execute() => repository.getMidtransFeeConfig();
}
