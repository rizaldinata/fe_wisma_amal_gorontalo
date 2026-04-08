/*
  File ini digunakan untuk mengelola dependency injection di aplikasi Dart/Flutter.

  dependency injection berguna agar suatu dependency (class/object) dapat di gunakan dimana aja saja tanpa perlu membuat instance baru secara berulang.

  singkatnya, agar bisa di akses global
 */

import 'dart:core';

import 'package:frontend/core/dependency_injection/bloc.dart';
import 'package:frontend/core/dependency_injection/datasource.dart';
import 'package:frontend/core/dependency_injection/network.dart';
import 'package:frontend/core/dependency_injection/repository.dart';
import 'package:frontend/core/dependency_injection/storage.dart';
import 'package:frontend/core/dependency_injection/usecase.dart';
import 'package:get_it/get_it.dart';

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

  await initializeStorage();
  await initializeNetwork();
  await initializeDatasource();
  await initializeRepository();
  await initializeUseCase();
  await initializeBloc();
}
