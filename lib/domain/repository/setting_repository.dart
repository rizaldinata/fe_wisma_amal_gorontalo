import '../entity/setting/bank_account_entity.dart';
import '../entity/setting/midtrans_method_entity.dart';
import '../entity/setting/setting_entity.dart';

abstract class SettingRepository {
  Future<SettingEntity> getSettings();
  Future<SettingEntity> getPublicSettings();
  Future<SettingEntity> updateBulkSettings(Map<String, dynamic> settingsData);
  Future<List<MidtransMethodEntity>> getPaymentMethods();
  Future<List<MidtransMethodEntity>> updatePaymentMethods(List<String> enabledCodes);

  Future<List<BankAccountEntity>> getBankAccounts();
  Future<List<BankAccountEntity>> getPublicBankAccounts();
  Future<BankAccountEntity> createBankAccount(Map<String, dynamic> data);
  Future<BankAccountEntity> updateBankAccount(int id, Map<String, dynamic> data);
  Future<void> deleteBankAccount(int id);
}
