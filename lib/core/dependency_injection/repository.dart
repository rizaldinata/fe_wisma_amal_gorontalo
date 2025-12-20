import 'package:dio/dio.dart';
import 'package:frontend/core/dependency_injection/dependency_injection.dart';
import 'package:frontend/core/services/network/api_config.dart';
import 'package:frontend/core/services/network/dio_client.dart';
import 'package:frontend/core/services/storage/shared_prefrence.dart';
import 'package:frontend/data/repository/auth_repository.dart';

Future<void> initializeRepository() async {
  serviceLocator.registerFactory(
    () => AuthRepository(
      datasource: serviceLocator.get(),
      storage: serviceLocator.get(),
    ),
  );
}
