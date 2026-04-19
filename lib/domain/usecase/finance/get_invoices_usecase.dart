import 'package:frontend/domain/repository/finance_repository.dart';
import 'package:frontend/domain/entity/finance/invoice_entity.dart';

class GetInvoicesUseCase {
  final FinanceRepository repository;

  GetInvoicesUseCase(this.repository);

  Future<List<InvoiceEntity>> call() async {
    return await repository.getInvoices();
  }
}
