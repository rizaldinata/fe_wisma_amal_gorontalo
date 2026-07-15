import '../../repository/setting_repository.dart';
import '../../entity/setting/setting_entity.dart';

class GetPublicSettingsUseCase {
  final SettingRepository repository;

  GetPublicSettingsUseCase(this.repository);

  Future<SettingEntity> execute() async {
    return await repository.getPublicSettings();
  }
}
