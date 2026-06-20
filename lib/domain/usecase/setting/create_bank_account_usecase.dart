import '../../entity/setting/bank_account_entity.dart';
import '../../repository/setting_repository.dart';

class CreateBankAccountUseCase {
  final SettingRepository repository;
  CreateBankAccountUseCase(this.repository);
  Future<BankAccountEntity> execute(Map<String, dynamic> data) =>
      repository.createBankAccount(data);
}
