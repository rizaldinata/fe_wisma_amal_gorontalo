import '../../core/services/network/dio_client.dart';
import '../model/setting/setting_model.dart';

abstract class SettingDatasource {
  Future<SettingModel> getSettings();
  Future<SettingModel> getPublicSettings();
  Future<SettingModel> updateBulkSettings(Map<String, dynamic> settingsData);
}

class SettingDatasourceImpl implements SettingDatasource {
  final DioClient _dioClient;

  SettingDatasourceImpl(this._dioClient);

  @override
  Future<SettingModel> getSettings() async {
    try {
      final response = await _dioClient.get('/v1/settings');
      final data = response.data['data'] as Map<String, dynamic>;
      return SettingModel.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<SettingModel> getPublicSettings() async {
    try {
      final response = await _dioClient.get('/v1/settings/public');
      final data = response.data['data'] as Map<String, dynamic>;
      return SettingModel.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<SettingModel> updateBulkSettings(Map<String, dynamic> settingsData) async {
    try {
      // Endpoint require JSON Object as `settings` wrapper
      final response = await _dioClient.post(
        '/v1/settings/update-bulk',
        data: {'settings': settingsData},
      );
      final data = response.data['data'] as Map<String, dynamic>;
      return SettingModel.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }
}
