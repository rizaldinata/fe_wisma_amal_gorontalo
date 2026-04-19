import '../../repository/setting_repository.dart';
import '../../entity/setting/setting_entity.dart';

class UpdateBulkSettingsUseCase {
  final SettingRepository repository;

  UpdateBulkSettingsUseCase(this.repository);

  Future<SettingEntity> execute(Map<String, dynamic> settingsData) async {
    return await repository.updateBulkSettings(settingsData);
  }
}
