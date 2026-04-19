import 'package:dio/dio.dart';
import 'package:frontend/core/dependency_injection/dependency_injection.dart';
import 'package:frontend/core/services/network/api_config.dart';
import 'package:frontend/core/services/network/dio_client.dart';
import 'package:frontend/core/services/storage/shared_prefrence.dart';
import 'package:frontend/data/datasource/finance_datasource.dart';
import 'package:frontend/data/datasource/permission_datasource.dart';
import 'package:frontend/data/datasource/room_datasource.dart';
import 'package:frontend/data/datasource/setting_datasource.dart';
import 'package:frontend/data/repository/auth_repository_impl.dart';
import 'package:frontend/data/repository/finance_repository_impl.dart';
import 'package:frontend/data/repository/permission_repository_impl.dart';
import 'package:frontend/data/repository/room_repository_impl.dart';
import 'package:frontend/data/repository/setting_repository_impl.dart';
import 'package:frontend/domain/repository/auth_repository.dart';
import 'package:frontend/domain/repository/finance_repository.dart';
import 'package:frontend/domain/repository/permission_repository.dart';
import 'package:frontend/domain/repository/room_repository.dart';
import 'package:frontend/data/repository/maintenance_repository_impl.dart';
import 'package:frontend/domain/repository/maintenance_repository.dart';
import 'package:frontend/data/datasource/maintenance_remote_datasource.dart';
import 'package:frontend/domain/repository/setting_repository.dart';

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

  serviceLocator.registerLazySingleton<FinanceRepository>(
    () => FinanceRepositoryImpl(
      remoteDatasource: serviceLocator.get<FinanceRemoteDatasource>(),
    ),
  );

  serviceLocator.registerLazySingleton<SettingRepository>(
    () => SettingRepositoryImpl(
      remoteDatasource: serviceLocator.get<SettingDatasource>(),
    ),
  );

  serviceLocator.registerFactory<MaintenanceRepository>(
    () => MaintenanceRepositoryImpl(
      defaultDataSource: serviceLocator<MaintenanceRemoteDataSource>(),
    ),
  );
}
