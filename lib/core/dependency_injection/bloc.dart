import 'package:frontend/core/dependency_injection/dependency_injection.dart';
import 'package:frontend/core/services/storage/shared_prefrence.dart';
import 'package:frontend/data/datasource/auth_datasource.dart';
import 'package:frontend/data/repository/auth_repository.dart';
import 'package:frontend/presentation/bloc/auth/auth_bloc.dart';

Future<void> initializeBloc() async {
  serviceLocator.registerLazySingleton<AuthBloc>(
    () => AuthBloc(
      auth: serviceLocator<AuthRepository>(),
      storage: serviceLocator<SharedPrefsStorage>(),
    ),
  );
}