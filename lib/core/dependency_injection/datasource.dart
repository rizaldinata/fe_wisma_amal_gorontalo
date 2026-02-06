import 'package:frontend/core/dependency_injection/dependency_injection.dart';
import 'package:frontend/core/services/network/dio_client.dart';
import 'package:frontend/data/datasource/auth_datasource.dart';
import 'package:frontend/data/datasource/permission_datasource.dart';
import 'package:frontend/data/datasource/room_datasource.dart';

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
}
