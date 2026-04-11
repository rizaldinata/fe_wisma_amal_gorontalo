import 'package:frontend/core/dependency_injection/dependency_injection.dart';
import 'package:frontend/core/services/network/dio_client.dart';
import 'package:frontend/data/datasource/auth_datasource.dart';
import 'package:frontend/data/datasource/finance_datasource.dart';
import 'package:frontend/data/datasource/permission_datasource.dart';
import 'package:frontend/data/datasource/room_datasource.dart';
import 'package:frontend/data/datasource/maintenance_remote_datasource.dart';
import 'package:frontend/data/datasource/inventory_datasource.dart';

Future<void> initializeDatasource() async {
  serviceLocator.registerFactory<AuthDatasource>(
    () => AuthDatasource(dioClient: serviceLocator<DioClient>()),
  );

  serviceLocator.registerFactory<PermissionDatasource>(
    () => PermissionDatasource(dioClient: serviceLocator<DioClient>()),
  );

  serviceLocator.registerFactory<RoomDatasource>(
    () => RoomDatasource(dioClient: serviceLocator<DioClient>()),
  );

  serviceLocator.registerFactory<FinanceRemoteDatasource>(
    () => FinanceRemoteDatasourceImpl(serviceLocator<DioClient>()),
  );

  serviceLocator.registerFactory<MaintenanceRemoteDataSource>(
    () => MaintenanceRemoteDataSourceImpl(dioClient: serviceLocator<DioClient>()),
  );

  serviceLocator.registerFactory<InventoryRemoteDatasource>(
    () => InventoryRemoteDatasourceImpl(dioClient: serviceLocator<DioClient>()),
  );
}
