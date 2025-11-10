/*
  File ini digunakan untuk mengelola dependency injection di aplikasi Dart/Flutter.

  dependency injection berguna agar suatu dependency (class/object) dapat di gunakan dimana aja saja tanpa perlu membuat instance baru secara berulang.

  singkatnya, agar bisa di akses global
 */

import 'dart:core';

import 'package:dio/dio.dart';
import 'package:frontend/core/services/network/dio_client.dart';
import 'package:frontend/core/services/storage/shared_prefrence.dart';
import 'package:frontend/data/datasource/auth_datasource.dart';
import 'package:frontend/presentation/bloc/auth/auth_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/network/api_config.dart';

final GetIt serviceLocator = GetIt.instance;

Future<void> initializeDependencies() async {
  // Contoh pendaftaran dependency
  // serviceLocator.registerLazySingleton<SomeService>(() => SomeServiceImpl());

  /*
  sedikit panduan

    registerSingleton: membuat satu instance yang akan digunakan di seluruh aplikasi.
    registerLazySingleton: membuat satu instance yang akan digunakan di seluruh aplikasi, tapi instance tersebut hanya akan dibuat saat pertama kali di panggil.
    registerFactory: membuat instance baru setiap kali di panggil.
   */

  await _initializeStorage();
  await _initializeNetwork();
  await _initializeDatasource();
  await _initializeBloc();
}

Future<void> _initializeNetwork() async {
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

Future<void> _initializeStorage() async {
  final prefs = await SharedPreferences.getInstance();
  serviceLocator.registerSingleton<SharedPreferences>(prefs);
  serviceLocator.registerSingleton<SharedPrefsStorage>(
    SharedPrefsStorage(prefs),
  );
}

Future<void> _initializeDatasource() async {
  serviceLocator.registerFactory<AuthDatasource>(
    () => AuthDatasource(
      dioClient: serviceLocator<DioClient>(),
      storage: serviceLocator<SharedPrefsStorage>(),
    ),
  );
}

Future<void> _initializeBloc() async {
  serviceLocator.registerLazySingleton<AuthBloc>(
    () => AuthBloc(
      auth: serviceLocator<AuthDatasource>(),
      storage: serviceLocator<SharedPrefsStorage>(),
    ),
  );
}
