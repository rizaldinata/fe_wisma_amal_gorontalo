import '../../entity/setting/bank_account_entity.dart';
import '../../repository/setting_repository.dart';

class GetPublicBankAccountsUseCase {
  final SettingRepository repository;
  GetPublicBankAccountsUseCase(this.repository);
  Future<List<BankAccountEntity>> execute() => repository.getPublicBankAccounts();
}
