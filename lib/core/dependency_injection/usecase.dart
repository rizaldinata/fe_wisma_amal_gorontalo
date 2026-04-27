import 'package:frontend/core/dependency_injection/dependency_injection.dart';
import 'package:frontend/domain/repository/auth_repository.dart';
import 'package:frontend/domain/repository/finance_repository.dart';
import 'package:frontend/domain/repository/permission_repository.dart';
import 'package:frontend/domain/repository/room_repository.dart';
import 'package:frontend/domain/repository/setting_repository.dart';
import 'package:frontend/domain/repository/user_repository.dart';
import 'package:frontend/domain/repository/profile_repository.dart';
import 'package:frontend/domain/usecase/user/get_all_users_usecase.dart';
import 'package:frontend/domain/usecase/user/update_user_usecase.dart';
import 'package:frontend/domain/usecase/user/delete_user_usecase.dart';
import 'package:frontend/domain/usecase/user/create_user_usecase.dart';
import 'package:frontend/domain/usecase/profile/profile_usecases.dart';
import 'package:frontend/domain/usecase/auth/check_session_usecase.dart';
import 'package:frontend/domain/usecase/auth/get_permissions_usecase.dart';
import 'package:frontend/domain/usecase/auth/is_logged_in_usecase.dart';
import 'package:frontend/domain/usecase/auth/login_usecase.dart';
import 'package:frontend/domain/usecase/auth/logout_usecase.dart';
import 'package:frontend/domain/usecase/auth/register_usecase.dart';
import 'package:frontend/domain/usecase/finance/get_invoices_usecase.dart';
import 'package:frontend/domain/usecase/setting/get_settings_usecase.dart';
import 'package:frontend/domain/usecase/setting/update_settings_usecase.dart';
import 'package:frontend/domain/usecase/finance/get_due_invoices_usecase.dart';
import 'package:frontend/domain/usecase/finance/get_kpi_summary_usecase.dart';
import 'package:frontend/domain/usecase/finance/get_pending_payments_usecase.dart';
import 'package:frontend/domain/usecase/finance/get_revenue_chart_usecase.dart';
import 'package:frontend/domain/usecase/finance/get_expenses_usecase.dart';
import 'package:frontend/domain/usecase/finance/create_expense_usecase.dart';
import 'package:frontend/domain/usecase/finance/update_expense_usecase.dart';
import 'package:frontend/domain/usecase/finance/delete_expense_usecase.dart';
import 'package:frontend/domain/usecase/permission/create_permission_usecase.dart';
import 'package:frontend/domain/usecase/permission/delete_permission_usecase.dart';
import 'package:frontend/domain/usecase/permission/get_permission_list_usecase.dart';
import 'package:frontend/domain/usecase/permission/update_permission_usecase.dart';
import 'package:frontend/domain/usecase/room/create_room_usecase.dart';
import 'package:frontend/domain/usecase/room/delete_room_image_usecase.dart';
import 'package:frontend/domain/usecase/room/delete_room_usecase.dart';
import 'package:frontend/domain/usecase/room/get_room_by_id_usecase.dart';
import 'package:frontend/domain/usecase/room/get_room_schedules_usecase.dart';
import 'package:frontend/domain/usecase/room/get_rooms_usecase.dart';
import 'package:frontend/domain/usecase/room/update_room_usecase.dart';
import 'package:frontend/domain/usecase/room/upload_room_image_usecase.dart';
import 'package:frontend/domain/usecase/maintenance/get_my_requests_usecase.dart';
import 'package:frontend/domain/usecase/maintenance/get_all_requests_usecase.dart';
import 'package:frontend/domain/usecase/maintenance/get_detail_usecase.dart';
import 'package:frontend/domain/usecase/maintenance/create_request_usecase.dart';
import 'package:frontend/domain/usecase/maintenance/add_update_usecase.dart';
import 'package:frontend/domain/repository/maintenance_repository.dart';
import 'package:frontend/domain/usecase/finance/verify_payment_usecase.dart';
import 'package:frontend/domain/usecase/finance/refund_payment_usecase.dart';

import 'package:frontend/domain/repository/inventory_repository.dart';
import 'package:frontend/domain/usecase/inventory/get_inventories_usecase.dart';
import 'package:frontend/domain/usecase/inventory/inventory_action_usecases.dart';
import 'package:frontend/domain/repository/schedule_repository.dart';
import 'package:frontend/domain/usecase/schedule/schedule_usecases.dart';
import 'package:frontend/domain/usecase/schedule/add_schedule_update_usecase.dart';
import 'package:frontend/domain/repository/resident_repository.dart';
import 'package:frontend/domain/usecase/resident/get_admin_residents_usecase.dart';

Future<void> initializeUseCase() async {
  // Auth UseCases
  serviceLocator.registerFactory(
    () => CheckSessionUseCase(serviceLocator.get<AuthRepository>()),
  );
  serviceLocator.registerFactory(
    () => GetPermissionsUseCase(serviceLocator.get<AuthRepository>()),
  );
  serviceLocator.registerFactory(
    () => LoginUseCase(serviceLocator.get<AuthRepository>()),
  );
  serviceLocator.registerFactory(
    () => RegisterUseCase(serviceLocator.get<AuthRepository>()),
  );
  serviceLocator.registerFactory(
    () => LogoutUseCase(serviceLocator.get<AuthRepository>()),
  );
  serviceLocator.registerFactory(
    () => IsLoggedInUseCase(serviceLocator.get<AuthRepository>()),
  );

  // Room UseCases
  serviceLocator.registerFactory(
    () => GetRoomsUseCase(serviceLocator.get<RoomRepository>()),
  );
  serviceLocator.registerFactory(
    () => GetRoomSchedulesUseCase(serviceLocator.get<RoomRepository>()),
  );
  serviceLocator.registerFactory(
    () => CreateRoomUseCase(serviceLocator.get<RoomRepository>()),
  );
  serviceLocator.registerFactory(
    () => GetRoomByIdUseCase(serviceLocator.get<RoomRepository>()),
  );
  serviceLocator.registerFactory(
    () => UpdateRoomUseCase(serviceLocator.get<RoomRepository>()),
  );
  serviceLocator.registerFactory(
    () => DeleteRoomUseCase(serviceLocator.get<RoomRepository>()),
  );
  serviceLocator.registerFactory(
    () => UploadRoomImageUseCase(serviceLocator.get<RoomRepository>()),
  );
  serviceLocator.registerFactory(
    () => DeleteRoomImageUseCase(serviceLocator.get<RoomRepository>()),
  );

  // Permission UseCases
  serviceLocator.registerFactory(
    () => GetPermissionListUseCase(serviceLocator.get<PermissionRepository>()),
  );
  serviceLocator.registerFactory(
    () => CreatePermissionUseCase(serviceLocator.get<PermissionRepository>()),
  );
  serviceLocator.registerFactory(
    () => UpdatePermissionUseCase(serviceLocator.get<PermissionRepository>()),
  );
  serviceLocator.registerFactory(
    () => DeletePermissionUseCase(serviceLocator.get<PermissionRepository>()),
  );

  // Finance UseCases
  serviceLocator.registerFactory(
    () => GetInvoicesUseCase(serviceLocator.get<FinanceRepository>()),
  );
  serviceLocator.registerFactory(
    () => GetDueInvoicesUseCase(serviceLocator.get<FinanceRepository>()),
  );
  serviceLocator.registerFactory(
    () => GetPendingPaymentsUseCase(serviceLocator.get<FinanceRepository>()),
  );
  serviceLocator.registerFactory(
    () => GetKpiSummaryUseCase(serviceLocator.get<FinanceRepository>()),
  );
  serviceLocator.registerFactory(
    () => GetRevenueChartUseCase(serviceLocator.get<FinanceRepository>()),
  );
  serviceLocator.registerFactory(
    () => GetExpensesUseCase(serviceLocator.get<FinanceRepository>()),
  );
  serviceLocator.registerFactory(
    () => CreateExpenseUseCase(serviceLocator.get<FinanceRepository>()),
  );
  serviceLocator.registerFactory(
    () => UpdateExpenseUseCase(serviceLocator.get<FinanceRepository>()),
  );
  serviceLocator.registerFactory(
    () => DeleteExpenseUseCase(serviceLocator.get<FinanceRepository>()),
  );
  serviceLocator.registerFactory(
    () => VerifyPaymentUseCase(serviceLocator.get<FinanceRepository>()),
  );  
  serviceLocator.registerFactory(
    () => RefundPaymentUseCase(serviceLocator.get<FinanceRepository>()),
  );

  // Setting UseCases
  serviceLocator.registerFactory(
    () => GetSettingsUseCase(serviceLocator.get<SettingRepository>()),
  );
  serviceLocator.registerFactory(
    () => UpdateBulkSettingsUseCase(serviceLocator.get<SettingRepository>()),
  );

  // Maintenance UseCases
  serviceLocator.registerFactory(
    () => GetMyRequestsUseCase(serviceLocator.get<MaintenanceRepository>()),
  );
  serviceLocator.registerFactory(
    () => GetAllRequestsUseCase(serviceLocator.get<MaintenanceRepository>()),
  );
  serviceLocator.registerFactory(
    () => GetDetailUseCase(serviceLocator.get<MaintenanceRepository>()),
  );
  serviceLocator.registerFactory(
    () => CreateRequestUseCase(serviceLocator.get<MaintenanceRepository>()),
  );
  serviceLocator.registerFactory(
    () => AddUpdateUseCase(serviceLocator.get<MaintenanceRepository>()),
  );

  // Inventory UseCases
  serviceLocator.registerFactory(
    () => GetInventoriesUseCase(serviceLocator.get<InventoryRepository>()),
  );
  serviceLocator.registerFactory(
    () => GetInventoryByIdUseCase(serviceLocator.get<InventoryRepository>()),
  );
  serviceLocator.registerFactory(
    () => CreateInventoryUseCase(serviceLocator.get<InventoryRepository>()),
  );
  serviceLocator.registerFactory(
    () => UpdateInventoryUseCase(serviceLocator.get<InventoryRepository>()),
  );
  serviceLocator.registerFactory(
    () => DeleteInventoryUseCase(serviceLocator.get<InventoryRepository>()),
  );

  // Schedule UseCases
  serviceLocator.registerFactory(
    () => GetSchedulesUseCase(serviceLocator.get<ScheduleRepository>()),
  );
  serviceLocator.registerFactory(
    () => GetScheduleByIdUseCase(serviceLocator.get<ScheduleRepository>()),
  );
  serviceLocator.registerFactory(
    () => CreateScheduleUseCase(serviceLocator.get<ScheduleRepository>()),
  );
  serviceLocator.registerFactory(
    () => UpdateScheduleUseCase(serviceLocator.get<ScheduleRepository>()),
  );
  serviceLocator.registerFactory(
    () => DeleteScheduleUseCase(serviceLocator.get<ScheduleRepository>()),
  );
  serviceLocator.registerFactory(
    () => AddScheduleUpdateUseCase(serviceLocator.get<ScheduleRepository>()),
  );
  
  // User Management UseCases
  serviceLocator.registerFactory(
    () => GetAllUsersUseCase(serviceLocator.get<UserRepository>()),
  );
  serviceLocator.registerFactory(
    () => UpdateUserUseCase(serviceLocator.get<UserRepository>()),
  );
  serviceLocator.registerFactory(
    () => DeleteUserUseCase(serviceLocator.get<UserRepository>()),
  );
  serviceLocator.registerFactory(
    () => CreateUserUseCase(serviceLocator.get<UserRepository>()),
  );

  // Profile UseCases
  serviceLocator.registerFactory(
    () => GetProfileUseCase(serviceLocator.get<ProfileRepository>()),
  );
  serviceLocator.registerFactory(
    () => UpdateProfileUseCase(serviceLocator.get<ProfileRepository>()),
  );
  serviceLocator.registerFactory(
    () => ChangePasswordUseCase(serviceLocator.get<ProfileRepository>()),
  );

  // Resident UseCases
  serviceLocator.registerFactory(
    () => GetAdminResidentsUseCase(serviceLocator.get<ResidentRepository>()),
  );
}
