import '../../entity/setting/midtrans_fee_config_entity.dart';
import '../../repository/setting_repository.dart';

class UpdateMidtransFeeConfigUseCase {
  final SettingRepository repository;
  const UpdateMidtransFeeConfigUseCase(this.repository);

  Future<MidtransFeeConfigEntity> execute(MidtransFeeConfigEntity config) =>
      repository.updateMidtransFeeConfig(config);
}
