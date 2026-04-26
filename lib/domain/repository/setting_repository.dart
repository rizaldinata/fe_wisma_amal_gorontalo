import '../entity/setting/setting_entity.dart';

abstract class SettingRepository {
  Future<SettingEntity> getSettings();
  Future<SettingEntity> updateBulkSettings(Map<String, dynamic> settingsData);
}
