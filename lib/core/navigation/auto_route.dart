import 'package:auto_route/auto_route.dart';
import 'package:frontend/core/constant/route_constant.dart';
import 'package:frontend/core/dependency_injection/dependency_injection.dart';
import 'package:frontend/core/navigation/auth_guard.dart';
import 'package:frontend/core/navigation/auto_route.gr.dart';
import 'package:frontend/core/navigation/feature_toggle_guard.dart';
import 'package:frontend/domain/repository/auth_repository.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(
      path: RouteConstant.landingPath,
      page: LandingRoute.page,
      initial: true,
    ),
    AutoRoute(
      page: AppLayoutRoute.page,
      path: RouteConstant.rootPath,
      children: [
        // dashboard
        AutoRoute(
          path: RouteConstant.dashboardName,
          page: DashboardRoute.page,
          guards: [AuthGuard(serviceLocator.get<AuthRepository>())],
        ),
        AutoRoute(
          path: RouteConstant.permissionName,
          page: PermissionRoute.page,
          guards: [AuthGuard(serviceLocator.get<AuthRepository>())],
        ),
        AutoRoute(
          path: '${RouteConstant.permissionName}/:id',
          page: PermissionDetailRoute.page,
          guards: [AuthGuard(serviceLocator.get<AuthRepository>())],
        ),
        AutoRoute(
          path: RouteConstant.roleName,
          page: RoleManagementRoute.page,
          guards: [AuthGuard(serviceLocator.get<AuthRepository>())],
        ),

        // manajemen penghuni
        AutoRoute(
          path: RouteConstant.residentName,
          page: ResidentRoute.page,
          guards: [AuthGuard(serviceLocator.get<AuthRepository>())],
        ),
        AutoRoute(
          path: '${RouteConstant.residentName}/guest',
          page: GuestListRoute.page,
          guards: [
            AuthGuard(serviceLocator.get<AuthRepository>()),
            FeatureToggleGuard('guest'),
          ],
        ),
        AutoRoute(
          path: RouteConstant.residentProfileName,
          page: ProfileUserRoute.page,
          guards: [AuthGuard(serviceLocator.get<AuthRepository>())],
        ),
        AutoRoute(
          guards: [
            AuthGuard(serviceLocator.get<AuthRepository>()),
            FeatureToggleGuard('schedule'),
          ],
          path: RouteConstant.myReservationName,
          page: MyReservationRoute.page,
        ),

        // manajemen kamar & reservasi
        AutoRoute(
          initial: true,
          path: RouteConstant.roomName,
          page: RoomRoute.page,
          guards: [FeatureToggleGuard('room')],
        ),
        // form identitas pengguna
        AutoRoute(
          // guards: [AuthGuard(serviceLocator.get<AuthRepository>())],
          path: RouteConstant.identityFormName,
          page: IdentityFormRoute.page,
        ),
        // form detail reservasi
        AutoRoute(
          path: RouteConstant.reservationDetailFormName,
          page: ReservationDetailFormRoute.page,
          guards: [FeatureToggleGuard('schedule')],
        ),
        AutoRoute(
          guards: [AuthGuard(serviceLocator.get<AuthRepository>())],
          path: RouteConstant.completeProfileName,
          page: CompleteProfileRoute.page,
        ),
        AutoRoute(
          path: RouteConstant.detailRoomName,
          page: RoomDetailRoute.page,
          guards: [FeatureToggleGuard('room')],
        ),
        AutoRoute(
          guards: [
            AuthGuard(serviceLocator.get<AuthRepository>()),
            FeatureToggleGuard('room'),
          ],
          path: RouteConstant.addRoomName,
          page: AddRoomRoute.page,
        ),
        AutoRoute(
          guards: [
            AuthGuard(serviceLocator.get<AuthRepository>()),
            FeatureToggleGuard('room'),
          ],
          path: RouteConstant.editRoomName,
          page: EditRoomRoute.page,
        ),
        AutoRoute(
          guards: [
            AuthGuard(serviceLocator.get<AuthRepository>()),
            FeatureToggleGuard('room'),
          ],
          path: RouteConstant.roomAndReservationName,
          page: RoomAndReservationPlaceholderRoute.page,
        ),
        AutoRoute(
          path: RouteConstant.reservationName,
          page: ReservationRoute.page,
          guards: [FeatureToggleGuard('schedule')],
        ),
        AutoRoute(
          guards: [FeatureToggleGuard('schedule')],
          path: RouteConstant.roomScheduleName,
          page: RoomScheduleRoute.page,
        ),

        // manajemen keuangan
        AutoRoute(
          guards: [
            AuthGuard(serviceLocator.get<AuthRepository>()),
            FeatureToggleGuard('finance_dashboard'),
          ],
          path: RouteConstant.financeDashboardName,
          page: FinanceDashboardRoute.page,
        ),
        AutoRoute(
          guards: [
            AuthGuard(serviceLocator.get<AuthRepository>()),
            FeatureToggleGuard('finance_expense'),
          ],
          path: RouteConstant.financeExpenseName,
          page: ExpenseListRoute.page,
        ),
        AutoRoute(
          guards: [
            AuthGuard(serviceLocator.get<AuthRepository>()),
            FeatureToggleGuard('finance_invoice'),
          ],
          path: RouteConstant.financeInvoiceName,
          page: InvoiceListRoute.page,
        ),
        AutoRoute(
          guards: [
            AuthGuard(serviceLocator.get<AuthRepository>()),
            FeatureToggleGuard('finance_invoice'),
          ],
          path: RouteConstant.paymentVerificationName,
          page: PaymentVerificationRoute.page,
        ),
        // manajemen inventaris
        AutoRoute(
          guards: [
            AuthGuard(serviceLocator.get<AuthRepository>()),
            FeatureToggleGuard('inventory'),
          ],
          path: RouteConstant.inventory,
          page: InventoryRoute.page,
        ),
        AutoRoute(
          guards: [
            AuthGuard(serviceLocator.get<AuthRepository>()),
            FeatureToggleGuard('inventory'),
          ],
          path: RouteConstant.inventoryForm,
          page: InventoryFormRoute.page,
        ),

        // manajemen maintanance (jadwal)
        AutoRoute(
          guards: [
            AuthGuard(serviceLocator.get<AuthRepository>()),
            FeatureToggleGuard('maintenance_schedule'),
          ],
          path: RouteConstant.maintanance,
          page: MaintananceRoute.page,
        ),
        AutoRoute(
          guards: [
            AuthGuard(serviceLocator.get<AuthRepository>()),
            FeatureToggleGuard('maintenance_schedule'),
          ],
          path: RouteConstant.maintananceForm,
          page: MaintananceFormRoute.page,
        ),
        AutoRoute(
          guards: [
            AuthGuard(serviceLocator.get<AuthRepository>()),
            FeatureToggleGuard('maintenance_schedule'),
          ],
          path: RouteConstant.maintananceDetail,
          page: MaintananceDetailRoute.page,
        ),

        // laporan kerusakan
        AutoRoute(
          guards: [
            AuthGuard(serviceLocator.get<AuthRepository>()),
            FeatureToggleGuard('damage_report'),
          ],
          path: RouteConstant.maintenanceReport,
          page: MaintenanceReportListRoute.page,
        ),
        AutoRoute(
          guards: [
            AuthGuard(serviceLocator.get<AuthRepository>()),
            FeatureToggleGuard('damage_report'),
          ],
          path: RouteConstant.maintenanceReportCreate,
          page: MaintenanceCreateReportRoute.page,
        ),
        AutoRoute(
          guards: [
            AuthGuard(serviceLocator.get<AuthRepository>()),
            FeatureToggleGuard('damage_report'),
          ],
          path: '${RouteConstant.maintenanceReport}/:id',
          page: MaintenanceReportDetailRoute.page,
        ),
        AutoRoute(
          guards: [
            AuthGuard(serviceLocator.get<AuthRepository>()),
            FeatureToggleGuard('finance'),
          ],
          path: RouteConstant.memberFinanceName,
          page: MemberFinanceRoute.page,
        ),
        AutoRoute(
          guards: [
            AuthGuard(serviceLocator.get<AuthRepository>()),
            FeatureToggleGuard('finance_lease'),
          ],
          path: RouteConstant.extendLeaseName,
          page: ExtendLeaseRoute.page,
        ),
        AutoRoute(
          guards: [
            AuthGuard(serviceLocator.get<AuthRepository>()),
            FeatureToggleGuard('finance_lease'),
          ],
          path: RouteConstant.extendLeasePaymentName,
          page: ExtendLeasePaymentRoute.page,
        ),
        AutoRoute(
          guards: [
            AuthGuard(serviceLocator.get<AuthRepository>()),
            FeatureToggleGuard('finance_invoice'),
          ],
          path: RouteConstant.invoicePaymentName,
          page: InvoicePaymentRoute.page,
        ),
        AutoRoute(
          guards: [
            AuthGuard(serviceLocator.get<AuthRepository>()),
            FeatureToggleGuard('finance_fine'),
          ],
          path: RouteConstant.myFinesName,
          page: MyFinesRoute.page,
        ),
        AutoRoute(
          guards: [
            AuthGuard(serviceLocator.get<AuthRepository>()),
            FeatureToggleGuard('finance_fine'),
          ],
          path: RouteConstant.fineManagementName,
          page: FineManagementRoute.page,
        ),
        AutoRoute(
          guards: [
            AuthGuard(serviceLocator.get<AuthRepository>()),
            FeatureToggleGuard('guest'),
          ],
          path: RouteConstant.myGuestName,
          page: MyGuestRoute.page,
        ),
        AutoRoute(
          guards: [
            AuthGuard(serviceLocator.get<AuthRepository>()),
            FeatureToggleGuard('guest'),
          ],
          path: RouteConstant.adminGuestBillName,
          page: AdminGuestBillRoute.page,
        ),
        AutoRoute(
          guards: [
            AuthGuard(serviceLocator.get<AuthRepository>()),
            FeatureToggleGuard('guest'),
          ],
          path: 'me/guests/bill-payment',
          page: GuestBillPaymentRoute.page,
        ),
        AutoRoute(
          guards: [
            AuthGuard(serviceLocator.get<AuthRepository>()),
            FeatureToggleGuard('finance'),
          ],
          path: 'payment-upload',
          page: PaymentUploadRoute.page,
        ),
        AutoRoute(
          guards: [
            AuthGuard(serviceLocator.get<AuthRepository>()),
            FeatureToggleGuard('finance'),
          ],
          path: 'payment-midtrans',
          page: MidtransPaymentRoute.page,
        ),

        // pengaturan
        AutoRoute(
          guards: [AuthGuard(serviceLocator.get<AuthRepository>())],
          path: RouteConstant.settingName,
          page: SettingRoute.page,
        ),
        AutoRoute(
          guards: [AuthGuard(serviceLocator.get<AuthRepository>())],
          path: RouteConstant.featureToggleName,
          page: FeatureToggleRoute.page,
        ),
        AutoRoute(
          guards: [AuthGuard(serviceLocator.get<AuthRepository>())],
          path: RouteConstant.userManagementName,
          page: UserManagementRoute.page,
        ),
        AutoRoute(
          guards: [AuthGuard(serviceLocator.get<AuthRepository>())],
          path: RouteConstant.profileName,
          page: ProfileRoute.page,
        ),
        AutoRoute(
          guards: [AuthGuard(serviceLocator.get<AuthRepository>())],
          path: RouteConstant.editProfileName,
          page: EditProfileRoute.page,
        ),
        AutoRoute(
          guards: [AuthGuard(serviceLocator.get<AuthRepository>())],
          path: RouteConstant.changePasswordName,
          page: ChangePasswordRoute.page,
        ),
        AutoRoute(
          guards: [
            AuthGuard(serviceLocator.get<AuthRepository>()),
            FeatureToggleGuard('notification'),
          ],
          path: RouteConstant.notificationMonitoringName,
          page: NotificationMonitoringRoute.page,
        ),
      ],
    ),
    AutoRoute(path: RouteConstant.loginName, page: LoginRoute.page),
    AutoRoute(path: RouteConstant.registerName, page: RegisterRoute.page),
  ];
}
