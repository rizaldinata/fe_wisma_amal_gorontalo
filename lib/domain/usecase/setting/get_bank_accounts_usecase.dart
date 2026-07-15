import '../../entity/setting/bank_account_entity.dart';
import '../../repository/setting_repository.dart';

class GetBankAccountsUseCase {
  final SettingRepository repository;
  GetBankAccountsUseCase(this.repository);
  Future<List<BankAccountEntity>> execute() => repository.getBankAccounts();
}
