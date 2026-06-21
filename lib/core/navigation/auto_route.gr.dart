// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
<<<<<<< HEAD
import 'package:auto_route/auto_route.dart' as _i48;
import 'package:collection/collection.dart' as _i50;
import 'package:flutter/material.dart' as _i49;
import 'package:frontend/domain/entity/inventory_entity.dart' as _i51;
import 'package:frontend/domain/entity/reservation_entity.dart' as _i54;
import 'package:frontend/domain/entity/room_entity.dart' as _i52;
import 'package:frontend/domain/entity/schedule_entity.dart' as _i53;
import 'package:frontend/presentation/pages/auth/login_page.dart' as _i21;
import 'package:frontend/presentation/pages/auth/register_page.dart' as _i38;
import 'package:frontend/presentation/pages/dashboard/dashboard.dart' as _i6;
import 'package:frontend/presentation/pages/detail_room/room_detail.dart'
    as _i43;
import 'package:frontend/presentation/pages/finance/expense_list_page.dart'
    as _i8;
import 'package:frontend/presentation/pages/finance/finance_dashboard_page.dart'
    as _i12;
import 'package:frontend/presentation/pages/finance/invoice_list_page.dart'
    as _i19;
import 'package:frontend/presentation/pages/finance/payment_verification_page.dart'
    as _i33;
=======
import 'package:auto_route/auto_route.dart' as _i51;
import 'package:collection/collection.dart' as _i53;
import 'package:flutter/material.dart' as _i52;
import 'package:frontend/domain/entity/inventory_entity.dart' as _i54;
import 'package:frontend/domain/entity/reservation_entity.dart' as _i58;
import 'package:frontend/domain/entity/room_entity.dart' as _i56;
import 'package:frontend/domain/entity/schedule_entity.dart' as _i57;
import 'package:frontend/presentation/bloc/member_finance/member_finance_bloc.dart'
    as _i55;
import 'package:frontend/presentation/pages/auth/login_page.dart' as _i22;
import 'package:frontend/presentation/pages/auth/register_page.dart' as _i41;
import 'package:frontend/presentation/pages/dashboard/dashboard.dart' as _i6;
import 'package:frontend/presentation/pages/detail_room/room_detail.dart'
    as _i46;
import 'package:frontend/presentation/pages/finance/expense_list_page.dart'
    as _i8;
import 'package:frontend/presentation/pages/finance/finance_dashboard_page.dart'
    as _i11;
import 'package:frontend/presentation/pages/finance/fine_management_page.dart'
    as _i13;
import 'package:frontend/presentation/pages/finance/invoice_list_page.dart'
    as _i19;
import 'package:frontend/presentation/pages/finance/payment_verification_page.dart'
    as _i36;
>>>>>>> feat/dp-payment
import 'package:frontend/presentation/pages/identity_form/identity_form_page.dart'
    as _i16;
import 'package:frontend/presentation/pages/inventory/inventory_form_page.dart'
    as _i17;
import 'package:frontend/presentation/pages/inventory/inventory_page.dart'
    as _i18;
import 'package:frontend/presentation/pages/landing_page/landing_page.dart'
<<<<<<< HEAD
    as _i20;
import 'package:frontend/presentation/pages/maintanance/maintanance_detail_page.dart'
    as _i22;
import 'package:frontend/presentation/pages/maintanance/maintanance_form_page.dart'
    as _i23;
import 'package:frontend/presentation/pages/maintanance/maintanance_page.dart'
    as _i24;
import 'package:frontend/presentation/pages/maintenance_report/maintenance_create_report_page.dart'
    as _i25;
import 'package:frontend/presentation/pages/maintenance_report/maintenance_report_detail_page.dart'
    as _i26;
import 'package:frontend/presentation/pages/maintenance_report/maintenance_report_list_page.dart'
    as _i27;
=======
    as _i21;
import 'package:frontend/presentation/pages/maintanance/maintanance_detail_page.dart'
    as _i23;
import 'package:frontend/presentation/pages/maintanance/maintanance_form_page.dart'
    as _i24;
import 'package:frontend/presentation/pages/maintanance/maintanance_page.dart'
    as _i25;
import 'package:frontend/presentation/pages/maintenance_report/maintenance_create_report_page.dart'
    as _i26;
import 'package:frontend/presentation/pages/maintenance_report/maintenance_report_detail_page.dart'
    as _i27;
import 'package:frontend/presentation/pages/maintenance_report/maintenance_report_list_page.dart'
    as _i28;
>>>>>>> feat/dp-payment
import 'package:frontend/presentation/pages/member_finance/extend_lease_page.dart'
    as _i9;
import 'package:frontend/presentation/pages/member_finance/extend_lease_payment_page.dart'
    as _i10;
import 'package:frontend/presentation/pages/member_finance/invoice_payment_page.dart'
    as _i20;
import 'package:frontend/presentation/pages/member_finance/member_finance_page.dart'
<<<<<<< HEAD
    as _i28;
import 'package:frontend/presentation/pages/midtrans_payment/midtrans_payment_page.dart'
    as _i29;
import 'package:frontend/presentation/pages/payment_upload/payment_upload_page.dart'
    as _i32;
import 'package:frontend/presentation/pages/permission/permission_detail_page.dart'
    as _i34;
import 'package:frontend/presentation/pages/permission/permission_page.dart'
    as _i35;
=======
    as _i29;
import 'package:frontend/presentation/pages/member_finance/my_fines_page.dart'
    as _i31;
import 'package:frontend/presentation/pages/midtrans_payment/midtrans_payment_page.dart'
    as _i30;
import 'package:frontend/presentation/pages/notification/notification_monitoring_page.dart'
    as _i34;
import 'package:frontend/presentation/pages/payment_upload/payment_upload_page.dart'
    as _i35;
import 'package:frontend/presentation/pages/permission/permission_detail_page.dart'
    as _i37;
import 'package:frontend/presentation/pages/permission/permission_page.dart'
    as _i38;
>>>>>>> feat/dp-payment
import 'package:frontend/presentation/pages/placeholder/placeholder_page.dart'
    as _i13;
import 'package:frontend/presentation/pages/profile/change_password_page.dart'
    as _i4;
import 'package:frontend/presentation/pages/profile/edit_profile_page.dart'
    as _i7;
<<<<<<< HEAD
import 'package:frontend/presentation/pages/profile/profile_page.dart' as _i36;
import 'package:frontend/presentation/pages/reservation_detail_form/reservation_detail_form_page.dart'
    as _i39;
import 'package:frontend/presentation/pages/reservation_list/reservation_page.dart'
    as _i40;
=======
import 'package:frontend/presentation/pages/profile/profile_page.dart' as _i39;
import 'package:frontend/presentation/pages/reservation_detail_form/reservation_detail_form_page.dart'
    as _i42;
import 'package:frontend/presentation/pages/reservation_list/reservation_page.dart'
    as _i43;
>>>>>>> feat/dp-payment
import 'package:frontend/presentation/pages/resident/admin_guest_bill_page.dart'
    as _i2;
import 'package:frontend/presentation/pages/resident/complete_profile_page.dart'
    as _i5;
import 'package:frontend/presentation/pages/resident/guest_bill_payment_page.dart'
    as _i14;
import 'package:frontend/presentation/pages/resident/guest_list_page.dart'
    as _i15;
import 'package:frontend/presentation/pages/resident/my_guest_page.dart'
<<<<<<< HEAD
    as _i30;
import 'package:frontend/presentation/pages/resident/profile_user_page.dart'
    as _i37;
import 'package:frontend/presentation/pages/resident/resident_page.dart'
    as _i41;
import 'package:frontend/presentation/pages/resident_portal/my_reservation/my_reservation_page.dart'
    as _i31;
import 'package:frontend/presentation/pages/role_management/role_management_page.dart'
    as _i42;
import 'package:frontend/presentation/pages/room_form/form_room.dart' as _i1;
import 'package:frontend/presentation/pages/room_list/room_page.dart' as _i44;
import 'package:frontend/presentation/pages/room_schedule/room_schedule_page.dart'
    as _i45;
import 'package:frontend/presentation/pages/setting/feature_toggle_page.dart'
    as _i11;
import 'package:frontend/presentation/pages/setting/setting_page.dart' as _i46;
import 'package:frontend/presentation/pages/user_management/user_management_page.dart'
    as _i47;
=======
    as _i32;
import 'package:frontend/presentation/pages/resident/profile_user_page.dart'
    as _i40;
import 'package:frontend/presentation/pages/resident/resident_page.dart'
    as _i44;
import 'package:frontend/presentation/pages/resident_portal/my_reservation/my_reservation_page.dart'
    as _i33;
import 'package:frontend/presentation/pages/role_management/role_management_page.dart'
    as _i45;
import 'package:frontend/presentation/pages/room_form/form_room.dart' as _i1;
import 'package:frontend/presentation/pages/room_list/room_page.dart' as _i47;
import 'package:frontend/presentation/pages/room_schedule/room_schedule_page.dart'
    as _i48;
import 'package:frontend/presentation/pages/setting/setting_page.dart' as _i49;
import 'package:frontend/presentation/pages/user_management/user_management_page.dart'
    as _i50;
>>>>>>> feat/dp-payment
import 'package:frontend/presentation/widget/app_layout.dart' as _i3;

/// generated route for
/// [_i1.AddRoomPage]
<<<<<<< HEAD
class AddRoomRoute extends _i48.PageRouteInfo<void> {
  const AddRoomRoute({List<_i48.PageRouteInfo>? children})
=======
class AddRoomRoute extends _i51.PageRouteInfo<void> {
  const AddRoomRoute({List<_i51.PageRouteInfo>? children})
>>>>>>> feat/dp-payment
    : super(AddRoomRoute.name, initialChildren: children);

  static const String name = 'AddRoomRoute';

<<<<<<< HEAD
  static _i48.PageInfo page = _i48.PageInfo(
=======
  static _i51.PageInfo page = _i51.PageInfo(
>>>>>>> feat/dp-payment
    name,
    builder: (data) {
      return const _i1.AddRoomPage();
    },
  );
}

/// generated route for
/// [_i2.AdminGuestBillPage]
<<<<<<< HEAD
class AdminGuestBillRoute extends _i48.PageRouteInfo<void> {
  const AdminGuestBillRoute({List<_i48.PageRouteInfo>? children})
=======
class AdminGuestBillRoute extends _i51.PageRouteInfo<void> {
  const AdminGuestBillRoute({List<_i51.PageRouteInfo>? children})
>>>>>>> feat/dp-payment
    : super(AdminGuestBillRoute.name, initialChildren: children);

  static const String name = 'AdminGuestBillRoute';

<<<<<<< HEAD
  static _i48.PageInfo page = _i48.PageInfo(
=======
  static _i51.PageInfo page = _i51.PageInfo(
>>>>>>> feat/dp-payment
    name,
    builder: (data) {
      return const _i2.AdminGuestBillPage();
    },
  );
}

/// generated route for
/// [_i3.AppLayoutPage]
<<<<<<< HEAD
class AppLayoutRoute extends _i48.PageRouteInfo<void> {
  const AppLayoutRoute({List<_i48.PageRouteInfo>? children})
=======
class AppLayoutRoute extends _i51.PageRouteInfo<void> {
  const AppLayoutRoute({List<_i51.PageRouteInfo>? children})
>>>>>>> feat/dp-payment
    : super(AppLayoutRoute.name, initialChildren: children);

  static const String name = 'AppLayoutRoute';

<<<<<<< HEAD
  static _i48.PageInfo page = _i48.PageInfo(
=======
  static _i51.PageInfo page = _i51.PageInfo(
>>>>>>> feat/dp-payment
    name,
    builder: (data) {
      return const _i3.AppLayoutPage();
    },
  );
}

/// generated route for
/// [_i4.ChangePasswordPage]
<<<<<<< HEAD
class ChangePasswordRoute extends _i48.PageRouteInfo<void> {
  const ChangePasswordRoute({List<_i48.PageRouteInfo>? children})
=======
class ChangePasswordRoute extends _i51.PageRouteInfo<void> {
  const ChangePasswordRoute({List<_i51.PageRouteInfo>? children})
>>>>>>> feat/dp-payment
    : super(ChangePasswordRoute.name, initialChildren: children);

  static const String name = 'ChangePasswordRoute';

<<<<<<< HEAD
  static _i48.PageInfo page = _i48.PageInfo(
=======
  static _i51.PageInfo page = _i51.PageInfo(
>>>>>>> feat/dp-payment
    name,
    builder: (data) {
      return const _i4.ChangePasswordPage();
    },
  );
}

/// generated route for
/// [_i5.CompleteProfilePage]
<<<<<<< HEAD
class CompleteProfileRoute extends _i48.PageRouteInfo<void> {
  const CompleteProfileRoute({List<_i48.PageRouteInfo>? children})
=======
class CompleteProfileRoute extends _i51.PageRouteInfo<void> {
  const CompleteProfileRoute({List<_i51.PageRouteInfo>? children})
>>>>>>> feat/dp-payment
    : super(CompleteProfileRoute.name, initialChildren: children);

  static const String name = 'CompleteProfileRoute';

<<<<<<< HEAD
  static _i48.PageInfo page = _i48.PageInfo(
=======
  static _i51.PageInfo page = _i51.PageInfo(
>>>>>>> feat/dp-payment
    name,
    builder: (data) {
      return const _i5.CompleteProfilePage();
    },
  );
}

/// generated route for
/// [_i6.DashboardPage]
<<<<<<< HEAD
class DashboardRoute extends _i48.PageRouteInfo<void> {
  const DashboardRoute({List<_i48.PageRouteInfo>? children})
=======
class DashboardRoute extends _i51.PageRouteInfo<void> {
  const DashboardRoute({List<_i51.PageRouteInfo>? children})
>>>>>>> feat/dp-payment
    : super(DashboardRoute.name, initialChildren: children);

  static const String name = 'DashboardRoute';

<<<<<<< HEAD
  static _i48.PageInfo page = _i48.PageInfo(
=======
  static _i51.PageInfo page = _i51.PageInfo(
>>>>>>> feat/dp-payment
    name,
    builder: (data) {
      return const _i6.DashboardPage();
    },
  );
}

/// generated route for
/// [_i7.EditProfilePage]
<<<<<<< HEAD
class EditProfileRoute extends _i48.PageRouteInfo<void> {
  const EditProfileRoute({List<_i48.PageRouteInfo>? children})
=======
class EditProfileRoute extends _i51.PageRouteInfo<void> {
  const EditProfileRoute({List<_i51.PageRouteInfo>? children})
>>>>>>> feat/dp-payment
    : super(EditProfileRoute.name, initialChildren: children);

  static const String name = 'EditProfileRoute';

<<<<<<< HEAD
  static _i48.PageInfo page = _i48.PageInfo(
=======
  static _i51.PageInfo page = _i51.PageInfo(
>>>>>>> feat/dp-payment
    name,
    builder: (data) {
      return const _i7.EditProfilePage();
    },
  );
}

/// generated route for
/// [_i1.EditRoomPage]
<<<<<<< HEAD
class EditRoomRoute extends _i48.PageRouteInfo<EditRoomRouteArgs> {
  EditRoomRoute({
    _i49.Key? key,
    required int roomId,
    List<_i48.PageRouteInfo>? children,
=======
class EditRoomRoute extends _i51.PageRouteInfo<EditRoomRouteArgs> {
  EditRoomRoute({
    _i52.Key? key,
    required int roomId,
    List<_i51.PageRouteInfo>? children,
>>>>>>> feat/dp-payment
  }) : super(
         EditRoomRoute.name,
         args: EditRoomRouteArgs(key: key, roomId: roomId),
         rawPathParams: {'id': roomId},
         initialChildren: children,
       );

  static const String name = 'EditRoomRoute';

<<<<<<< HEAD
  static _i48.PageInfo page = _i48.PageInfo(
=======
  static _i51.PageInfo page = _i51.PageInfo(
>>>>>>> feat/dp-payment
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<EditRoomRouteArgs>(
        orElse: () => EditRoomRouteArgs(roomId: pathParams.getInt('id')),
      );
      return _i1.EditRoomPage(key: args.key, roomId: args.roomId);
    },
  );
}

class EditRoomRouteArgs {
  const EditRoomRouteArgs({this.key, required this.roomId});

<<<<<<< HEAD
  final _i49.Key? key;
=======
  final _i52.Key? key;
>>>>>>> feat/dp-payment

  final int roomId;

  @override
  String toString() {
    return 'EditRoomRouteArgs{key: $key, roomId: $roomId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! EditRoomRouteArgs) return false;
    return key == other.key && roomId == other.roomId;
  }

  @override
  int get hashCode => key.hashCode ^ roomId.hashCode;
}

/// generated route for
/// [_i8.ExpenseListPage]
<<<<<<< HEAD
class ExpenseListRoute extends _i48.PageRouteInfo<void> {
  const ExpenseListRoute({List<_i48.PageRouteInfo>? children})
=======
class ExpenseListRoute extends _i51.PageRouteInfo<void> {
  const ExpenseListRoute({List<_i51.PageRouteInfo>? children})
>>>>>>> feat/dp-payment
    : super(ExpenseListRoute.name, initialChildren: children);

  static const String name = 'ExpenseListRoute';

<<<<<<< HEAD
  static _i48.PageInfo page = _i48.PageInfo(
=======
  static _i51.PageInfo page = _i51.PageInfo(
>>>>>>> feat/dp-payment
    name,
    builder: (data) {
      return const _i8.ExpenseListPage();
    },
  );
}

/// generated route for
/// [_i9.ExtendLeasePage]
<<<<<<< HEAD
class ExtendLeaseRoute extends _i48.PageRouteInfo<ExtendLeaseRouteArgs> {
  ExtendLeaseRoute({
    _i49.Key? key,
=======
class ExtendLeaseRoute extends _i51.PageRouteInfo<ExtendLeaseRouteArgs> {
  ExtendLeaseRoute({
    _i52.Key? key,
>>>>>>> feat/dp-payment
    required int leaseId,
    required String roomNumber,
    required DateTime currentEndDate,
    required bool isMidtransEnabled,
<<<<<<< HEAD
    List<_i48.PageRouteInfo>? children,
=======
    List<_i51.PageRouteInfo>? children,
>>>>>>> feat/dp-payment
  }) : super(
         ExtendLeaseRoute.name,
         args: ExtendLeaseRouteArgs(
           key: key,
           leaseId: leaseId,
           roomNumber: roomNumber,
           currentEndDate: currentEndDate,
           isMidtransEnabled: isMidtransEnabled,
         ),
         initialChildren: children,
       );

  static const String name = 'ExtendLeaseRoute';

<<<<<<< HEAD
  static _i48.PageInfo page = _i48.PageInfo(
=======
  static _i51.PageInfo page = _i51.PageInfo(
>>>>>>> feat/dp-payment
    name,
    builder: (data) {
      final args = data.argsAs<ExtendLeaseRouteArgs>();
      return _i9.ExtendLeasePage(
        key: args.key,
        leaseId: args.leaseId,
        roomNumber: args.roomNumber,
        currentEndDate: args.currentEndDate,
        isMidtransEnabled: args.isMidtransEnabled,
      );
    },
  );
}

class ExtendLeaseRouteArgs {
  const ExtendLeaseRouteArgs({
    this.key,
    required this.leaseId,
    required this.roomNumber,
    required this.currentEndDate,
    required this.isMidtransEnabled,
  });

<<<<<<< HEAD
  final _i49.Key? key;
=======
  final _i52.Key? key;
>>>>>>> feat/dp-payment

  final int leaseId;

  final String roomNumber;

  final DateTime currentEndDate;

  final bool isMidtransEnabled;

  @override
  String toString() {
    return 'ExtendLeaseRouteArgs{key: $key, leaseId: $leaseId, roomNumber: $roomNumber, currentEndDate: $currentEndDate, isMidtransEnabled: $isMidtransEnabled}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ExtendLeaseRouteArgs) return false;
    return key == other.key &&
        leaseId == other.leaseId &&
        roomNumber == other.roomNumber &&
        currentEndDate == other.currentEndDate &&
        isMidtransEnabled == other.isMidtransEnabled;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      leaseId.hashCode ^
      roomNumber.hashCode ^
      currentEndDate.hashCode ^
      isMidtransEnabled.hashCode;
}

/// generated route for
/// [_i10.ExtendLeasePaymentPage]
class ExtendLeasePaymentRoute
<<<<<<< HEAD
    extends _i48.PageRouteInfo<ExtendLeasePaymentRouteArgs> {
  ExtendLeasePaymentRoute({
    _i49.Key? key,
=======
    extends _i51.PageRouteInfo<ExtendLeasePaymentRouteArgs> {
  ExtendLeasePaymentRoute({
    _i52.Key? key,
>>>>>>> feat/dp-payment
    required int invoiceId,
    required String roomNumber,
    required double amount,
    double? baseAmount,
    int midtransFee = 0,
    String? feeBearer,
    String? snapToken,
    Map<String, dynamic>? paymentData,
<<<<<<< HEAD
    List<_i48.PageRouteInfo>? children,
=======
    String? pageTitle,
    List<_i51.PageRouteInfo>? children,
>>>>>>> feat/dp-payment
  }) : super(
         ExtendLeasePaymentRoute.name,
         args: ExtendLeasePaymentRouteArgs(
           key: key,
           invoiceId: invoiceId,
           roomNumber: roomNumber,
           amount: amount,
           baseAmount: baseAmount,
           midtransFee: midtransFee,
           feeBearer: feeBearer,
           snapToken: snapToken,
           paymentData: paymentData,
           pageTitle: pageTitle,
         ),
         initialChildren: children,
       );

  static const String name = 'ExtendLeasePaymentRoute';

<<<<<<< HEAD
  static _i48.PageInfo page = _i48.PageInfo(
=======
  static _i51.PageInfo page = _i51.PageInfo(
>>>>>>> feat/dp-payment
    name,
    builder: (data) {
      final args = data.argsAs<ExtendLeasePaymentRouteArgs>();
      return _i10.ExtendLeasePaymentPage(
        key: args.key,
        invoiceId: args.invoiceId,
        roomNumber: args.roomNumber,
        amount: args.amount,
        baseAmount: args.baseAmount,
        midtransFee: args.midtransFee,
        feeBearer: args.feeBearer,
        snapToken: args.snapToken,
        paymentData: args.paymentData,
        pageTitle: args.pageTitle,
      );
    },
  );
}

class ExtendLeasePaymentRouteArgs {
  const ExtendLeasePaymentRouteArgs({
    this.key,
    required this.invoiceId,
    required this.roomNumber,
    required this.amount,
    this.baseAmount,
    this.midtransFee = 0,
    this.feeBearer,
    this.snapToken,
    this.paymentData,
    this.pageTitle,
  });

<<<<<<< HEAD
  final _i49.Key? key;
=======
  final _i52.Key? key;
>>>>>>> feat/dp-payment

  final int invoiceId;

  final String roomNumber;

  final double amount;

  final double? baseAmount;

  final int midtransFee;

  final String? feeBearer;

  final String? snapToken;

  final Map<String, dynamic>? paymentData;

  final String? pageTitle;

  @override
  String toString() {
    return 'ExtendLeasePaymentRouteArgs{key: $key, invoiceId: $invoiceId, roomNumber: $roomNumber, amount: $amount, baseAmount: $baseAmount, midtransFee: $midtransFee, feeBearer: $feeBearer, snapToken: $snapToken, paymentData: $paymentData, pageTitle: $pageTitle}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ExtendLeasePaymentRouteArgs) return false;
    return key == other.key &&
        invoiceId == other.invoiceId &&
        roomNumber == other.roomNumber &&
        amount == other.amount &&
        baseAmount == other.baseAmount &&
        midtransFee == other.midtransFee &&
        feeBearer == other.feeBearer &&
        snapToken == other.snapToken &&
<<<<<<< HEAD
        const _i50.MapEquality<String, dynamic>().equals(
=======
        const _i53.MapEquality<String, dynamic>().equals(
>>>>>>> feat/dp-payment
          paymentData,
          other.paymentData,
        ) &&
        pageTitle == other.pageTitle;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      invoiceId.hashCode ^
      roomNumber.hashCode ^
      amount.hashCode ^
      baseAmount.hashCode ^
      midtransFee.hashCode ^
      feeBearer.hashCode ^
      snapToken.hashCode ^
<<<<<<< HEAD
      const _i50.MapEquality<String, dynamic>().hash(paymentData);
}

/// generated route for
/// [_i11.FeatureTogglePage]
class FeatureToggleRoute extends _i48.PageRouteInfo<void> {
  const FeatureToggleRoute({List<_i48.PageRouteInfo>? children})
    : super(FeatureToggleRoute.name, initialChildren: children);

  static const String name = 'FeatureToggleRoute';

  static _i48.PageInfo page = _i48.PageInfo(
    name,
    builder: (data) {
      return const _i11.FeatureTogglePage();
    },
  );
}

/// generated route for
/// [_i12.FinanceDashboardPage]
class FinanceDashboardRoute extends _i48.PageRouteInfo<void> {
  const FinanceDashboardRoute({List<_i48.PageRouteInfo>? children})
=======
      const _i53.MapEquality<String, dynamic>().hash(paymentData) ^
      pageTitle.hashCode;
}

/// generated route for
/// [_i11.FinanceDashboardPage]
class FinanceDashboardRoute extends _i51.PageRouteInfo<void> {
  const FinanceDashboardRoute({List<_i51.PageRouteInfo>? children})
>>>>>>> feat/dp-payment
    : super(FinanceDashboardRoute.name, initialChildren: children);

  static const String name = 'FinanceDashboardRoute';

<<<<<<< HEAD
  static _i48.PageInfo page = _i48.PageInfo(
=======
  static _i51.PageInfo page = _i51.PageInfo(
>>>>>>> feat/dp-payment
    name,
    builder: (data) {
      return const _i12.FinanceDashboardPage();
    },
  );
}

/// generated route for
<<<<<<< HEAD
/// [_i13.FinancePlaceholderPage]
class FinancePlaceholderRoute extends _i48.PageRouteInfo<void> {
  const FinancePlaceholderRoute({List<_i48.PageRouteInfo>? children})
=======
/// [_i12.FinancePlaceholderPage]
class FinancePlaceholderRoute extends _i51.PageRouteInfo<void> {
  const FinancePlaceholderRoute({List<_i51.PageRouteInfo>? children})
>>>>>>> feat/dp-payment
    : super(FinancePlaceholderRoute.name, initialChildren: children);

  static const String name = 'FinancePlaceholderRoute';

<<<<<<< HEAD
  static _i48.PageInfo page = _i48.PageInfo(
=======
  static _i51.PageInfo page = _i51.PageInfo(
>>>>>>> feat/dp-payment
    name,
    builder: (data) {
      return const _i13.FinancePlaceholderPage();
    },
  );
}

/// generated route for
<<<<<<< HEAD
/// [_i14.GuestBillPaymentPage]
class GuestBillPaymentRoute
    extends _i48.PageRouteInfo<GuestBillPaymentRouteArgs> {
  GuestBillPaymentRoute({
    _i49.Key? key,
=======
/// [_i13.FineManagementPage]
class FineManagementRoute extends _i51.PageRouteInfo<void> {
  const FineManagementRoute({List<_i51.PageRouteInfo>? children})
    : super(FineManagementRoute.name, initialChildren: children);

  static const String name = 'FineManagementRoute';

  static _i51.PageInfo page = _i51.PageInfo(
    name,
    builder: (data) {
      return const _i13.FineManagementPage();
    },
  );
}

/// generated route for
/// [_i14.GuestBillPaymentPage]
class GuestBillPaymentRoute
    extends _i51.PageRouteInfo<GuestBillPaymentRouteArgs> {
  GuestBillPaymentRoute({
    _i52.Key? key,
>>>>>>> feat/dp-payment
    required int guestId,
    required String guestName,
    required double amount,
    String? billNumber,
<<<<<<< HEAD
    List<_i48.PageRouteInfo>? children,
=======
    List<_i51.PageRouteInfo>? children,
>>>>>>> feat/dp-payment
  }) : super(
         GuestBillPaymentRoute.name,
         args: GuestBillPaymentRouteArgs(
           key: key,
           guestId: guestId,
           guestName: guestName,
           amount: amount,
           billNumber: billNumber,
         ),
         initialChildren: children,
       );

  static const String name = 'GuestBillPaymentRoute';

<<<<<<< HEAD
  static _i48.PageInfo page = _i48.PageInfo(
=======
  static _i51.PageInfo page = _i51.PageInfo(
>>>>>>> feat/dp-payment
    name,
    builder: (data) {
      final args = data.argsAs<GuestBillPaymentRouteArgs>();
      return _i14.GuestBillPaymentPage(
        key: args.key,
        guestId: args.guestId,
        guestName: args.guestName,
        amount: args.amount,
        billNumber: args.billNumber,
      );
    },
  );
}

class GuestBillPaymentRouteArgs {
  const GuestBillPaymentRouteArgs({
    this.key,
    required this.guestId,
    required this.guestName,
    required this.amount,
    this.billNumber,
  });

<<<<<<< HEAD
  final _i49.Key? key;
=======
  final _i52.Key? key;
>>>>>>> feat/dp-payment

  final int guestId;

  final String guestName;

  final double amount;

  final String? billNumber;

  @override
  String toString() {
    return 'GuestBillPaymentRouteArgs{key: $key, guestId: $guestId, guestName: $guestName, amount: $amount, billNumber: $billNumber}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! GuestBillPaymentRouteArgs) return false;
    return key == other.key &&
        guestId == other.guestId &&
        guestName == other.guestName &&
        amount == other.amount &&
        billNumber == other.billNumber;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      guestId.hashCode ^
      guestName.hashCode ^
      amount.hashCode ^
      billNumber.hashCode;
}

/// generated route for
/// [_i15.GuestListPage]
<<<<<<< HEAD
class GuestListRoute extends _i48.PageRouteInfo<void> {
  const GuestListRoute({List<_i48.PageRouteInfo>? children})
=======
class GuestListRoute extends _i51.PageRouteInfo<void> {
  const GuestListRoute({List<_i51.PageRouteInfo>? children})
>>>>>>> feat/dp-payment
    : super(GuestListRoute.name, initialChildren: children);

  static const String name = 'GuestListRoute';

<<<<<<< HEAD
  static _i48.PageInfo page = _i48.PageInfo(
=======
  static _i51.PageInfo page = _i51.PageInfo(
>>>>>>> feat/dp-payment
    name,
    builder: (data) {
      return const _i15.GuestListPage();
    },
  );
}

/// generated route for
/// [_i16.IdentityFormPage]
<<<<<<< HEAD
class IdentityFormRoute extends _i48.PageRouteInfo<void> {
  const IdentityFormRoute({List<_i48.PageRouteInfo>? children})
=======
class IdentityFormRoute extends _i51.PageRouteInfo<void> {
  const IdentityFormRoute({List<_i51.PageRouteInfo>? children})
>>>>>>> feat/dp-payment
    : super(IdentityFormRoute.name, initialChildren: children);

  static const String name = 'IdentityFormRoute';

<<<<<<< HEAD
  static _i48.PageInfo page = _i48.PageInfo(
=======
  static _i51.PageInfo page = _i51.PageInfo(
>>>>>>> feat/dp-payment
    name,
    builder: (data) {
      return const _i16.IdentityFormPage();
    },
  );
}

/// generated route for
<<<<<<< HEAD
/// [_i13.InventoryAndMaintenancePlaceholderPage]
class InventoryAndMaintenancePlaceholderRoute extends _i48.PageRouteInfo<void> {
  const InventoryAndMaintenancePlaceholderRoute({
    List<_i48.PageRouteInfo>? children,
=======
/// [_i12.InventoryAndMaintenancePlaceholderPage]
class InventoryAndMaintenancePlaceholderRoute extends _i51.PageRouteInfo<void> {
  const InventoryAndMaintenancePlaceholderRoute({
    List<_i51.PageRouteInfo>? children,
>>>>>>> feat/dp-payment
  }) : super(
         InventoryAndMaintenancePlaceholderRoute.name,
         initialChildren: children,
       );

  static const String name = 'InventoryAndMaintenancePlaceholderRoute';

<<<<<<< HEAD
  static _i48.PageInfo page = _i48.PageInfo(
=======
  static _i51.PageInfo page = _i51.PageInfo(
>>>>>>> feat/dp-payment
    name,
    builder: (data) {
      return const _i13.InventoryAndMaintenancePlaceholderPage();
    },
  );
}

/// generated route for
/// [_i17.InventoryFormPage]
<<<<<<< HEAD
class InventoryFormRoute extends _i48.PageRouteInfo<InventoryFormRouteArgs> {
  InventoryFormRoute({
    _i49.Key? key,
    _i51.InventoryEntity? inventoryData,
    List<_i48.PageRouteInfo>? children,
=======
class InventoryFormRoute extends _i51.PageRouteInfo<InventoryFormRouteArgs> {
  InventoryFormRoute({
    _i52.Key? key,
    _i54.InventoryEntity? inventoryData,
    List<_i51.PageRouteInfo>? children,
>>>>>>> feat/dp-payment
  }) : super(
         InventoryFormRoute.name,
         args: InventoryFormRouteArgs(key: key, inventoryData: inventoryData),
         initialChildren: children,
       );

  static const String name = 'InventoryFormRoute';

<<<<<<< HEAD
  static _i48.PageInfo page = _i48.PageInfo(
=======
  static _i51.PageInfo page = _i51.PageInfo(
>>>>>>> feat/dp-payment
    name,
    builder: (data) {
      final args = data.argsAs<InventoryFormRouteArgs>(
        orElse: () => const InventoryFormRouteArgs(),
      );
      return _i17.InventoryFormPage(
        key: args.key,
        inventoryData: args.inventoryData,
      );
    },
  );
}

class InventoryFormRouteArgs {
  const InventoryFormRouteArgs({this.key, this.inventoryData});

<<<<<<< HEAD
  final _i49.Key? key;

  final _i51.InventoryEntity? inventoryData;
=======
  final _i52.Key? key;

  final _i54.InventoryEntity? inventoryData;
>>>>>>> feat/dp-payment

  @override
  String toString() {
    return 'InventoryFormRouteArgs{key: $key, inventoryData: $inventoryData}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! InventoryFormRouteArgs) return false;
    return key == other.key && inventoryData == other.inventoryData;
  }

  @override
  int get hashCode => key.hashCode ^ inventoryData.hashCode;
}

/// generated route for
/// [_i18.InventoryPage]
<<<<<<< HEAD
class InventoryRoute extends _i48.PageRouteInfo<void> {
  const InventoryRoute({List<_i48.PageRouteInfo>? children})
=======
class InventoryRoute extends _i51.PageRouteInfo<void> {
  const InventoryRoute({List<_i51.PageRouteInfo>? children})
>>>>>>> feat/dp-payment
    : super(InventoryRoute.name, initialChildren: children);

  static const String name = 'InventoryRoute';

<<<<<<< HEAD
  static _i48.PageInfo page = _i48.PageInfo(
=======
  static _i51.PageInfo page = _i51.PageInfo(
>>>>>>> feat/dp-payment
    name,
    builder: (data) {
      return const _i18.InventoryPage();
    },
  );
}

/// generated route for
/// [_i19.InvoiceListPage]
<<<<<<< HEAD
class InvoiceListRoute extends _i48.PageRouteInfo<void> {
  const InvoiceListRoute({List<_i48.PageRouteInfo>? children})
=======
class InvoiceListRoute extends _i51.PageRouteInfo<void> {
  const InvoiceListRoute({List<_i51.PageRouteInfo>? children})
>>>>>>> feat/dp-payment
    : super(InvoiceListRoute.name, initialChildren: children);

  static const String name = 'InvoiceListRoute';

<<<<<<< HEAD
  static _i48.PageInfo page = _i48.PageInfo(
=======
  static _i51.PageInfo page = _i51.PageInfo(
>>>>>>> feat/dp-payment
    name,
    builder: (data) {
      return const _i19.InvoiceListPage();
    },
  );
}

/// generated route for
<<<<<<< HEAD
/// [_i20.LandingPage]
class LandingRoute extends _i48.PageRouteInfo<void> {
  const LandingRoute({List<_i48.PageRouteInfo>? children})
=======
/// [_i20.InvoicePaymentPage]
class InvoicePaymentRoute extends _i51.PageRouteInfo<InvoicePaymentRouteArgs> {
  InvoicePaymentRoute({
    _i52.Key? key,
    required int invoiceId,
    required String invoiceNumber,
    required double amount,
    String? roomNumber,
    String? invoiceType,
    DateTime? dueDate,
    _i55.MemberFinanceBloc? bloc,
    List<_i51.PageRouteInfo>? children,
  }) : super(
         InvoicePaymentRoute.name,
         args: InvoicePaymentRouteArgs(
           key: key,
           invoiceId: invoiceId,
           invoiceNumber: invoiceNumber,
           amount: amount,
           roomNumber: roomNumber,
           invoiceType: invoiceType,
           dueDate: dueDate,
           bloc: bloc,
         ),
         initialChildren: children,
       );

  static const String name = 'InvoicePaymentRoute';

  static _i51.PageInfo page = _i51.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<InvoicePaymentRouteArgs>();
      return _i20.InvoicePaymentPage(
        key: args.key,
        invoiceId: args.invoiceId,
        invoiceNumber: args.invoiceNumber,
        amount: args.amount,
        roomNumber: args.roomNumber,
        invoiceType: args.invoiceType,
        dueDate: args.dueDate,
        bloc: args.bloc,
      );
    },
  );
}

class InvoicePaymentRouteArgs {
  const InvoicePaymentRouteArgs({
    this.key,
    required this.invoiceId,
    required this.invoiceNumber,
    required this.amount,
    this.roomNumber,
    this.invoiceType,
    this.dueDate,
    this.bloc,
  });

  final _i52.Key? key;

  final int invoiceId;

  final String invoiceNumber;

  final double amount;

  final String? roomNumber;

  final String? invoiceType;

  final DateTime? dueDate;

  final _i55.MemberFinanceBloc? bloc;

  @override
  String toString() {
    return 'InvoicePaymentRouteArgs{key: $key, invoiceId: $invoiceId, invoiceNumber: $invoiceNumber, amount: $amount, roomNumber: $roomNumber, invoiceType: $invoiceType, dueDate: $dueDate, bloc: $bloc}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! InvoicePaymentRouteArgs) return false;
    return key == other.key &&
        invoiceId == other.invoiceId &&
        invoiceNumber == other.invoiceNumber &&
        amount == other.amount &&
        roomNumber == other.roomNumber &&
        invoiceType == other.invoiceType &&
        dueDate == other.dueDate &&
        bloc == other.bloc;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      invoiceId.hashCode ^
      invoiceNumber.hashCode ^
      amount.hashCode ^
      roomNumber.hashCode ^
      invoiceType.hashCode ^
      dueDate.hashCode ^
      bloc.hashCode;
}

/// generated route for
/// [_i21.LandingPage]
class LandingRoute extends _i51.PageRouteInfo<void> {
  const LandingRoute({List<_i51.PageRouteInfo>? children})
>>>>>>> feat/dp-payment
    : super(LandingRoute.name, initialChildren: children);

  static const String name = 'LandingRoute';

<<<<<<< HEAD
  static _i48.PageInfo page = _i48.PageInfo(
    name,
    builder: (data) {
      return const _i20.LandingPage();
=======
  static _i51.PageInfo page = _i51.PageInfo(
    name,
    builder: (data) {
      return const _i21.LandingPage();
>>>>>>> feat/dp-payment
    },
  );
}

/// generated route for
<<<<<<< HEAD
/// [_i21.LoginPage]
class LoginRoute extends _i48.PageRouteInfo<LoginRouteArgs> {
  LoginRoute({
    _i49.Key? key,
    String? reason,
    _i52.RoomEntity? pendingRoom,
    List<_i48.PageRouteInfo>? children,
=======
/// [_i22.LoginPage]
class LoginRoute extends _i51.PageRouteInfo<LoginRouteArgs> {
  LoginRoute({
    _i52.Key? key,
    String? reason,
    _i56.RoomEntity? pendingRoom,
    List<_i51.PageRouteInfo>? children,
>>>>>>> feat/dp-payment
  }) : super(
         LoginRoute.name,
         args: LoginRouteArgs(
           key: key,
           reason: reason,
           pendingRoom: pendingRoom,
         ),
         rawQueryParams: {'reason': reason},
         initialChildren: children,
       );

  static const String name = 'LoginRoute';

<<<<<<< HEAD
  static _i48.PageInfo page = _i48.PageInfo(
=======
  static _i51.PageInfo page = _i51.PageInfo(
>>>>>>> feat/dp-payment
    name,
    builder: (data) {
      final queryParams = data.queryParams;
      final args = data.argsAs<LoginRouteArgs>(
        orElse: () => LoginRouteArgs(reason: queryParams.optString('reason')),
      );
<<<<<<< HEAD
      return _i21.LoginPage(
=======
      return _i22.LoginPage(
>>>>>>> feat/dp-payment
        key: args.key,
        reason: args.reason,
        pendingRoom: args.pendingRoom,
      );
    },
  );
}

class LoginRouteArgs {
  const LoginRouteArgs({this.key, this.reason, this.pendingRoom});

<<<<<<< HEAD
  final _i49.Key? key;

  final String? reason;

  final _i52.RoomEntity? pendingRoom;
=======
  final _i52.Key? key;

  final String? reason;

  final _i56.RoomEntity? pendingRoom;
>>>>>>> feat/dp-payment

  @override
  String toString() {
    return 'LoginRouteArgs{key: $key, reason: $reason, pendingRoom: $pendingRoom}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! LoginRouteArgs) return false;
    return key == other.key &&
        reason == other.reason &&
        pendingRoom == other.pendingRoom;
  }

  @override
  int get hashCode => key.hashCode ^ reason.hashCode ^ pendingRoom.hashCode;
}

/// generated route for
<<<<<<< HEAD
/// [_i22.MaintananceDetailPage]
class MaintananceDetailRoute
    extends _i48.PageRouteInfo<MaintananceDetailRouteArgs> {
  MaintananceDetailRoute({
    _i49.Key? key,
    required _i53.ScheduleEntity schedule,
    List<_i48.PageRouteInfo>? children,
=======
/// [_i23.MaintananceDetailPage]
class MaintananceDetailRoute
    extends _i51.PageRouteInfo<MaintananceDetailRouteArgs> {
  MaintananceDetailRoute({
    _i52.Key? key,
    required _i57.ScheduleEntity schedule,
    List<_i51.PageRouteInfo>? children,
>>>>>>> feat/dp-payment
  }) : super(
         MaintananceDetailRoute.name,
         args: MaintananceDetailRouteArgs(key: key, schedule: schedule),
         initialChildren: children,
       );

  static const String name = 'MaintananceDetailRoute';

<<<<<<< HEAD
  static _i48.PageInfo page = _i48.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<MaintananceDetailRouteArgs>();
      return _i22.MaintananceDetailPage(key: args.key, schedule: args.schedule);
=======
  static _i51.PageInfo page = _i51.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<MaintananceDetailRouteArgs>();
      return _i23.MaintananceDetailPage(key: args.key, schedule: args.schedule);
>>>>>>> feat/dp-payment
    },
  );
}

class MaintananceDetailRouteArgs {
  const MaintananceDetailRouteArgs({this.key, required this.schedule});

<<<<<<< HEAD
  final _i49.Key? key;

  final _i53.ScheduleEntity schedule;
=======
  final _i52.Key? key;

  final _i57.ScheduleEntity schedule;
>>>>>>> feat/dp-payment

  @override
  String toString() {
    return 'MaintananceDetailRouteArgs{key: $key, schedule: $schedule}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! MaintananceDetailRouteArgs) return false;
    return key == other.key && schedule == other.schedule;
  }

  @override
  int get hashCode => key.hashCode ^ schedule.hashCode;
}

/// generated route for
<<<<<<< HEAD
/// [_i23.MaintananceFormPage]
class MaintananceFormRoute
    extends _i48.PageRouteInfo<MaintananceFormRouteArgs> {
  MaintananceFormRoute({
    _i49.Key? key,
    _i53.ScheduleEntity? scheduleData,
    List<_i48.PageRouteInfo>? children,
=======
/// [_i24.MaintananceFormPage]
class MaintananceFormRoute
    extends _i51.PageRouteInfo<MaintananceFormRouteArgs> {
  MaintananceFormRoute({
    _i52.Key? key,
    _i57.ScheduleEntity? scheduleData,
    List<_i51.PageRouteInfo>? children,
>>>>>>> feat/dp-payment
  }) : super(
         MaintananceFormRoute.name,
         args: MaintananceFormRouteArgs(key: key, scheduleData: scheduleData),
         initialChildren: children,
       );

  static const String name = 'MaintananceFormRoute';

<<<<<<< HEAD
  static _i48.PageInfo page = _i48.PageInfo(
=======
  static _i51.PageInfo page = _i51.PageInfo(
>>>>>>> feat/dp-payment
    name,
    builder: (data) {
      final args = data.argsAs<MaintananceFormRouteArgs>(
        orElse: () => const MaintananceFormRouteArgs(),
      );
<<<<<<< HEAD
      return _i23.MaintananceFormPage(
=======
      return _i24.MaintananceFormPage(
>>>>>>> feat/dp-payment
        key: args.key,
        scheduleData: args.scheduleData,
      );
    },
  );
}

class MaintananceFormRouteArgs {
  const MaintananceFormRouteArgs({this.key, this.scheduleData});

<<<<<<< HEAD
  final _i49.Key? key;

  final _i53.ScheduleEntity? scheduleData;
=======
  final _i52.Key? key;

  final _i57.ScheduleEntity? scheduleData;
>>>>>>> feat/dp-payment

  @override
  String toString() {
    return 'MaintananceFormRouteArgs{key: $key, scheduleData: $scheduleData}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! MaintananceFormRouteArgs) return false;
    return key == other.key && scheduleData == other.scheduleData;
  }

  @override
  int get hashCode => key.hashCode ^ scheduleData.hashCode;
}

/// generated route for
<<<<<<< HEAD
/// [_i24.MaintanancePage]
class MaintananceRoute extends _i48.PageRouteInfo<void> {
  const MaintananceRoute({List<_i48.PageRouteInfo>? children})
=======
/// [_i25.MaintanancePage]
class MaintananceRoute extends _i51.PageRouteInfo<void> {
  const MaintananceRoute({List<_i51.PageRouteInfo>? children})
>>>>>>> feat/dp-payment
    : super(MaintananceRoute.name, initialChildren: children);

  static const String name = 'MaintananceRoute';

<<<<<<< HEAD
  static _i48.PageInfo page = _i48.PageInfo(
    name,
    builder: (data) {
      return const _i24.MaintanancePage();
=======
  static _i51.PageInfo page = _i51.PageInfo(
    name,
    builder: (data) {
      return const _i25.MaintanancePage();
>>>>>>> feat/dp-payment
    },
  );
}

/// generated route for
<<<<<<< HEAD
/// [_i25.MaintenanceCreateReportPage]
class MaintenanceCreateReportRoute extends _i48.PageRouteInfo<void> {
  const MaintenanceCreateReportRoute({List<_i48.PageRouteInfo>? children})
=======
/// [_i26.MaintenanceCreateReportPage]
class MaintenanceCreateReportRoute extends _i51.PageRouteInfo<void> {
  const MaintenanceCreateReportRoute({List<_i51.PageRouteInfo>? children})
>>>>>>> feat/dp-payment
    : super(MaintenanceCreateReportRoute.name, initialChildren: children);

  static const String name = 'MaintenanceCreateReportRoute';

<<<<<<< HEAD
  static _i48.PageInfo page = _i48.PageInfo(
    name,
    builder: (data) {
      return const _i25.MaintenanceCreateReportPage();
=======
  static _i51.PageInfo page = _i51.PageInfo(
    name,
    builder: (data) {
      return const _i26.MaintenanceCreateReportPage();
>>>>>>> feat/dp-payment
    },
  );
}

/// generated route for
<<<<<<< HEAD
/// [_i26.MaintenanceReportDetailPage]
class MaintenanceReportDetailRoute
    extends _i48.PageRouteInfo<MaintenanceReportDetailRouteArgs> {
  MaintenanceReportDetailRoute({
    _i49.Key? key,
    required int id,
    List<_i48.PageRouteInfo>? children,
=======
/// [_i27.MaintenanceReportDetailPage]
class MaintenanceReportDetailRoute
    extends _i51.PageRouteInfo<MaintenanceReportDetailRouteArgs> {
  MaintenanceReportDetailRoute({
    _i52.Key? key,
    required int id,
    List<_i51.PageRouteInfo>? children,
>>>>>>> feat/dp-payment
  }) : super(
         MaintenanceReportDetailRoute.name,
         args: MaintenanceReportDetailRouteArgs(key: key, id: id),
         rawPathParams: {'id': id},
         initialChildren: children,
       );

  static const String name = 'MaintenanceReportDetailRoute';

<<<<<<< HEAD
  static _i48.PageInfo page = _i48.PageInfo(
=======
  static _i51.PageInfo page = _i51.PageInfo(
>>>>>>> feat/dp-payment
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<MaintenanceReportDetailRouteArgs>(
        orElse: () =>
            MaintenanceReportDetailRouteArgs(id: pathParams.getInt('id')),
      );
<<<<<<< HEAD
      return _i26.MaintenanceReportDetailPage(key: args.key, id: args.id);
=======
      return _i27.MaintenanceReportDetailPage(key: args.key, id: args.id);
>>>>>>> feat/dp-payment
    },
  );
}

class MaintenanceReportDetailRouteArgs {
  const MaintenanceReportDetailRouteArgs({this.key, required this.id});

<<<<<<< HEAD
  final _i49.Key? key;
=======
  final _i52.Key? key;
>>>>>>> feat/dp-payment

  final int id;

  @override
  String toString() {
    return 'MaintenanceReportDetailRouteArgs{key: $key, id: $id}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! MaintenanceReportDetailRouteArgs) return false;
    return key == other.key && id == other.id;
  }

  @override
  int get hashCode => key.hashCode ^ id.hashCode;
}

/// generated route for
<<<<<<< HEAD
/// [_i27.MaintenanceReportListPage]
class MaintenanceReportListRoute extends _i48.PageRouteInfo<void> {
  const MaintenanceReportListRoute({List<_i48.PageRouteInfo>? children})
=======
/// [_i28.MaintenanceReportListPage]
class MaintenanceReportListRoute extends _i51.PageRouteInfo<void> {
  const MaintenanceReportListRoute({List<_i51.PageRouteInfo>? children})
>>>>>>> feat/dp-payment
    : super(MaintenanceReportListRoute.name, initialChildren: children);

  static const String name = 'MaintenanceReportListRoute';

<<<<<<< HEAD
  static _i48.PageInfo page = _i48.PageInfo(
    name,
    builder: (data) {
      return const _i27.MaintenanceReportListPage();
=======
  static _i51.PageInfo page = _i51.PageInfo(
    name,
    builder: (data) {
      return const _i28.MaintenanceReportListPage();
>>>>>>> feat/dp-payment
    },
  );
}

/// generated route for
<<<<<<< HEAD
/// [_i28.MemberFinancePage]
class MemberFinanceRoute extends _i48.PageRouteInfo<void> {
  const MemberFinanceRoute({List<_i48.PageRouteInfo>? children})
=======
/// [_i29.MemberFinancePage]
class MemberFinanceRoute extends _i51.PageRouteInfo<void> {
  const MemberFinanceRoute({List<_i51.PageRouteInfo>? children})
>>>>>>> feat/dp-payment
    : super(MemberFinanceRoute.name, initialChildren: children);

  static const String name = 'MemberFinanceRoute';

<<<<<<< HEAD
  static _i48.PageInfo page = _i48.PageInfo(
    name,
    builder: (data) {
      return const _i28.MemberFinancePage();
=======
  static _i51.PageInfo page = _i51.PageInfo(
    name,
    builder: (data) {
      return const _i29.MemberFinancePage();
>>>>>>> feat/dp-payment
    },
  );
}

/// generated route for
<<<<<<< HEAD
/// [_i29.MidtransPaymentPage]
class MidtransPaymentRoute
    extends _i48.PageRouteInfo<MidtransPaymentRouteArgs> {
  MidtransPaymentRoute({
    _i49.Key? key,
    required _i54.ReservationEntity reservation,
    List<_i48.PageRouteInfo>? children,
=======
/// [_i30.MidtransPaymentPage]
class MidtransPaymentRoute
    extends _i51.PageRouteInfo<MidtransPaymentRouteArgs> {
  MidtransPaymentRoute({
    _i52.Key? key,
    required _i58.ReservationEntity reservation,
    List<_i51.PageRouteInfo>? children,
>>>>>>> feat/dp-payment
  }) : super(
         MidtransPaymentRoute.name,
         args: MidtransPaymentRouteArgs(key: key, reservation: reservation),
         initialChildren: children,
       );

  static const String name = 'MidtransPaymentRoute';

<<<<<<< HEAD
  static _i48.PageInfo page = _i48.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<MidtransPaymentRouteArgs>();
      return _i29.MidtransPaymentPage(
=======
  static _i51.PageInfo page = _i51.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<MidtransPaymentRouteArgs>();
      return _i30.MidtransPaymentPage(
>>>>>>> feat/dp-payment
        key: args.key,
        reservation: args.reservation,
      );
    },
  );
}

class MidtransPaymentRouteArgs {
  const MidtransPaymentRouteArgs({this.key, required this.reservation});

<<<<<<< HEAD
  final _i49.Key? key;

  final _i54.ReservationEntity reservation;
=======
  final _i52.Key? key;

  final _i58.ReservationEntity reservation;
>>>>>>> feat/dp-payment

  @override
  String toString() {
    return 'MidtransPaymentRouteArgs{key: $key, reservation: $reservation}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! MidtransPaymentRouteArgs) return false;
    return key == other.key && reservation == other.reservation;
  }

  @override
  int get hashCode => key.hashCode ^ reservation.hashCode;
}

/// generated route for
<<<<<<< HEAD
/// [_i30.MyGuestPage]
class MyGuestRoute extends _i48.PageRouteInfo<void> {
  const MyGuestRoute({List<_i48.PageRouteInfo>? children})
=======
/// [_i31.MyFinesPage]
class MyFinesRoute extends _i51.PageRouteInfo<void> {
  const MyFinesRoute({List<_i51.PageRouteInfo>? children})
    : super(MyFinesRoute.name, initialChildren: children);

  static const String name = 'MyFinesRoute';

  static _i51.PageInfo page = _i51.PageInfo(
    name,
    builder: (data) {
      return const _i31.MyFinesPage();
    },
  );
}

/// generated route for
/// [_i32.MyGuestPage]
class MyGuestRoute extends _i51.PageRouteInfo<void> {
  const MyGuestRoute({List<_i51.PageRouteInfo>? children})
>>>>>>> feat/dp-payment
    : super(MyGuestRoute.name, initialChildren: children);

  static const String name = 'MyGuestRoute';

<<<<<<< HEAD
  static _i48.PageInfo page = _i48.PageInfo(
    name,
    builder: (data) {
      return const _i30.MyGuestPage();
=======
  static _i51.PageInfo page = _i51.PageInfo(
    name,
    builder: (data) {
      return const _i32.MyGuestPage();
>>>>>>> feat/dp-payment
    },
  );
}

/// generated route for
<<<<<<< HEAD
/// [_i31.MyReservationPage]
class MyReservationRoute extends _i48.PageRouteInfo<void> {
  const MyReservationRoute({List<_i48.PageRouteInfo>? children})
=======
/// [_i33.MyReservationPage]
class MyReservationRoute extends _i51.PageRouteInfo<void> {
  const MyReservationRoute({List<_i51.PageRouteInfo>? children})
>>>>>>> feat/dp-payment
    : super(MyReservationRoute.name, initialChildren: children);

  static const String name = 'MyReservationRoute';

<<<<<<< HEAD
  static _i48.PageInfo page = _i48.PageInfo(
    name,
    builder: (data) {
      return const _i31.MyReservationPage();
=======
  static _i51.PageInfo page = _i51.PageInfo(
    name,
    builder: (data) {
      return const _i33.MyReservationPage();
>>>>>>> feat/dp-payment
    },
  );
}

/// generated route for
<<<<<<< HEAD
/// [_i32.PaymentUploadPage]
class PaymentUploadRoute extends _i48.PageRouteInfo<PaymentUploadRouteArgs> {
  PaymentUploadRoute({
    _i49.Key? key,
    required _i54.ReservationEntity reservation,
    List<_i48.PageRouteInfo>? children,
=======
/// [_i34.NotificationMonitoringPage]
class NotificationMonitoringRoute extends _i51.PageRouteInfo<void> {
  const NotificationMonitoringRoute({List<_i51.PageRouteInfo>? children})
    : super(NotificationMonitoringRoute.name, initialChildren: children);

  static const String name = 'NotificationMonitoringRoute';

  static _i51.PageInfo page = _i51.PageInfo(
    name,
    builder: (data) {
      return const _i34.NotificationMonitoringPage();
    },
  );
}

/// generated route for
/// [_i35.PaymentUploadPage]
class PaymentUploadRoute extends _i51.PageRouteInfo<PaymentUploadRouteArgs> {
  PaymentUploadRoute({
    _i52.Key? key,
    required _i58.ReservationEntity reservation,
    List<_i51.PageRouteInfo>? children,
>>>>>>> feat/dp-payment
  }) : super(
         PaymentUploadRoute.name,
         args: PaymentUploadRouteArgs(key: key, reservation: reservation),
         initialChildren: children,
       );

  static const String name = 'PaymentUploadRoute';

<<<<<<< HEAD
  static _i48.PageInfo page = _i48.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<PaymentUploadRouteArgs>();
      return _i32.PaymentUploadPage(
=======
  static _i51.PageInfo page = _i51.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<PaymentUploadRouteArgs>();
      return _i35.PaymentUploadPage(
>>>>>>> feat/dp-payment
        key: args.key,
        reservation: args.reservation,
      );
    },
  );
}

class PaymentUploadRouteArgs {
  const PaymentUploadRouteArgs({this.key, required this.reservation});

<<<<<<< HEAD
  final _i49.Key? key;

  final _i54.ReservationEntity reservation;
=======
  final _i52.Key? key;

  final _i58.ReservationEntity reservation;
>>>>>>> feat/dp-payment

  @override
  String toString() {
    return 'PaymentUploadRouteArgs{key: $key, reservation: $reservation}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PaymentUploadRouteArgs) return false;
    return key == other.key && reservation == other.reservation;
  }

  @override
  int get hashCode => key.hashCode ^ reservation.hashCode;
}

/// generated route for
<<<<<<< HEAD
/// [_i33.PaymentVerificationPage]
class PaymentVerificationRoute extends _i48.PageRouteInfo<void> {
  const PaymentVerificationRoute({List<_i48.PageRouteInfo>? children})
=======
/// [_i36.PaymentVerificationPage]
class PaymentVerificationRoute extends _i51.PageRouteInfo<void> {
  const PaymentVerificationRoute({List<_i51.PageRouteInfo>? children})
>>>>>>> feat/dp-payment
    : super(PaymentVerificationRoute.name, initialChildren: children);

  static const String name = 'PaymentVerificationRoute';

<<<<<<< HEAD
  static _i48.PageInfo page = _i48.PageInfo(
    name,
    builder: (data) {
      return const _i33.PaymentVerificationPage();
=======
  static _i51.PageInfo page = _i51.PageInfo(
    name,
    builder: (data) {
      return const _i36.PaymentVerificationPage();
>>>>>>> feat/dp-payment
    },
  );
}

/// generated route for
<<<<<<< HEAD
/// [_i34.PermissionDetailPage]
class PermissionDetailRoute
    extends _i48.PageRouteInfo<PermissionDetailRouteArgs> {
  PermissionDetailRoute({
    _i49.Key? key,
    required int id,
    List<_i48.PageRouteInfo>? children,
=======
/// [_i37.PermissionDetailPage]
class PermissionDetailRoute
    extends _i51.PageRouteInfo<PermissionDetailRouteArgs> {
  PermissionDetailRoute({
    _i52.Key? key,
    required int id,
    List<_i51.PageRouteInfo>? children,
>>>>>>> feat/dp-payment
  }) : super(
         PermissionDetailRoute.name,
         args: PermissionDetailRouteArgs(key: key, id: id),
         rawPathParams: {'id': id},
         initialChildren: children,
       );

  static const String name = 'PermissionDetailRoute';

<<<<<<< HEAD
  static _i48.PageInfo page = _i48.PageInfo(
=======
  static _i51.PageInfo page = _i51.PageInfo(
>>>>>>> feat/dp-payment
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<PermissionDetailRouteArgs>(
        orElse: () => PermissionDetailRouteArgs(id: pathParams.getInt('id')),
      );
<<<<<<< HEAD
      return _i34.PermissionDetailPage(key: args.key, id: args.id);
=======
      return _i37.PermissionDetailPage(key: args.key, id: args.id);
>>>>>>> feat/dp-payment
    },
  );
}

class PermissionDetailRouteArgs {
  const PermissionDetailRouteArgs({this.key, required this.id});

<<<<<<< HEAD
  final _i49.Key? key;
=======
  final _i52.Key? key;
>>>>>>> feat/dp-payment

  final int id;

  @override
  String toString() {
    return 'PermissionDetailRouteArgs{key: $key, id: $id}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PermissionDetailRouteArgs) return false;
    return key == other.key && id == other.id;
  }

  @override
  int get hashCode => key.hashCode ^ id.hashCode;
}

/// generated route for
<<<<<<< HEAD
/// [_i35.PermissionPage]
class PermissionRoute extends _i48.PageRouteInfo<void> {
  const PermissionRoute({List<_i48.PageRouteInfo>? children})
=======
/// [_i38.PermissionPage]
class PermissionRoute extends _i51.PageRouteInfo<void> {
  const PermissionRoute({List<_i51.PageRouteInfo>? children})
>>>>>>> feat/dp-payment
    : super(PermissionRoute.name, initialChildren: children);

  static const String name = 'PermissionRoute';

<<<<<<< HEAD
  static _i48.PageInfo page = _i48.PageInfo(
    name,
    builder: (data) {
      return const _i35.PermissionPage();
=======
  static _i51.PageInfo page = _i51.PageInfo(
    name,
    builder: (data) {
      return const _i38.PermissionPage();
>>>>>>> feat/dp-payment
    },
  );
}

/// generated route for
<<<<<<< HEAD
/// [_i13.PermissionPlaceholderPage]
class PermissionPlaceholderRoute extends _i48.PageRouteInfo<void> {
  const PermissionPlaceholderRoute({List<_i48.PageRouteInfo>? children})
=======
/// [_i12.PermissionPlaceholderPage]
class PermissionPlaceholderRoute extends _i51.PageRouteInfo<void> {
  const PermissionPlaceholderRoute({List<_i51.PageRouteInfo>? children})
>>>>>>> feat/dp-payment
    : super(PermissionPlaceholderRoute.name, initialChildren: children);

  static const String name = 'PermissionPlaceholderRoute';

<<<<<<< HEAD
  static _i48.PageInfo page = _i48.PageInfo(
=======
  static _i51.PageInfo page = _i51.PageInfo(
>>>>>>> feat/dp-payment
    name,
    builder: (data) {
      return const _i13.PermissionPlaceholderPage();
    },
  );
}

/// generated route for
<<<<<<< HEAD
/// [_i36.ProfilePage]
class ProfileRoute extends _i48.PageRouteInfo<void> {
  const ProfileRoute({List<_i48.PageRouteInfo>? children})
=======
/// [_i39.ProfilePage]
class ProfileRoute extends _i51.PageRouteInfo<void> {
  const ProfileRoute({List<_i51.PageRouteInfo>? children})
>>>>>>> feat/dp-payment
    : super(ProfileRoute.name, initialChildren: children);

  static const String name = 'ProfileRoute';

<<<<<<< HEAD
  static _i48.PageInfo page = _i48.PageInfo(
    name,
    builder: (data) {
      return const _i36.ProfilePage();
=======
  static _i51.PageInfo page = _i51.PageInfo(
    name,
    builder: (data) {
      return const _i39.ProfilePage();
>>>>>>> feat/dp-payment
    },
  );
}

/// generated route for
<<<<<<< HEAD
/// [_i37.ProfileUserPage]
class ProfileUserRoute extends _i48.PageRouteInfo<void> {
  const ProfileUserRoute({List<_i48.PageRouteInfo>? children})
=======
/// [_i40.ProfileUserPage]
class ProfileUserRoute extends _i51.PageRouteInfo<void> {
  const ProfileUserRoute({List<_i51.PageRouteInfo>? children})
>>>>>>> feat/dp-payment
    : super(ProfileUserRoute.name, initialChildren: children);

  static const String name = 'ProfileUserRoute';

<<<<<<< HEAD
  static _i48.PageInfo page = _i48.PageInfo(
    name,
    builder: (data) {
      return const _i37.ProfileUserPage();
=======
  static _i51.PageInfo page = _i51.PageInfo(
    name,
    builder: (data) {
      return const _i40.ProfileUserPage();
>>>>>>> feat/dp-payment
    },
  );
}

/// generated route for
<<<<<<< HEAD
/// [_i38.RegisterPage]
class RegisterRoute extends _i48.PageRouteInfo<RegisterRouteArgs> {
  RegisterRoute({
    _i49.Key? key,
    _i52.RoomEntity? pendingRoom,
    List<_i48.PageRouteInfo>? children,
=======
/// [_i41.RegisterPage]
class RegisterRoute extends _i51.PageRouteInfo<RegisterRouteArgs> {
  RegisterRoute({
    _i52.Key? key,
    _i56.RoomEntity? pendingRoom,
    List<_i51.PageRouteInfo>? children,
>>>>>>> feat/dp-payment
  }) : super(
         RegisterRoute.name,
         args: RegisterRouteArgs(key: key, pendingRoom: pendingRoom),
         initialChildren: children,
       );

  static const String name = 'RegisterRoute';

<<<<<<< HEAD
  static _i48.PageInfo page = _i48.PageInfo(
=======
  static _i51.PageInfo page = _i51.PageInfo(
>>>>>>> feat/dp-payment
    name,
    builder: (data) {
      final args = data.argsAs<RegisterRouteArgs>(
        orElse: () => const RegisterRouteArgs(),
      );
<<<<<<< HEAD
      return _i38.RegisterPage(key: args.key, pendingRoom: args.pendingRoom);
=======
      return _i41.RegisterPage(key: args.key, pendingRoom: args.pendingRoom);
>>>>>>> feat/dp-payment
    },
  );
}

class RegisterRouteArgs {
  const RegisterRouteArgs({this.key, this.pendingRoom});

<<<<<<< HEAD
  final _i49.Key? key;

  final _i52.RoomEntity? pendingRoom;
=======
  final _i52.Key? key;

  final _i56.RoomEntity? pendingRoom;
>>>>>>> feat/dp-payment

  @override
  String toString() {
    return 'RegisterRouteArgs{key: $key, pendingRoom: $pendingRoom}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! RegisterRouteArgs) return false;
    return key == other.key && pendingRoom == other.pendingRoom;
  }

  @override
  int get hashCode => key.hashCode ^ pendingRoom.hashCode;
}

/// generated route for
<<<<<<< HEAD
/// [_i39.ReservationDetailFormPage]
class ReservationDetailFormRoute
    extends _i48.PageRouteInfo<ReservationDetailFormRouteArgs> {
  ReservationDetailFormRoute({
    _i49.Key? key,
    required _i52.RoomEntity room,
    List<_i48.PageRouteInfo>? children,
=======
/// [_i42.ReservationDetailFormPage]
class ReservationDetailFormRoute
    extends _i51.PageRouteInfo<ReservationDetailFormRouteArgs> {
  ReservationDetailFormRoute({
    _i52.Key? key,
    required _i56.RoomEntity room,
    List<_i51.PageRouteInfo>? children,
>>>>>>> feat/dp-payment
  }) : super(
         ReservationDetailFormRoute.name,
         args: ReservationDetailFormRouteArgs(key: key, room: room),
         initialChildren: children,
       );

  static const String name = 'ReservationDetailFormRoute';

<<<<<<< HEAD
  static _i48.PageInfo page = _i48.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ReservationDetailFormRouteArgs>();
      return _i39.ReservationDetailFormPage(key: args.key, room: args.room);
=======
  static _i51.PageInfo page = _i51.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ReservationDetailFormRouteArgs>();
      return _i42.ReservationDetailFormPage(key: args.key, room: args.room);
>>>>>>> feat/dp-payment
    },
  );
}

class ReservationDetailFormRouteArgs {
  const ReservationDetailFormRouteArgs({this.key, required this.room});

<<<<<<< HEAD
  final _i49.Key? key;

  final _i52.RoomEntity room;
=======
  final _i52.Key? key;

  final _i56.RoomEntity room;
>>>>>>> feat/dp-payment

  @override
  String toString() {
    return 'ReservationDetailFormRouteArgs{key: $key, room: $room}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ReservationDetailFormRouteArgs) return false;
    return key == other.key && room == other.room;
  }

  @override
  int get hashCode => key.hashCode ^ room.hashCode;
}

/// generated route for
<<<<<<< HEAD
/// [_i40.ReservationPage]
class ReservationRoute extends _i48.PageRouteInfo<void> {
  const ReservationRoute({List<_i48.PageRouteInfo>? children})
=======
/// [_i43.ReservationPage]
class ReservationRoute extends _i51.PageRouteInfo<void> {
  const ReservationRoute({List<_i51.PageRouteInfo>? children})
>>>>>>> feat/dp-payment
    : super(ReservationRoute.name, initialChildren: children);

  static const String name = 'ReservationRoute';

<<<<<<< HEAD
  static _i48.PageInfo page = _i48.PageInfo(
    name,
    builder: (data) {
      return const _i40.ReservationPage();
=======
  static _i51.PageInfo page = _i51.PageInfo(
    name,
    builder: (data) {
      return const _i43.ReservationPage();
>>>>>>> feat/dp-payment
    },
  );
}

/// generated route for
<<<<<<< HEAD
/// [_i41.ResidentPage]
class ResidentRoute extends _i48.PageRouteInfo<void> {
  const ResidentRoute({List<_i48.PageRouteInfo>? children})
=======
/// [_i44.ResidentPage]
class ResidentRoute extends _i51.PageRouteInfo<void> {
  const ResidentRoute({List<_i51.PageRouteInfo>? children})
>>>>>>> feat/dp-payment
    : super(ResidentRoute.name, initialChildren: children);

  static const String name = 'ResidentRoute';

<<<<<<< HEAD
  static _i48.PageInfo page = _i48.PageInfo(
    name,
    builder: (data) {
      return const _i41.ResidentPage();
=======
  static _i51.PageInfo page = _i51.PageInfo(
    name,
    builder: (data) {
      return const _i44.ResidentPage();
>>>>>>> feat/dp-payment
    },
  );
}

/// generated route for
<<<<<<< HEAD
/// [_i13.ResidentPlaceholderPage]
class ResidentPlaceholderRoute extends _i48.PageRouteInfo<void> {
  const ResidentPlaceholderRoute({List<_i48.PageRouteInfo>? children})
=======
/// [_i12.ResidentPlaceholderPage]
class ResidentPlaceholderRoute extends _i51.PageRouteInfo<void> {
  const ResidentPlaceholderRoute({List<_i51.PageRouteInfo>? children})
>>>>>>> feat/dp-payment
    : super(ResidentPlaceholderRoute.name, initialChildren: children);

  static const String name = 'ResidentPlaceholderRoute';

<<<<<<< HEAD
  static _i48.PageInfo page = _i48.PageInfo(
=======
  static _i51.PageInfo page = _i51.PageInfo(
>>>>>>> feat/dp-payment
    name,
    builder: (data) {
      return const _i13.ResidentPlaceholderPage();
    },
  );
}

/// generated route for
<<<<<<< HEAD
/// [_i42.RoleManagementPage]
class RoleManagementRoute extends _i48.PageRouteInfo<void> {
  const RoleManagementRoute({List<_i48.PageRouteInfo>? children})
=======
/// [_i45.RoleManagementPage]
class RoleManagementRoute extends _i51.PageRouteInfo<void> {
  const RoleManagementRoute({List<_i51.PageRouteInfo>? children})
>>>>>>> feat/dp-payment
    : super(RoleManagementRoute.name, initialChildren: children);

  static const String name = 'RoleManagementRoute';

<<<<<<< HEAD
  static _i48.PageInfo page = _i48.PageInfo(
    name,
    builder: (data) {
      return const _i42.RoleManagementPage();
=======
  static _i51.PageInfo page = _i51.PageInfo(
    name,
    builder: (data) {
      return const _i45.RoleManagementPage();
>>>>>>> feat/dp-payment
    },
  );
}

/// generated route for
<<<<<<< HEAD
/// [_i13.RolePlaceholderPage]
class RolePlaceholderRoute extends _i48.PageRouteInfo<void> {
  const RolePlaceholderRoute({List<_i48.PageRouteInfo>? children})
=======
/// [_i12.RolePlaceholderPage]
class RolePlaceholderRoute extends _i51.PageRouteInfo<void> {
  const RolePlaceholderRoute({List<_i51.PageRouteInfo>? children})
>>>>>>> feat/dp-payment
    : super(RolePlaceholderRoute.name, initialChildren: children);

  static const String name = 'RolePlaceholderRoute';

<<<<<<< HEAD
  static _i48.PageInfo page = _i48.PageInfo(
=======
  static _i51.PageInfo page = _i51.PageInfo(
>>>>>>> feat/dp-payment
    name,
    builder: (data) {
      return const _i13.RolePlaceholderPage();
    },
  );
}

/// generated route for
<<<<<<< HEAD
/// [_i13.RoomAndReservationPlaceholderPage]
class RoomAndReservationPlaceholderRoute extends _i48.PageRouteInfo<void> {
  const RoomAndReservationPlaceholderRoute({List<_i48.PageRouteInfo>? children})
=======
/// [_i12.RoomAndReservationPlaceholderPage]
class RoomAndReservationPlaceholderRoute extends _i51.PageRouteInfo<void> {
  const RoomAndReservationPlaceholderRoute({List<_i51.PageRouteInfo>? children})
>>>>>>> feat/dp-payment
    : super(RoomAndReservationPlaceholderRoute.name, initialChildren: children);

  static const String name = 'RoomAndReservationPlaceholderRoute';

<<<<<<< HEAD
  static _i48.PageInfo page = _i48.PageInfo(
=======
  static _i51.PageInfo page = _i51.PageInfo(
>>>>>>> feat/dp-payment
    name,
    builder: (data) {
      return const _i13.RoomAndReservationPlaceholderPage();
    },
  );
}

/// generated route for
<<<<<<< HEAD
/// [_i43.RoomDetailPage]
class RoomDetailRoute extends _i48.PageRouteInfo<RoomDetailRouteArgs> {
  RoomDetailRoute({
    _i49.Key? key,
    required int roomId,
    List<_i48.PageRouteInfo>? children,
=======
/// [_i46.RoomDetailPage]
class RoomDetailRoute extends _i51.PageRouteInfo<RoomDetailRouteArgs> {
  RoomDetailRoute({
    _i52.Key? key,
    required int roomId,
    List<_i51.PageRouteInfo>? children,
>>>>>>> feat/dp-payment
  }) : super(
         RoomDetailRoute.name,
         args: RoomDetailRouteArgs(key: key, roomId: roomId),
         rawPathParams: {'id': roomId},
         initialChildren: children,
       );

  static const String name = 'RoomDetailRoute';

<<<<<<< HEAD
  static _i48.PageInfo page = _i48.PageInfo(
=======
  static _i51.PageInfo page = _i51.PageInfo(
>>>>>>> feat/dp-payment
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<RoomDetailRouteArgs>(
        orElse: () => RoomDetailRouteArgs(roomId: pathParams.getInt('id')),
      );
<<<<<<< HEAD
      return _i43.RoomDetailPage(key: args.key, roomId: args.roomId);
=======
      return _i46.RoomDetailPage(key: args.key, roomId: args.roomId);
>>>>>>> feat/dp-payment
    },
  );
}

class RoomDetailRouteArgs {
  const RoomDetailRouteArgs({this.key, required this.roomId});

<<<<<<< HEAD
  final _i49.Key? key;
=======
  final _i52.Key? key;
>>>>>>> feat/dp-payment

  final int roomId;

  @override
  String toString() {
    return 'RoomDetailRouteArgs{key: $key, roomId: $roomId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! RoomDetailRouteArgs) return false;
    return key == other.key && roomId == other.roomId;
  }

  @override
  int get hashCode => key.hashCode ^ roomId.hashCode;
}

/// generated route for
<<<<<<< HEAD
/// [_i44.RoomPage]
class RoomRoute extends _i48.PageRouteInfo<void> {
  const RoomRoute({List<_i48.PageRouteInfo>? children})
=======
/// [_i47.RoomPage]
class RoomRoute extends _i51.PageRouteInfo<void> {
  const RoomRoute({List<_i51.PageRouteInfo>? children})
>>>>>>> feat/dp-payment
    : super(RoomRoute.name, initialChildren: children);

  static const String name = 'RoomRoute';

<<<<<<< HEAD
  static _i48.PageInfo page = _i48.PageInfo(
    name,
    builder: (data) {
      return const _i44.RoomPage();
=======
  static _i51.PageInfo page = _i51.PageInfo(
    name,
    builder: (data) {
      return const _i47.RoomPage();
>>>>>>> feat/dp-payment
    },
  );
}

/// generated route for
<<<<<<< HEAD
/// [_i45.RoomSchedulePage]
class RoomScheduleRoute extends _i48.PageRouteInfo<void> {
  const RoomScheduleRoute({List<_i48.PageRouteInfo>? children})
=======
/// [_i48.RoomSchedulePage]
class RoomScheduleRoute extends _i51.PageRouteInfo<void> {
  const RoomScheduleRoute({List<_i51.PageRouteInfo>? children})
>>>>>>> feat/dp-payment
    : super(RoomScheduleRoute.name, initialChildren: children);

  static const String name = 'RoomScheduleRoute';

<<<<<<< HEAD
  static _i48.PageInfo page = _i48.PageInfo(
    name,
    builder: (data) {
      return const _i45.RoomSchedulePage();
=======
  static _i51.PageInfo page = _i51.PageInfo(
    name,
    builder: (data) {
      return const _i48.RoomSchedulePage();
>>>>>>> feat/dp-payment
    },
  );
}

/// generated route for
<<<<<<< HEAD
/// [_i46.SettingPage]
class SettingRoute extends _i48.PageRouteInfo<void> {
  const SettingRoute({List<_i48.PageRouteInfo>? children})
=======
/// [_i49.SettingPage]
class SettingRoute extends _i51.PageRouteInfo<void> {
  const SettingRoute({List<_i51.PageRouteInfo>? children})
>>>>>>> feat/dp-payment
    : super(SettingRoute.name, initialChildren: children);

  static const String name = 'SettingRoute';

<<<<<<< HEAD
  static _i48.PageInfo page = _i48.PageInfo(
    name,
    builder: (data) {
      return const _i46.SettingPage();
=======
  static _i51.PageInfo page = _i51.PageInfo(
    name,
    builder: (data) {
      return const _i49.SettingPage();
>>>>>>> feat/dp-payment
    },
  );
}

/// generated route for
<<<<<<< HEAD
/// [_i47.UserManagementPage]
class UserManagementRoute extends _i48.PageRouteInfo<void> {
  const UserManagementRoute({List<_i48.PageRouteInfo>? children})
=======
/// [_i50.UserManagementPage]
class UserManagementRoute extends _i51.PageRouteInfo<void> {
  const UserManagementRoute({List<_i51.PageRouteInfo>? children})
>>>>>>> feat/dp-payment
    : super(UserManagementRoute.name, initialChildren: children);

  static const String name = 'UserManagementRoute';

<<<<<<< HEAD
  static _i48.PageInfo page = _i48.PageInfo(
    name,
    builder: (data) {
      return const _i47.UserManagementPage();
=======
  static _i51.PageInfo page = _i51.PageInfo(
    name,
    builder: (data) {
      return const _i50.UserManagementPage();
>>>>>>> feat/dp-payment
    },
  );
}
