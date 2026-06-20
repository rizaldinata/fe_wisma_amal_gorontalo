import '../../core/services/network/dio_client.dart';
import '../../domain/entity/setting/midtrans_method_entity.dart';
import '../model/setting/bank_account_model.dart';
import '../model/setting/setting_model.dart';

abstract class SettingDatasource {
  Future<SettingModel> getSettings();
  Future<SettingModel> getPublicSettings();
  Future<SettingModel> updateBulkSettings(Map<String, dynamic> settingsData);
  Future<List<MidtransMethodEntity>> getPaymentMethods();
  Future<List<MidtransMethodEntity>> updatePaymentMethods(List<String> enabledCodes);

  Future<List<BankAccountModel>> getBankAccounts();
  Future<List<BankAccountModel>> getPublicBankAccounts();
  Future<BankAccountModel> createBankAccount(Map<String, dynamic> data);
  Future<BankAccountModel> updateBankAccount(int id, Map<String, dynamic> data);
  Future<void> deleteBankAccount(int id);
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

  @override
  Future<List<MidtransMethodEntity>> getPaymentMethods() async {
    try {
      final response = await _dioClient.get('/v1/settings/payment-methods');
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((item) => MidtransMethodEntity(
            code: item['code'] as String,
            label: item['label'] as String,
            enabled: item['enabled'] == true,
          )).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<MidtransMethodEntity>> updatePaymentMethods(List<String> enabledCodes) async {
    try {
      final response = await _dioClient.put(
        '/v1/settings/payment-methods',
        data: {'enabled_methods': enabledCodes},
      );
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((item) => MidtransMethodEntity(
            code: item['code'] as String,
            label: item['label'] as String,
            enabled: item['enabled'] == true,
          )).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<BankAccountModel>> getBankAccounts() async {
    try {
      final response = await _dioClient.get('/v1/settings/bank-accounts');
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((e) => BankAccountModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<BankAccountModel>> getPublicBankAccounts() async {
    try {
      final response = await _dioClient.get('/v1/settings/bank-accounts/public');
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((e) => BankAccountModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<BankAccountModel> createBankAccount(Map<String, dynamic> data) async {
    try {
      final response = await _dioClient.post('/v1/settings/bank-accounts', data: data);
      return BankAccountModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<BankAccountModel> updateBankAccount(int id, Map<String, dynamic> data) async {
    try {
      final response = await _dioClient.put('/v1/settings/bank-accounts/$id', data: data);
      return BankAccountModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteBankAccount(int id) async {
    try {
      await _dioClient.delete('/v1/settings/bank-accounts/$id');
    } catch (e) {
      rethrow;
    }
  }
}
