import '../../domain/entity/setting/midtrans_method_entity.dart';
import '../../domain/entity/setting/setting_entity.dart';
import '../../domain/repository/setting_repository.dart';
import '../datasource/setting_datasource.dart';

class SettingRepositoryImpl implements SettingRepository {
  final SettingDatasource remoteDatasource;

  SettingRepositoryImpl({required this.remoteDatasource});

  @override
  Future<SettingEntity> getSettings() async {
    try {
      final model = await remoteDatasource.getSettings();
      return model;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<SettingEntity> getPublicSettings() async {
    try {
      final model = await remoteDatasource.getPublicSettings();
      return model;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<SettingEntity> updateBulkSettings(Map<String, dynamic> settingsData) async {
    try {
      final model = await remoteDatasource.updateBulkSettings(settingsData);
      return model;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<MidtransMethodEntity>> getPaymentMethods() async {
    try {
      return await remoteDatasource.getPaymentMethods();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<MidtransMethodEntity>> updatePaymentMethods(List<String> enabledCodes) async {
    try {
      return await remoteDatasource.updatePaymentMethods(enabledCodes);
    } catch (e) {
      rethrow;
    }
  }
}
