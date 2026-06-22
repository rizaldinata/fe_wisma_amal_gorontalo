import '../../entity/finance/fine_eligible_user_entity.dart';
import '../../repository/finance_repository.dart';

class GetFineEligibleUsersUseCase {
  final FinanceRepository repository;
  GetFineEligibleUsersUseCase(this.repository);

  Future<List<FineEligibleUserEntity>> execute() async {
    return await repository.getFineEligibleUsers();
  }
}
