import '../../entity/finance/invoice_entity.dart';
import '../../repository/finance_repository.dart';

class GetMemberInvoiceByIdUseCase {
  final FinanceRepository _repository;
  GetMemberInvoiceByIdUseCase(this._repository);

  Future<InvoiceEntity> execute(int id) => _repository.getMemberInvoiceById(id);
}
