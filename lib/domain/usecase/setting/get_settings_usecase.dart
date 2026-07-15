import '../../repository/setting_repository.dart';
import '../../entity/setting/setting_entity.dart';

class GetSettingsUseCase {
  final SettingRepository repository;

  GetSettingsUseCase(this.repository);

  Future<SettingEntity> execute() async {
    return await repository.getSettings();
  }
}
