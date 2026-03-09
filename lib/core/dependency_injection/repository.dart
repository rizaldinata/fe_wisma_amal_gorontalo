import 'package:dio/dio.dart';
import 'package:frontend/core/dependency_injection/dependency_injection.dart';
import 'package:frontend/core/services/network/api_config.dart';
import 'package:frontend/core/services/network/dio_client.dart';
import 'package:frontend/core/services/storage/shared_prefrence.dart';
import 'package:frontend/data/datasource/permission_datasource.dart';
import 'package:frontend/data/datasource/room_datasource.dart';
import 'package:frontend/data/repository/auth_repository_impl.dart';
import 'package:frontend/data/repository/permission_repository_impl.dart';
import 'package:frontend/data/repository/room_repository_impl.dart';
import 'package:frontend/domain/repository/auth_repository.dart';
import 'package:frontend/domain/repository/permission_repository.dart';
import 'package:frontend/domain/repository/room_repository.dart';

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
}
