import '../../repository/finance_repository.dart';
import '../../entity/finance/invoice_entity.dart';

class GetDueInvoicesUseCase {
  final FinanceRepository repository;

  GetDueInvoicesUseCase(this.repository);

  Future<List<InvoiceEntity>> call() async {
    return await repository.getDueInvoices();
  }
}
