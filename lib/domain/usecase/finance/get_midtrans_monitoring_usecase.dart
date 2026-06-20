import '../../entity/finance/midtrans_monitoring_entity.dart';
import '../../repository/finance_repository.dart';

class GetMidtransMonitoringUseCase {
  final FinanceRepository repository;
  GetMidtransMonitoringUseCase(this.repository);
  Future<MidtransMonitoringEntity> call() async => await repository.getMidtransMonitoring();
}
