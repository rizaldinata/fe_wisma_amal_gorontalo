import 'package:frontend/data/datasource/dashboard_datasource.dart';
import 'package:frontend/domain/entities/dashboard_entity.dart';
import 'package:frontend/domain/repository/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardDatasource remoteDataSource;

  DashboardRepositoryImpl({required this.remoteDataSource});

  @override
  Future<DashboardEntity> getAdminDashboard() async {
    try {
      final response = await remoteDataSource.getAdminDashboard();
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ResidentDashboardEntity> getResidentDashboard() async {
    try {
      final response = await remoteDataSource.getResidentDashboard();
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}
