import '../../repository/setting_repository.dart';

class DeleteBankAccountUseCase {
  final SettingRepository repository;
  DeleteBankAccountUseCase(this.repository);
  Future<void> execute(int id) => repository.deleteBankAccount(id);
}
