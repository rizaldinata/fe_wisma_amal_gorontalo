import '../../repository/finance_repository.dart';
import '../../entity/finance/kpi_entity.dart';

class GetKpiSummaryUseCase {
  final FinanceRepository repository;
  GetKpiSummaryUseCase(this.repository);
  Future<KpiEntity> call({int? month, int? year}) async => await repository.getKpiSummary(month: month, year: year);
}
