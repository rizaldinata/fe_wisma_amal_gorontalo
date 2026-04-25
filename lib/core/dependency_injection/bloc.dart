import 'package:frontend/core/dependency_injection/dependency_injection.dart';
import 'package:frontend/core/services/storage/shared_prefrence.dart';
import 'package:frontend/domain/usecase/auth/check_session_usecase.dart';
import 'package:frontend/domain/usecase/auth/get_permissions_usecase.dart';
import 'package:frontend/domain/usecase/auth/is_logged_in_usecase.dart';
import 'package:frontend/domain/usecase/auth/login_usecase.dart';
import 'package:frontend/domain/usecase/auth/logout_usecase.dart';
import 'package:frontend/domain/usecase/auth/register_usecase.dart';
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
import 'package:frontend/domain/usecase/room/delete_room_usecase.dart';
import 'package:frontend/domain/usecase/room/get_room_schedules_usecase.dart';
import 'package:frontend/domain/usecase/room/get_rooms_usecase.dart';
import 'package:frontend/domain/usecase/room/update_room_usecase.dart';
import 'package:frontend/domain/usecase/room/get_room_by_id_usecase.dart';
import 'package:frontend/domain/usecase/room/delete_room_image_usecase.dart';
import 'package:frontend/domain/usecase/room/upload_room_image_usecase.dart';
import 'package:frontend/presentation/bloc/auth/auth_bloc.dart';
import 'package:frontend/presentation/bloc/detail_room/detail_room_bloc.dart';
import 'package:frontend/presentation/bloc/form_room/form_room_bloc.dart';
import 'package:frontend/presentation/bloc/finance_dashboard/finance_dashboard_bloc.dart';
import 'package:frontend/domain/usecase/finance/get_invoices_usecase.dart';
import 'package:frontend/presentation/bloc/invoice/invoice_bloc.dart';
import 'package:frontend/presentation/bloc/setting/setting_bloc.dart';
import 'package:frontend/domain/usecase/setting/get_settings_usecase.dart';
import 'package:frontend/domain/usecase/setting/update_settings_usecase.dart';
import 'package:frontend/presentation/bloc/expense/expense_bloc.dart';
import 'package:frontend/presentation/bloc/permission/permission_bloc.dart';
import 'package:frontend/presentation/bloc/room_list/room_bloc.dart';
import 'package:frontend/presentation/bloc/room/room_schedule/room_schedule_bloc.dart';
import 'package:frontend/presentation/bloc/maintenance_list/maintenance_list_bloc.dart';
import 'package:frontend/presentation/bloc/maintenance_detail/maintenance_detail_bloc.dart';
import 'package:frontend/presentation/bloc/maintenance_action/maintenance_action_bloc.dart';
import 'package:frontend/domain/usecase/maintenance/get_my_requests_usecase.dart';
import 'package:frontend/domain/usecase/maintenance/get_all_requests_usecase.dart';
import 'package:frontend/domain/usecase/maintenance/get_detail_usecase.dart';
import 'package:frontend/domain/usecase/maintenance/create_request_usecase.dart';
import 'package:frontend/domain/usecase/maintenance/add_update_usecase.dart';
import 'package:frontend/domain/usecase/finance/verify_payment_usecase.dart';
import 'package:frontend/domain/usecase/finance/refund_payment_usecase.dart';
import 'package:frontend/presentation/bloc/payment_verification/payment_verification_bloc.dart';
import 'package:frontend/presentation/bloc/resident/complete_profile/complete_profile_bloc.dart';

import 'package:frontend/domain/usecase/inventory/get_inventories_usecase.dart';
import 'package:frontend/domain/usecase/inventory/inventory_action_usecases.dart';
import 'package:frontend/presentation/bloc/inventory/inventory_action_bloc.dart';
import 'package:frontend/presentation/bloc/inventory/inventory_list_bloc.dart';

import 'package:frontend/domain/usecase/schedule/schedule_usecases.dart';
import 'package:frontend/domain/usecase/schedule/add_schedule_update_usecase.dart';
import 'package:frontend/presentation/bloc/schedule/schedule_list_bloc.dart';
import 'package:frontend/presentation/bloc/schedule/schedule_action_bloc.dart';
import 'package:frontend/presentation/bloc/schedule_detail/schedule_detail_bloc.dart';

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
  
  serviceLocator.registerFactory<RoomScheduleBloc>(
    () => RoomScheduleBloc(
      getRoomSchedulesUseCase: serviceLocator.get<GetRoomSchedulesUseCase>(),
    ),
  );

  serviceLocator.registerFactory<FinanceDashboardBloc>(
    () => FinanceDashboardBloc(
      serviceLocator.get<GetDueInvoicesUseCase>(),
      serviceLocator.get<GetPendingPaymentsUseCase>(),
      serviceLocator.get<GetKpiSummaryUseCase>(),
      serviceLocator.get<GetRevenueChartUseCase>(),
    ),
  );

  serviceLocator.registerFactory<InvoiceBloc>(
    () => InvoiceBloc(
      getInvoicesUseCase: serviceLocator.get<GetInvoicesUseCase>(),
    ),
  );

  serviceLocator.registerFactory<SettingBloc>(
    () => SettingBloc(
      getSettingsUseCase: serviceLocator.get<GetSettingsUseCase>(),
      updateBulkSettingsUseCase: serviceLocator.get<UpdateBulkSettingsUseCase>(),
    ),
  );

  serviceLocator.registerFactory<ExpenseBloc>(
    () => ExpenseBloc(
      getExpensesUseCase: serviceLocator.get<GetExpensesUseCase>(),
      createExpenseUseCase: serviceLocator.get<CreateExpenseUseCase>(),
      updateExpenseUseCase: serviceLocator.get<UpdateExpenseUseCase>(),
      deleteExpenseUseCase: serviceLocator.get<DeleteExpenseUseCase>(),
    ),
  );

  serviceLocator.registerFactory<PaymentVerificationBloc>(
    () => PaymentVerificationBloc(
      getPendingPaymentsUseCase: serviceLocator.get<GetPendingPaymentsUseCase>(),
      verifyPaymentUseCase: serviceLocator.get<VerifyPaymentUseCase>(),
      refundPaymentUseCase: serviceLocator.get<RefundPaymentUseCase>(),
    ),
  );

  // Maintenance Blocs
  serviceLocator.registerFactory<MaintenanceListBloc>(
    () => MaintenanceListBloc(
      getMyRequestsUseCase: serviceLocator.get<GetMyRequestsUseCase>(),
      getAllRequestsUseCase: serviceLocator.get<GetAllRequestsUseCase>(),
    ),
  );

  serviceLocator.registerFactory<MaintenanceDetailBloc>(
    () => MaintenanceDetailBloc(
      getDetailUseCase: serviceLocator.get<GetDetailUseCase>(),
    ),
  );

  serviceLocator.registerFactory<MaintenanceActionBloc>(
    () => MaintenanceActionBloc(
      createRequestUseCase: serviceLocator.get<CreateRequestUseCase>(),
      addUpdateUseCase: serviceLocator.get<AddUpdateUseCase>(),
    ),
  );

  // Inventory Blocs
  serviceLocator.registerFactory<InventoryListBloc>(
    () => InventoryListBloc(
      getInventoriesUseCase: serviceLocator.get<GetInventoriesUseCase>(),
    ),
  );

  serviceLocator.registerFactory<InventoryActionBloc>(
    () => InventoryActionBloc(
      createInventoryUseCase: serviceLocator.get<CreateInventoryUseCase>(),
      updateInventoryUseCase: serviceLocator.get<UpdateInventoryUseCase>(),
      deleteInventoryUseCase: serviceLocator.get<DeleteInventoryUseCase>(),
    ),
  );

  // Schedule BLoCs
  serviceLocator.registerFactory<ScheduleListBloc>(
    () => ScheduleListBloc(
      getSchedulesUseCase: serviceLocator.get<GetSchedulesUseCase>(),
    ),
  );

  serviceLocator.registerFactory<ScheduleActionBloc>(
    () => ScheduleActionBloc(
      createScheduleUseCase: serviceLocator.get<CreateScheduleUseCase>(),
      updateScheduleUseCase: serviceLocator.get<UpdateScheduleUseCase>(),
      deleteScheduleUseCase: serviceLocator.get<DeleteScheduleUseCase>(),
      addScheduleUpdateUseCase: serviceLocator.get<AddScheduleUpdateUseCase>(),
    ),
  );

  serviceLocator.registerFactory<ScheduleDetailBloc>(
    () => ScheduleDetailBloc(
      getScheduleByIdUseCase: serviceLocator.get<GetScheduleByIdUseCase>(),
    ),
  );

  serviceLocator.registerFactory<CompleteProfileBloc>(
    () => CompleteProfileBloc(repository: serviceLocator()),
  );
}
