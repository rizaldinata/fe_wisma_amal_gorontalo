import 'package:frontend/domain/entities/dashboard_entity.dart';

abstract class DashboardRepository {
  Future<DashboardEntity> getAdminDashboard();
  Future<ResidentDashboardEntity> getResidentDashboard();
}
