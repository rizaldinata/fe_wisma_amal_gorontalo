import '../../entity/finance/invoice_entity.dart';
import '../../repository/finance_repository.dart';

class InitiatePerpanjangManualUseCase {
  final FinanceRepository repository;

  InitiatePerpanjangManualUseCase(this.repository);

  Future<InvoiceEntity> execute(int leaseId, int durationMonths) async {
    return await repository.initiatePerpanjangManual(leaseId, durationMonths);
  }
}
