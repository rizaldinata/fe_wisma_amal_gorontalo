import 'package:frontend/core/dependency_injection/dependency_injection.dart';
import 'package:frontend/core/services/storage/shared_prefrence.dart';
import 'package:frontend/domain/usecase/auth/check_session_usecase.dart';
import 'package:frontend/domain/usecase/auth/get_permissions_usecase.dart';
import 'package:frontend/domain/usecase/auth/is_logged_in_usecase.dart';
import 'package:frontend/domain/usecase/auth/login_usecase.dart';
import 'package:frontend/domain/usecase/auth/logout_usecase.dart';
import 'package:frontend/domain/usecase/auth/register_usecase.dart';
import 'package:frontend/domain/usecase/finance/get_due_invoices_usecase.dart';
import 'package:frontend/domain/usecase/finance/get_pending_payments_usecase.dart';
import 'package:frontend/domain/usecase/permission/create_permission_usecase.dart';
import 'package:frontend/domain/usecase/permission/delete_permission_usecase.dart';
import 'package:frontend/domain/usecase/permission/get_permission_list_usecase.dart';
import 'package:frontend/domain/usecase/permission/update_permission_usecase.dart';
import 'package:frontend/domain/usecase/room/create_room_usecase.dart';
import 'package:frontend/domain/usecase/room/delete_room_usecase.dart';
import 'package:frontend/domain/usecase/room/get_rooms_usecase.dart';
import 'package:frontend/domain/usecase/room/update_room_usecase.dart';
import 'package:frontend/domain/usecase/room/get_room_by_id_usecase.dart';
import 'package:frontend/domain/usecase/room/delete_room_image_usecase.dart';
import 'package:frontend/domain/usecase/room/upload_room_image_usecase.dart';
import 'package:frontend/presentation/bloc/auth/auth_bloc.dart';
import 'package:frontend/presentation/bloc/detail_room/detail_room_bloc.dart';
import 'package:frontend/presentation/bloc/finance_dashboard/finance_dashboard_bloc.dart'
    show FinanceDashboardBloc;
import 'package:frontend/presentation/bloc/form_room/form_room_bloc.dart';
import 'package:frontend/presentation/bloc/permission/permission_bloc.dart';
import 'package:frontend/presentation/bloc/room_list/room_bloc.dart';

Future<void> initializeBloc() async {
  serviceLocator.registerFactory<AuthBloc>(
    () => AuthBloc(
      checkSessionUseCase: serviceLocator.get<CheckSessionUseCase>(),
      getPermissionsUseCase: serviceLocator.get<GetPermissionsUseCase>(),
      loginUseCase: serviceLocator.get<LoginUseCase>(),
      registerUseCase: serviceLocator.get<RegisterUseCase>(),
      logoutUseCase: serviceLocator.get<LogoutUseCase>(),
      isLoggedInUseCase: serviceLocator.get<IsLoggedInUseCase>(),
      storage: serviceLocator.get<SharedPrefsStorage>(),
    ),
  );

  serviceLocator.registerFactory<PermissionBloc>(
    () => PermissionBloc(
      getPermissionsUseCase: serviceLocator.get<GetPermissionListUseCase>(),
      createPermissionUseCase: serviceLocator.get<CreatePermissionUseCase>(),
      updatePermissionUseCase: serviceLocator.get<UpdatePermissionUseCase>(),
      deletePermissionUseCase: serviceLocator.get<DeletePermissionUseCase>(),
    ),
  );

  serviceLocator.registerFactory<RoomBloc>(
    () => RoomBloc(
      getRoomsUseCase: serviceLocator.get<GetRoomsUseCase>(),
      createRoomUseCase: serviceLocator.get<CreateRoomUseCase>(),
      updateRoomUseCase: serviceLocator.get<UpdateRoomUseCase>(),
      deleteRoomUseCase: serviceLocator.get<DeleteRoomUseCase>(),
    ),
  );

  serviceLocator.registerFactory<DetailRoomBloc>(
    () => DetailRoomBloc(
      getRoomByIdUseCase: serviceLocator.get<GetRoomByIdUseCase>(),
      updateRoomUseCase: serviceLocator.get<UpdateRoomUseCase>(),
    ),
  );

  serviceLocator.registerFactory<FormRoomBloc>(
    () => FormRoomBloc(
      createRoomUseCase: serviceLocator.get<CreateRoomUseCase>(),
      getRoomByIdUseCase: serviceLocator.get<GetRoomByIdUseCase>(),
      updateRoomUseCase: serviceLocator.get<UpdateRoomUseCase>(),
      deleteRoomImageUseCase: serviceLocator.get<DeleteRoomImageUseCase>(),
      uploadRoomImageUseCase: serviceLocator.get<UploadRoomImageUseCase>(),
    ),
  );

  serviceLocator.registerFactory<FinanceDashboardBloc>(
    () => FinanceDashboardBloc(
      serviceLocator.get<GetDueInvoicesUseCase>(),
      serviceLocator.get<GetPendingPaymentsUseCase>(),
    ),
  );
}
