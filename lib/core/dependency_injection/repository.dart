import 'package:dio/dio.dart';
import 'package:frontend/core/dependency_injection/dependency_injection.dart';
import 'package:frontend/core/services/network/api_config.dart';
import 'package:frontend/core/services/network/dio_client.dart';
import 'package:frontend/core/services/storage/shared_prefrence.dart';
import 'package:frontend/data/datasource/finance_datasource.dart';
import 'package:frontend/data/datasource/permission_datasource.dart';
import 'package:frontend/data/datasource/room_datasource.dart';
import 'package:frontend/data/repository/auth_repository_impl.dart';
import 'package:frontend/data/repository/finance_repository_impl.dart';
import 'package:frontend/data/repository/permission_repository_impl.dart';
import 'package:frontend/data/repository/room_repository_impl.dart';
import 'package:frontend/domain/repository/auth_repository.dart';
import 'package:frontend/domain/repository/finance_repository.dart';
import 'package:frontend/domain/repository/permission_repository.dart';
import 'package:frontend/domain/repository/room_repository.dart';
import 'package:frontend/data/repository/maintenance_repository_impl.dart';
import 'package:frontend/domain/repository/maintenance_repository.dart';
import 'package:frontend/data/datasource/maintenance_remote_datasource.dart';
import 'package:frontend/data/repository/inventory_repository_impl.dart';
import 'package:frontend/domain/repository/inventory_repository.dart';
import 'package:frontend/data/datasource/inventory_datasource.dart';
import 'package:frontend/data/repository/schedule_repository_impl.dart';
import 'package:frontend/domain/repository/schedule_repository.dart';
import 'package:frontend/data/datasource/schedule_datasource.dart';

Future<void> initializeRepository() async {
  serviceLocator.registerFactory<AuthRepository>(
    () => AuthRepositoryImpl(
      datasource: serviceLocator.get(),
      storage: serviceLocator.get(),
      secureStorage: serviceLocator.get(),
    ),
  );
  serviceLocator.registerFactory<RoomRepository>(
    () => RoomRepositoryImpl(datasource: serviceLocator.get<RoomDatasource>()),
  );

  serviceLocator.registerFactory<PermissionRepository>(
    () => PermissionRepositoryImpl(
      datasource: serviceLocator<PermissionDatasource>(),
    ),
  );

  serviceLocator.registerFactory<FinanceRepository>(
    () => FinanceRepositoryImpl(
      remoteDatasource: serviceLocator<FinanceRemoteDatasource>(),
    ),
  );

  serviceLocator.registerFactory<MaintenanceRepository>(
    () => MaintenanceRepositoryImpl(
      defaultDataSource: serviceLocator<MaintenanceRemoteDataSource>(),
    ),
  );

  serviceLocator.registerFactory<InventoryRepository>(
    () => InventoryRepositoryImpl(
      remoteDatasource: serviceLocator<InventoryRemoteDatasource>(),
    ),
  );

  serviceLocator.registerFactory<ScheduleRepository>(
    () => ScheduleRepositoryImpl(
      remoteDatasource: serviceLocator<ScheduleRemoteDatasource>(),
    ),
  );
}
