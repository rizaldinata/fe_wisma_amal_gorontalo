import '../../repository/finance_repository.dart';
import '../../entity/finance/kpi_entity.dart';

class GetKpiSummaryUseCase {
  final FinanceRepository repository;
  GetKpiSummaryUseCase(this.repository);
  Future<KpiEntity> call() async => await repository.getKpiSummary();
}
