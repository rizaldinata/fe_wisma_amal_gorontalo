import '../../entity/finance/member_finance_summary_entity.dart';
import '../../repository/finance_repository.dart';

class GetMemberFinanceSummaryUseCase {
  final FinanceRepository repository;

  GetMemberFinanceSummaryUseCase(this.repository);

  Future<MemberFinanceSummaryEntity> execute() async {
    return await repository.getMemberFinanceSummary();
  }
}
