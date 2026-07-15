import '../../entity/finance/invoice_entity.dart';
import '../../repository/finance_repository.dart';

class GetMemberInvoicesUseCase {
  final FinanceRepository repository;

  GetMemberInvoicesUseCase(this.repository);

  Future<List<InvoiceEntity>> execute() async {
    return await repository.getMemberInvoices();
  }
}
