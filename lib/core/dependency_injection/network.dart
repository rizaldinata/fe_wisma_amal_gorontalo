
import 'package:dio/dio.dart';
import 'package:frontend/core/dependency_injection/dependency_injection.dart';
import 'package:frontend/core/services/network/api_config.dart';
import 'package:frontend/core/services/network/dio_client.dart';
import 'package:frontend/core/services/storage/shared_prefrence.dart';

Future<void> initializeNetwork() async {
  serviceLocator.registerSingleton<Dio>(Dio());
  serviceLocator.registerSingleton<ApiConfig>(ApiConfig.production().getUrl());
  serviceLocator.registerSingleton(
    DioClient(
      apiConfig: serviceLocator<ApiConfig>(),
      SharedPreferences: serviceLocator<SharedPrefsStorage>(),
      dio: serviceLocator<Dio>(),
    ),
  );
}