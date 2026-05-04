import '../../repository/finance_repository.dart';

class ExtendLeaseUseCase {
  final FinanceRepository repository;

  ExtendLeaseUseCase(this.repository);

  Future<void> execute(int leaseId, int durationMonths) async {
    return await repository.extendLease(leaseId, durationMonths);
  }
}
