import '../entity/setting/midtrans_method_entity.dart';
import '../entity/setting/setting_entity.dart';

abstract class SettingRepository {
  Future<SettingEntity> getSettings();
  Future<SettingEntity> getPublicSettings();
  Future<SettingEntity> updateBulkSettings(Map<String, dynamic> settingsData);
  Future<List<MidtransMethodEntity>> getPaymentMethods();
  Future<List<MidtransMethodEntity>> updatePaymentMethods(List<String> enabledCodes);
}
