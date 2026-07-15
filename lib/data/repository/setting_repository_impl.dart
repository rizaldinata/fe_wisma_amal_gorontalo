import '../../domain/entity/setting/bank_account_entity.dart';
import '../../domain/entity/setting/midtrans_fee_config_entity.dart';
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

  @override
  Future<List<BankAccountEntity>> getBankAccounts() async {
    try {
      return await remoteDatasource.getBankAccounts();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<BankAccountEntity>> getPublicBankAccounts() async {
    try {
      return await remoteDatasource.getPublicBankAccounts();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<BankAccountEntity> createBankAccount(Map<String, dynamic> data) async {
    try {
      return await remoteDatasource.createBankAccount(data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<BankAccountEntity> updateBankAccount(int id, Map<String, dynamic> data) async {
    try {
      return await remoteDatasource.updateBankAccount(id, data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteBankAccount(int id) async {
    try {
      await remoteDatasource.deleteBankAccount(id);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<MidtransFeeConfigEntity> getMidtransFeeConfig() async {
    try {
      final model = await remoteDatasource.getMidtransFeeConfig();
      return model.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<MidtransFeeConfigEntity> updateMidtransFeeConfig(MidtransFeeConfigEntity config) async {
    try {
      final model = await remoteDatasource.updateMidtransFeeConfig(config.toUpdatePayload());
      return model.toEntity();
    } catch (e) {
      rethrow;
    }
  }
}
