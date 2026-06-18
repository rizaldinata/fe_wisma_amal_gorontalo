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
import 'package:frontend/domain/usecase/finance/get_all_payments_usecase.dart';
import 'package:frontend/domain/usecase/finance/get_revenue_chart_usecase.dart';
import 'package:frontend/domain/usecase/finance/get_expenses_usecase.dart';
import 'package:frontend/domain/usecase/finance/create_expense_usecase.dart';
import 'package:frontend/domain/usecase/finance/update_expense_usecase.dart';
import 'package:frontend/domain/usecase/finance/delete_expense_usecase.dart';
import 'package:frontend/domain/usecase/permission/create_permission_usecase.dart';
import 'package:frontend/domain/usecase/permission/delete_permission_usecase.dart';
import 'package:frontend/domain/usecase/permission/get_permission_list_usecase.dart';
import 'package:frontend/domain/usecase/permission/update_permission_usecase.dart';
import 'package:frontend/domain/usecase/role/role_usecases.dart';
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
import 'package:frontend/presentation/bloc/role/role_bloc.dart';
import 'package:frontend/presentation/bloc/setting/setting_bloc.dart';
import 'package:frontend/domain/usecase/setting/get_settings_usecase.dart';
import 'package:frontend/domain/usecase/setting/update_settings_usecase.dart';
import 'package:frontend/domain/usecase/setting/get_public_settings_usecase.dart';
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
import 'package:frontend/presentation/bloc/user_management/user_management_bloc.dart';
import 'package:frontend/presentation/bloc/profile/profile_bloc.dart';
import 'package:frontend/domain/usecase/profile/profile_usecases.dart';
import 'package:frontend/domain/usecase/user/get_all_users_usecase.dart';
import 'package:frontend/domain/usecase/user/update_user_usecase.dart';
import 'package:frontend/domain/usecase/user/delete_user_usecase.dart';
import 'package:frontend/domain/usecase/user/create_user_usecase.dart';
import 'package:frontend/domain/usecase/resident/get_admin_residents_usecase.dart';
import 'package:frontend/domain/usecase/resident/get_admin_resident_detail_usecase.dart';
import 'package:frontend/presentation/bloc/resident/resident_bloc.dart';
import 'package:frontend/presentation/bloc/resident_detail/resident_detail_bloc.dart';
import 'package:frontend/presentation/bloc/member_finance/member_finance_bloc.dart';
import 'package:frontend/domain/usecase/finance/get_member_finance_summary_usecase.dart';
import 'package:frontend/domain/usecase/finance/get_member_invoices_usecase.dart';
import 'package:frontend/domain/usecase/finance/get_member_payments_usecase.dart';
import 'package:frontend/domain/usecase/finance/pay_invoice_usecase.dart';
import 'package:frontend/domain/usecase/finance/extend_lease_usecase.dart';

import 'package:frontend/domain/usecase/inventory/get_inventories_usecase.dart';
import 'package:frontend/domain/usecase/inventory/inventory_action_usecases.dart';
import 'package:frontend/presentation/bloc/inventory/inventory_action_bloc.dart';
import 'package:frontend/presentation/bloc/inventory/inventory_list_bloc.dart';

import 'package:frontend/domain/usecase/schedule/schedule_usecases.dart';
import 'package:frontend/domain/usecase/schedule/add_schedule_update_usecase.dart';
import 'package:frontend/presentation/bloc/schedule/schedule_list_bloc.dart';
import 'package:frontend/presentation/bloc/schedule/schedule_action_bloc.dart';
import 'package:frontend/presentation/bloc/schedule_detail/schedule_detail_bloc.dart';

import 'package:frontend/domain/usecase/reservation/get_reservations_usecase.dart';
// import 'package:frontend/domain/usecase/reservation/update_reservation_status_usecase.dart';
import 'package:frontend/presentation/bloc/reservation_list/reservation_bloc.dart';
import 'package:frontend/domain/usecase/my_reservation/get_my_reservations_usecase.dart';
import 'package:frontend/domain/usecase/reservation/cancel_reservation_usecase.dart';
import 'package:frontend/presentation/bloc/my_reservation/my_reservation_bloc.dart';
import 'package:frontend/presentation/bloc/my_reservation/my_reservation_event.dart';
import 'package:frontend/presentation/bloc/guest/guest_bloc.dart';
import 'package:frontend/presentation/bloc/guest/my_guest_bloc.dart';
import 'package:frontend/presentation/bloc/guest/guest_bill_bloc.dart';
import 'package:frontend/presentation/bloc/notification/notification_log_bloc.dart';
import 'package:frontend/domain/usecase/guest/get_admin_guests_usecase.dart';
import 'package:frontend/domain/usecase/guest/get_my_guests_usecase.dart';
import 'package:frontend/domain/usecase/guest/create_guest_usecase.dart';
import 'package:frontend/domain/usecase/guest/create_admin_guest_usecase.dart';
import 'package:frontend/domain/usecase/guest/checkout_admin_guest_usecase.dart';
import 'package:frontend/domain/usecase/guest/delete_guest_usecase.dart';
import 'package:frontend/domain/usecase/guest/checkout_my_guest_usecase.dart';
import 'package:frontend/domain/usecase/guest/pay_guest_bill_usecase.dart';
import 'package:frontend/domain/usecase/guest/get_admin_guest_bills_usecase.dart';
import 'package:frontend/domain/usecase/guest/verify_guest_bill_usecase.dart';
import 'package:frontend/domain/usecase/notification/get_notification_logs_usecase.dart';
import 'package:frontend/domain/usecase/notification/mark_all_notification_logs_read_usecase.dart';
import 'package:frontend/domain/usecase/setting/get_payment_methods_usecase.dart';
import 'package:frontend/domain/usecase/setting/update_payment_methods_usecase.dart';
import 'package:frontend/presentation/bloc/payment_method_setting/payment_method_setting_cubit.dart';
import 'package:frontend/domain/usecase/finance/get_fixed_expenses_usecase.dart';
import 'package:frontend/domain/usecase/finance/update_fixed_expense_usecase.dart';
import 'package:frontend/domain/usecase/finance/get_fixed_expense_status_usecase.dart';
import 'package:frontend/domain/usecase/finance/generate_fixed_expenses_usecase.dart';
import 'package:frontend/presentation/bloc/fixed_expense/fixed_expense_bloc.dart';

Future<void> initializeBloc() async {
  serviceLocator.registerLazySingleton<AuthBloc>(
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

  serviceLocator.registerLazySingleton<PermissionBloc>(
    () => PermissionBloc(
      getPermissionsUseCase: serviceLocator.get<GetPermissionListUseCase>(),
      createPermissionUseCase: serviceLocator.get<CreatePermissionUseCase>(),
      updatePermissionUseCase: serviceLocator.get<UpdatePermissionUseCase>(),
      deletePermissionUseCase: serviceLocator.get<DeletePermissionUseCase>(),
    ),
  );

  serviceLocator.registerLazySingleton<RoomBloc>(
    () => RoomBloc(
      getRoomsUseCase: serviceLocator.get<GetRoomsUseCase>(),
      createRoomUseCase: serviceLocator.get<CreateRoomUseCase>(),
      updateRoomUseCase: serviceLocator.get<UpdateRoomUseCase>(),
      deleteRoomUseCase: serviceLocator.get<DeleteRoomUseCase>(),
    ),
  );

  serviceLocator.registerLazySingleton<DetailRoomBloc>(
    () => DetailRoomBloc(
      getRoomByIdUseCase: serviceLocator.get<GetRoomByIdUseCase>(),
      updateRoomUseCase: serviceLocator.get<UpdateRoomUseCase>(),
    ),
  );

  serviceLocator.registerLazySingleton<FormRoomBloc>(
    () => FormRoomBloc(
      createRoomUseCase: serviceLocator.get<CreateRoomUseCase>(),
      getRoomByIdUseCase: serviceLocator.get<GetRoomByIdUseCase>(),
      updateRoomUseCase: serviceLocator.get<UpdateRoomUseCase>(),
      deleteRoomImageUseCase: serviceLocator.get<DeleteRoomImageUseCase>(),
      uploadRoomImageUseCase: serviceLocator.get<UploadRoomImageUseCase>(),
    ),
  );

  serviceLocator.registerLazySingleton<RoomScheduleBloc>(
    () => RoomScheduleBloc(
      getRoomSchedulesUseCase: serviceLocator.get<GetRoomSchedulesUseCase>(),
    ),
  );

  serviceLocator.registerLazySingleton<FinanceDashboardBloc>(
    () => FinanceDashboardBloc(
      serviceLocator.get<GetDueInvoicesUseCase>(),
      serviceLocator.get<GetPendingPaymentsUseCase>(),
      serviceLocator.get<GetKpiSummaryUseCase>(),
      serviceLocator.get<GetRevenueChartUseCase>(),
    ),
  );

  serviceLocator.registerLazySingleton<InvoiceBloc>(
    () => InvoiceBloc(
      getInvoicesUseCase: serviceLocator.get<GetInvoicesUseCase>(),
    ),
  );

  serviceLocator.registerLazySingleton<SettingBloc>(
    () => SettingBloc(
      getSettingsUseCase: serviceLocator.get<GetSettingsUseCase>(),
      updateBulkSettingsUseCase: serviceLocator
          .get<UpdateBulkSettingsUseCase>(),
    ),
  );

  serviceLocator.registerLazySingleton<ExpenseBloc>(
    () => ExpenseBloc(
      getExpensesUseCase: serviceLocator.get<GetExpensesUseCase>(),
      createExpenseUseCase: serviceLocator.get<CreateExpenseUseCase>(),
      updateExpenseUseCase: serviceLocator.get<UpdateExpenseUseCase>(),
      deleteExpenseUseCase: serviceLocator.get<DeleteExpenseUseCase>(),
    ),
  );

  serviceLocator.registerLazySingleton<PaymentVerificationBloc>(
    () => PaymentVerificationBloc(
      getPendingPaymentsUseCase: serviceLocator.get<GetPendingPaymentsUseCase>(),
      getAllPaymentsUseCase: serviceLocator.get<GetAllPaymentsUseCase>(),
      verifyPaymentUseCase: serviceLocator.get<VerifyPaymentUseCase>(),
      refundPaymentUseCase: serviceLocator.get<RefundPaymentUseCase>(),
    ),
  );

  // Maintenance Blocs
  serviceLocator.registerLazySingleton<MaintenanceListBloc>(
    () => MaintenanceListBloc(
      getMyRequestsUseCase: serviceLocator.get<GetMyRequestsUseCase>(),
      getAllRequestsUseCase: serviceLocator.get<GetAllRequestsUseCase>(),
    ),
  );

  serviceLocator.registerLazySingleton<MaintenanceDetailBloc>(
    () => MaintenanceDetailBloc(
      getDetailUseCase: serviceLocator.get<GetDetailUseCase>(),
    ),
  );

  serviceLocator.registerLazySingleton<MaintenanceActionBloc>(
    () => MaintenanceActionBloc(
      createRequestUseCase: serviceLocator.get<CreateRequestUseCase>(),
      addUpdateUseCase: serviceLocator.get<AddUpdateUseCase>(),
    ),
  );

  // Inventory Blocs
  serviceLocator.registerLazySingleton<InventoryListBloc>(
    () => InventoryListBloc(
      getInventoriesUseCase: serviceLocator.get<GetInventoriesUseCase>(),
    ),
  );

  serviceLocator.registerLazySingleton<InventoryActionBloc>(
    () => InventoryActionBloc(
      createInventoryUseCase: serviceLocator.get<CreateInventoryUseCase>(),
      updateInventoryUseCase: serviceLocator.get<UpdateInventoryUseCase>(),
      deleteInventoryUseCase: serviceLocator.get<DeleteInventoryUseCase>(),
    ),
  );

  // Schedule BLoCs
  serviceLocator.registerLazySingleton<ScheduleListBloc>(
    () => ScheduleListBloc(
      getSchedulesUseCase: serviceLocator.get<GetSchedulesUseCase>(),
    ),
  );

  serviceLocator.registerLazySingleton<ScheduleActionBloc>(
    () => ScheduleActionBloc(
      createScheduleUseCase: serviceLocator.get<CreateScheduleUseCase>(),
      updateScheduleUseCase: serviceLocator.get<UpdateScheduleUseCase>(),
      deleteScheduleUseCase: serviceLocator.get<DeleteScheduleUseCase>(),
      addScheduleUpdateUseCase: serviceLocator.get<AddScheduleUpdateUseCase>(),
    ),
  );

  serviceLocator.registerLazySingleton<ScheduleDetailBloc>(
    () => ScheduleDetailBloc(
      getScheduleByIdUseCase: serviceLocator.get<GetScheduleByIdUseCase>(),
    ),
  );

  serviceLocator.registerFactory<CompleteProfileBloc>(
    () => CompleteProfileBloc(repository: serviceLocator()),
  );

  serviceLocator.registerLazySingleton<UserManagementBloc>(
    () => UserManagementBloc(
      getAllUsersUseCase: serviceLocator.get<GetAllUsersUseCase>(),
      updateUserUseCase: serviceLocator.get<UpdateUserUseCase>(),
      deleteUserUseCase: serviceLocator.get<DeleteUserUseCase>(),
      createUserUseCase: serviceLocator.get<CreateUserUseCase>(),
    ),
  );

  serviceLocator.registerFactory<ResidentBloc>(
    () => ResidentBloc(
      getAdminResidentsUseCase: serviceLocator.get<GetAdminResidentsUseCase>(),
    ),
  );

  serviceLocator.registerFactory<ResidentDetailBloc>(
    () => ResidentDetailBloc(
      getAdminResidentDetailUseCase: serviceLocator
          .get<GetAdminResidentDetailUseCase>(),
    ),
  );

  serviceLocator.registerFactory<ProfileBloc>(
    () => ProfileBloc(
      getProfileUseCase: serviceLocator.get<GetProfileUseCase>(),
      updateProfileUseCase: serviceLocator.get<UpdateProfileUseCase>(),
      changePasswordUseCase: serviceLocator.get<ChangePasswordUseCase>(),
    ),
  );

  // reservation blocs
  serviceLocator.registerLazySingleton<ReservationBloc>(
    () => ReservationBloc(
      getReservationsUseCase: serviceLocator<GetReservationsUseCase>(),

      // updateReservationStatusUseCase:
      //     serviceLocator<UpdateReservationStatusUseCase>(),
    ),
  );

  // Role Blocs
  serviceLocator.registerLazySingleton<RoleBloc>(
    () => RoleBloc(
      createRoleUseCase: serviceLocator.get<CreateRoleUseCase>(),
      getAllPermissionsUseCase: serviceLocator.get<GetAllPermissionsUseCase>(),
      updateRoleUseCase: serviceLocator.get<UpdateRoleUseCase>(),
      deleteRoleUseCase: serviceLocator.get<DeleteRoleUseCase>(),
      getAllRolesUseCase: serviceLocator.get<GetAllRolesUseCase>(),
    ),
  );
  // My Reservation Bloc
  serviceLocator.registerFactory(
    () => MyReservationBloc(
      getMyReservationsUseCase: serviceLocator<GetMyReservationsUseCase>(),
      cancelReservationUseCase: serviceLocator<CancelReservationUseCase>(),
    )..add(GetMyReservationsEvent()),
  );

  serviceLocator.registerFactory<MemberFinanceBloc>(
    () => MemberFinanceBloc(
      getSummary: serviceLocator.get<GetMemberFinanceSummaryUseCase>(),
      getInvoices: serviceLocator.get<GetMemberInvoicesUseCase>(),
      getPayments: serviceLocator.get<GetMemberPaymentsUseCase>(),
      payInvoice: serviceLocator.get<PayInvoiceUseCase>(),
      extendLease: serviceLocator.get<ExtendLeaseUseCase>(),
      getSettings: serviceLocator.get<GetPublicSettingsUseCase>(),
    ),
  );

  serviceLocator.registerFactory<GuestBloc>(
    () => GuestBloc(
      getAdminGuestsUseCase: serviceLocator.get<GetAdminGuestsUseCase>(),
      createAdminGuestUseCase: serviceLocator.get<CreateAdminGuestUseCase>(),
      checkoutAdminGuestUseCase: serviceLocator.get<CheckoutAdminGuestUseCase>(),
    ),
  );

  serviceLocator.registerFactory<MyGuestBloc>(
    () => MyGuestBloc(
      getMyGuestsUseCase: serviceLocator.get<GetMyGuestsUseCase>(),
      createGuestUseCase: serviceLocator.get<CreateGuestUseCase>(),
      deleteGuestUseCase: serviceLocator.get<DeleteGuestUseCase>(),
      payGuestBillUseCase: serviceLocator.get<PayGuestBillUseCase>(),
      checkoutMyGuestUseCase: serviceLocator.get<CheckoutMyGuestUseCase>(),
    ),
  );

  serviceLocator.registerFactory<GuestBillBloc>(
    () => GuestBillBloc(
      getAdminGuestBillsUseCase: serviceLocator.get<GetAdminGuestBillsUseCase>(),
      verifyGuestBillUseCase: serviceLocator.get<VerifyGuestBillUseCase>(),
    ),
  );

  serviceLocator.registerFactory<NotificationLogBloc>(
    () => NotificationLogBloc(
      getNotificationLogsUseCase:
          serviceLocator.get<GetNotificationLogsUseCase>(),
      markAllNotificationLogsReadUseCase:
          serviceLocator.get<MarkAllNotificationLogsReadUseCase>(),
    ),
  );

  serviceLocator.registerFactory<PaymentMethodSettingCubit>(
    () => PaymentMethodSettingCubit(
      getUseCase: serviceLocator.get<GetPaymentMethodsUseCase>(),
      updateUseCase: serviceLocator.get<UpdatePaymentMethodsUseCase>(),
    ),
  );
  serviceLocator.registerFactory<FixedExpenseBloc>(
    () => FixedExpenseBloc(
      getFixedExpenses: serviceLocator.get<GetFixedExpensesUseCase>(),
      updateFixedExpense: serviceLocator.get<UpdateFixedExpenseUseCase>(),
      getFixedExpenseStatus: serviceLocator.get<GetFixedExpenseStatusUseCase>(),
      generateFixedExpenses: serviceLocator.get<GenerateFixedExpensesUseCase>(),
    ),
  );
}
