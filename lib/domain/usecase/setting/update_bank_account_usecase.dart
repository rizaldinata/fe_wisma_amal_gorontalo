import '../../entity/setting/bank_account_entity.dart';
import '../../repository/setting_repository.dart';

class UpdateBankAccountUseCase {
  final SettingRepository repository;
  UpdateBankAccountUseCase(this.repository);
  Future<BankAccountEntity> execute(int id, Map<String, dynamic> data) =>
      repository.updateBankAccount(id, data);
}
