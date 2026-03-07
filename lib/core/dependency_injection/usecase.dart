import 'package:frontend/core/dependency_injection/dependency_injection.dart';
import 'package:frontend/domain/repository/auth_repository.dart';
import 'package:frontend/domain/repository/permission_repository.dart';
import 'package:frontend/domain/repository/room_repository.dart';
import 'package:frontend/domain/usecase/auth/check_session_usecase.dart';
import 'package:frontend/domain/usecase/auth/get_permissions_usecase.dart';
import 'package:frontend/domain/usecase/auth/is_logged_in_usecase.dart';
import 'package:frontend/domain/usecase/auth/login_usecase.dart';
import 'package:frontend/domain/usecase/auth/logout_usecase.dart';
import 'package:frontend/domain/usecase/auth/register_usecase.dart';
import 'package:frontend/domain/usecase/permission/create_permission_usecase.dart';
import 'package:frontend/domain/usecase/permission/delete_permission_usecase.dart';
import 'package:frontend/domain/usecase/permission/get_permission_list_usecase.dart';
import 'package:frontend/domain/usecase/permission/update_permission_usecase.dart';
import 'package:frontend/domain/usecase/room/create_room_usecase.dart';
import 'package:frontend/domain/usecase/room/delete_room_image_usecase.dart';
import 'package:frontend/domain/usecase/room/delete_room_usecase.dart';
import 'package:frontend/domain/usecase/room/get_room_by_id_usecase.dart';
import 'package:frontend/domain/usecase/room/get_rooms_usecase.dart';
import 'package:frontend/domain/usecase/room/update_room_usecase.dart';
import 'package:frontend/domain/usecase/room/upload_room_image_usecase.dart';

Future<void> initializeUseCase() async {
  // Auth UseCases
  serviceLocator.registerFactory(() => CheckSessionUseCase(serviceLocator.get<AuthRepository>()));
  serviceLocator.registerFactory(() => GetPermissionsUseCase(serviceLocator.get<AuthRepository>()));
  serviceLocator.registerFactory(() => LoginUseCase(serviceLocator.get<AuthRepository>()));
  serviceLocator.registerFactory(() => RegisterUseCase(serviceLocator.get<AuthRepository>()));
  serviceLocator.registerFactory(() => LogoutUseCase(serviceLocator.get<AuthRepository>()));
  serviceLocator.registerFactory(() => IsLoggedInUseCase(serviceLocator.get<AuthRepository>()));

  // Room UseCases
  serviceLocator.registerFactory(() => GetRoomsUseCase(serviceLocator.get<RoomRepository>()));
  serviceLocator.registerFactory(() => CreateRoomUseCase(serviceLocator.get<RoomRepository>()));
  serviceLocator.registerFactory(() => GetRoomByIdUseCase(serviceLocator.get<RoomRepository>()));
  serviceLocator.registerFactory(() => UpdateRoomUseCase(serviceLocator.get<RoomRepository>()));
  serviceLocator.registerFactory(() => DeleteRoomUseCase(serviceLocator.get<RoomRepository>()));
  serviceLocator.registerFactory(() => UploadRoomImageUseCase(serviceLocator.get<RoomRepository>()));
  serviceLocator.registerFactory(() => DeleteRoomImageUseCase(serviceLocator.get<RoomRepository>()));

  // Permission UseCases
  serviceLocator.registerFactory(() => GetPermissionListUseCase(serviceLocator.get<PermissionRepository>()));
  serviceLocator.registerFactory(() => CreatePermissionUseCase(serviceLocator.get<PermissionRepository>()));
  serviceLocator.registerFactory(() => UpdatePermissionUseCase(serviceLocator.get<PermissionRepository>()));
  serviceLocator.registerFactory(() => DeletePermissionUseCase(serviceLocator.get<PermissionRepository>()));
}
