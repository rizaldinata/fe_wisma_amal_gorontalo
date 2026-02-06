import 'package:frontend/core/dependency_injection/dependency_injection.dart';
import 'package:frontend/core/services/storage/shared_prefrence.dart';
import 'package:frontend/data/repository/auth_repository.dart';
import 'package:frontend/data/repository/permission_repository.dart';
import 'package:frontend/data/repository/room_repository.dart';
import 'package:frontend/presentation/bloc/auth/auth_bloc.dart';
import 'package:frontend/presentation/bloc/permission/permission_bloc.dart';
import 'package:frontend/presentation/bloc/room_list/room_bloc.dart';

Future<void> initializeBloc() async {
  serviceLocator.registerFactory<AuthBloc>(
    () => AuthBloc(
      auth: serviceLocator.get<AuthRepository>(),
      storage: serviceLocator.get<SharedPrefsStorage>(),
    ),
  );

  serviceLocator.registerFactory<PermissionBloc>(
    () => PermissionBloc(serviceLocator.get<PermissionRepository>()),
  );
}
