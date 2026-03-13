import '../../repository/finance_repository.dart';
import '../../entity/finance/revenue_entity.dart';

class GetRevenueChartUseCase {
  final FinanceRepository repository;
  GetRevenueChartUseCase(this.repository);
  Future<List<RevenueEntity>> call() async =>
      await repository.getRevenueChart();
}
