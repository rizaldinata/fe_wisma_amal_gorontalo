// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i55;
import 'package:collection/collection.dart' as _i57;
import 'package:flutter/material.dart' as _i56;
import 'package:frontend/domain/entity/inventory_entity.dart' as _i58;
import 'package:frontend/domain/entity/reservation_entity.dart' as _i62;
import 'package:frontend/domain/entity/room_entity.dart' as _i60;
import 'package:frontend/domain/entity/schedule_entity.dart' as _i61;
import 'package:frontend/presentation/bloc/member_finance/member_finance_bloc.dart'
    as _i59;
import 'package:frontend/presentation/pages/auth/login_page.dart' as _i24;
import 'package:frontend/presentation/pages/auth/register_page.dart' as _i44;
import 'package:frontend/presentation/pages/dashboard/dashboard.dart' as _i6;
import 'package:frontend/presentation/pages/detail_room/room_detail.dart'
    as _i50;
import 'package:frontend/presentation/pages/finance/expense_list_page.dart'
    as _i8;
import 'package:frontend/presentation/pages/finance/finance_dashboard_page.dart'
    as _i12;
import 'package:frontend/presentation/pages/finance/fine_management_page.dart'
    as _i14;
import 'package:frontend/presentation/pages/finance/invoice_list_page.dart'
    as _i20;
import 'package:frontend/presentation/pages/finance/payment_verification_page.dart'
    as _i38;
import 'package:frontend/presentation/pages/finance/refund_request_page.dart'
    as _i43;
import 'package:frontend/presentation/pages/identity_form/identity_form_page.dart'
    as _i17;
import 'package:frontend/presentation/pages/inventory/inventory_form_page.dart'
    as _i18;
import 'package:frontend/presentation/pages/inventory/inventory_page.dart'
    as _i19;
import 'package:frontend/presentation/pages/landing_page/landing_page.dart'
    as _i23;
import 'package:frontend/presentation/pages/maintanance/maintanance_detail_page.dart'
    as _i25;
import 'package:frontend/presentation/pages/maintanance/maintanance_form_page.dart'
    as _i26;
import 'package:frontend/presentation/pages/maintanance/maintanance_page.dart'
    as _i27;
import 'package:frontend/presentation/pages/maintenance_report/maintenance_create_report_page.dart'
    as _i28;
import 'package:frontend/presentation/pages/maintenance_report/maintenance_report_detail_page.dart'
    as _i29;
import 'package:frontend/presentation/pages/maintenance_report/maintenance_report_list_page.dart'
    as _i30;
import 'package:frontend/presentation/pages/member_finance/extend_lease_page.dart'
    as _i9;
import 'package:frontend/presentation/pages/member_finance/extend_lease_payment_page.dart'
    as _i10;
import 'package:frontend/presentation/pages/member_finance/invoice_payment_page.dart'
    as _i21;
import 'package:frontend/presentation/pages/member_finance/member_finance_page.dart'
    as _i31;
import 'package:frontend/presentation/pages/member_finance/my_fines_page.dart'
    as _i33;
import 'package:frontend/presentation/pages/midtrans_payment/midtrans_payment_page.dart'
    as _i32;
import 'package:frontend/presentation/pages/notification/notification_monitoring_page.dart'
    as _i36;
import 'package:frontend/presentation/pages/payment_upload/payment_upload_page.dart'
    as _i37;
import 'package:frontend/presentation/pages/permission/permission_detail_page.dart'
    as _i39;
import 'package:frontend/presentation/pages/permission/permission_page.dart'
    as _i40;
import 'package:frontend/presentation/pages/placeholder/placeholder_page.dart'
    as _i13;
import 'package:frontend/presentation/pages/profile/change_password_page.dart'
    as _i4;
import 'package:frontend/presentation/pages/profile/edit_profile_page.dart'
    as _i7;
import 'package:frontend/presentation/pages/profile/profile_page.dart' as _i41;
import 'package:frontend/presentation/pages/reservation_detail_form/reservation_detail_form_page.dart'
    as _i45;
import 'package:frontend/presentation/pages/reservation_list/reservation_page.dart'
    as _i46;
import 'package:frontend/presentation/pages/resident/admin_guest_bill_page.dart'
    as _i2;
import 'package:frontend/presentation/pages/resident/complete_profile_page.dart'
    as _i5;
import 'package:frontend/presentation/pages/resident/guest_bill_payment_page.dart'
    as _i15;
import 'package:frontend/presentation/pages/resident/guest_list_page.dart'
    as _i16;
import 'package:frontend/presentation/pages/resident/my_guest_page.dart'
    as _i34;
import 'package:frontend/presentation/pages/resident/profile_user_page.dart'
    as _i42;
import 'package:frontend/presentation/pages/resident/resident_page.dart'
    as _i48;
import 'package:frontend/presentation/pages/resident_dashboard/resident_dashboard_page.dart'
    as _i47;
import 'package:frontend/presentation/pages/resident_portal/my_reservation/my_reservation_page.dart'
    as _i35;
import 'package:frontend/presentation/pages/role_management/role_management_page.dart'
    as _i49;
import 'package:frontend/presentation/pages/room_form/form_room.dart' as _i1;
import 'package:frontend/presentation/pages/room_list/room_page.dart' as _i51;
import 'package:frontend/presentation/pages/room_schedule/room_schedule_page.dart'
    as _i52;
import 'package:frontend/presentation/pages/setting/feature_toggle_page.dart'
    as _i11;
import 'package:frontend/presentation/pages/setting/landing_cms/landing_cms_page.dart'
    as _i22;
import 'package:frontend/presentation/pages/setting/setting_page.dart' as _i53;
import 'package:frontend/presentation/pages/user_management/user_management_page.dart'
    as _i54;
    as _i53;
import 'package:frontend/presentation/pages/finance/refund_request_page.dart'
    as _i62;
import 'package:frontend/presentation/widget/app_layout.dart' as _i3;

/// generated route for
/// [_i1.AddRoomPage]
class AddRoomRoute extends _i55.PageRouteInfo<void> {
  const AddRoomRoute({List<_i55.PageRouteInfo>? children})
    : super(AddRoomRoute.name, initialChildren: children);

  static const String name = 'AddRoomRoute';

  static _i55.PageInfo page = _i55.PageInfo(
    name,
    builder: (data) {
      return const _i1.AddRoomPage();
    },
  );
}

/// generated route for
/// [_i2.AdminGuestBillPage]
class AdminGuestBillRoute extends _i55.PageRouteInfo<void> {
  const AdminGuestBillRoute({List<_i55.PageRouteInfo>? children})
    : super(AdminGuestBillRoute.name, initialChildren: children);

  static const String name = 'AdminGuestBillRoute';

  static _i55.PageInfo page = _i55.PageInfo(
    name,
    builder: (data) {
      return const _i2.AdminGuestBillPage();
    },
  );
}

/// generated route for
/// [_i3.AppLayoutPage]
class AppLayoutRoute extends _i55.PageRouteInfo<void> {
  const AppLayoutRoute({List<_i55.PageRouteInfo>? children})
    : super(AppLayoutRoute.name, initialChildren: children);

  static const String name = 'AppLayoutRoute';

  static _i55.PageInfo page = _i55.PageInfo(
    name,
    builder: (data) {
      return const _i3.AppLayoutPage();
    },
  );
}

/// generated route for
/// [_i4.ChangePasswordPage]
class ChangePasswordRoute extends _i55.PageRouteInfo<void> {
  const ChangePasswordRoute({List<_i55.PageRouteInfo>? children})
    : super(ChangePasswordRoute.name, initialChildren: children);

  static const String name = 'ChangePasswordRoute';

  static _i55.PageInfo page = _i55.PageInfo(
    name,
    builder: (data) {
      return const _i4.ChangePasswordPage();
    },
  );
}

/// generated route for
/// [_i5.CompleteProfilePage]
class CompleteProfileRoute extends _i55.PageRouteInfo<void> {
  const CompleteProfileRoute({List<_i55.PageRouteInfo>? children})
    : super(CompleteProfileRoute.name, initialChildren: children);

  static const String name = 'CompleteProfileRoute';

  static _i55.PageInfo page = _i55.PageInfo(
    name,
    builder: (data) {
      return const _i5.CompleteProfilePage();
    },
  );
}

/// generated route for
/// [_i6.DashboardPage]
class DashboardRoute extends _i55.PageRouteInfo<void> {
  const DashboardRoute({List<_i55.PageRouteInfo>? children})
    : super(DashboardRoute.name, initialChildren: children);

  static const String name = 'DashboardRoute';

  static _i55.PageInfo page = _i55.PageInfo(
    name,
    builder: (data) {
      return const _i6.DashboardPage();
    },
  );
}

/// generated route for
/// [_i7.EditProfilePage]
class EditProfileRoute extends _i55.PageRouteInfo<void> {
  const EditProfileRoute({List<_i55.PageRouteInfo>? children})
    : super(EditProfileRoute.name, initialChildren: children);

  static const String name = 'EditProfileRoute';

  static _i55.PageInfo page = _i55.PageInfo(
    name,
    builder: (data) {
      return const _i7.EditProfilePage();
    },
  );
}

/// generated route for
/// [_i1.EditRoomPage]
class EditRoomRoute extends _i55.PageRouteInfo<EditRoomRouteArgs> {
  EditRoomRoute({
    _i56.Key? key,
    required int roomId,
    List<_i55.PageRouteInfo>? children,
  }) : super(
         EditRoomRoute.name,
         args: EditRoomRouteArgs(key: key, roomId: roomId),
         rawPathParams: {'id': roomId},
         initialChildren: children,
       );

  static const String name = 'EditRoomRoute';

  static _i55.PageInfo page = _i55.PageInfo(
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

  final _i56.Key? key;

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
class ExpenseListRoute extends _i55.PageRouteInfo<void> {
  const ExpenseListRoute({List<_i55.PageRouteInfo>? children})
    : super(ExpenseListRoute.name, initialChildren: children);

  static const String name = 'ExpenseListRoute';

  static _i55.PageInfo page = _i55.PageInfo(
    name,
    builder: (data) {
      return const _i8.ExpenseListPage();
    },
  );
}

/// generated route for
/// [_i9.ExtendLeasePage]
class ExtendLeaseRoute extends _i55.PageRouteInfo<ExtendLeaseRouteArgs> {
  ExtendLeaseRoute({
    _i56.Key? key,
    required int leaseId,
    required String roomNumber,
    required DateTime currentEndDate,
    required bool isMidtransEnabled,
    List<_i55.PageRouteInfo>? children,
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

  static _i55.PageInfo page = _i55.PageInfo(
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

  final _i56.Key? key;

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
    extends _i55.PageRouteInfo<ExtendLeasePaymentRouteArgs> {
  ExtendLeasePaymentRoute({
    _i56.Key? key,
    required int invoiceId,
    required String roomNumber,
    required double amount,
    double? baseAmount,
    int midtransFee = 0,
    String? feeBearer,
    String? snapToken,
    Map<String, dynamic>? paymentData,
    String? pageTitle,
    List<_i55.PageRouteInfo>? children,
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

  static _i55.PageInfo page = _i55.PageInfo(
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

  final _i56.Key? key;

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
        const _i57.MapEquality<String, dynamic>().equals(
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
      const _i57.MapEquality<String, dynamic>().hash(paymentData) ^
      pageTitle.hashCode;
}

/// generated route for
/// [_i11.FeatureTogglePage]
class FeatureToggleRoute extends _i55.PageRouteInfo<void> {
  const FeatureToggleRoute({List<_i55.PageRouteInfo>? children})
    : super(FeatureToggleRoute.name, initialChildren: children);

  static const String name = 'FeatureToggleRoute';

  static _i55.PageInfo page = _i55.PageInfo(
    name,
    builder: (data) {
      return const _i11.FeatureTogglePage();
    },
  );
}

/// generated route for
/// [_i12.FinanceDashboardPage]
class FinanceDashboardRoute extends _i55.PageRouteInfo<void> {
  const FinanceDashboardRoute({List<_i55.PageRouteInfo>? children})
    : super(FinanceDashboardRoute.name, initialChildren: children);

  static const String name = 'FinanceDashboardRoute';

  static _i55.PageInfo page = _i55.PageInfo(
    name,
    builder: (data) {
      return const _i12.FinanceDashboardPage();
    },
  );
}

/// generated route for
/// [_i13.FinancePlaceholderPage]
class FinancePlaceholderRoute extends _i55.PageRouteInfo<void> {
  const FinancePlaceholderRoute({List<_i55.PageRouteInfo>? children})
    : super(FinancePlaceholderRoute.name, initialChildren: children);

  static const String name = 'FinancePlaceholderRoute';

  static _i55.PageInfo page = _i55.PageInfo(
    name,
    builder: (data) {
      return const _i13.FinancePlaceholderPage();
    },
  );
}

/// generated route for
/// [_i14.FineManagementPage]
class FineManagementRoute extends _i55.PageRouteInfo<void> {
  const FineManagementRoute({List<_i55.PageRouteInfo>? children})
    : super(FineManagementRoute.name, initialChildren: children);

  static const String name = 'FineManagementRoute';

  static _i55.PageInfo page = _i55.PageInfo(
    name,
    builder: (data) {
      return const _i14.FineManagementPage();
    },
  );
}

/// generated route for
/// [_i15.GuestBillPaymentPage]
class GuestBillPaymentRoute
    extends _i55.PageRouteInfo<GuestBillPaymentRouteArgs> {
  GuestBillPaymentRoute({
    _i56.Key? key,
    required int guestId,
    required String guestName,
    required double amount,
    String? billNumber,
    List<_i55.PageRouteInfo>? children,
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

  static _i55.PageInfo page = _i55.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<GuestBillPaymentRouteArgs>();
      return _i15.GuestBillPaymentPage(
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

  final _i56.Key? key;

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
/// [_i16.GuestListPage]
class GuestListRoute extends _i55.PageRouteInfo<void> {
  const GuestListRoute({List<_i55.PageRouteInfo>? children})
    : super(GuestListRoute.name, initialChildren: children);

  static const String name = 'GuestListRoute';

  static _i55.PageInfo page = _i55.PageInfo(
    name,
    builder: (data) {
      return const _i16.GuestListPage();
    },
  );
}

/// generated route for
/// [_i17.IdentityFormPage]
class IdentityFormRoute extends _i55.PageRouteInfo<void> {
  const IdentityFormRoute({List<_i55.PageRouteInfo>? children})
    : super(IdentityFormRoute.name, initialChildren: children);

  static const String name = 'IdentityFormRoute';

  static _i55.PageInfo page = _i55.PageInfo(
    name,
    builder: (data) {
      return const _i17.IdentityFormPage();
    },
  );
}

/// generated route for
/// [_i13.InventoryAndMaintenancePlaceholderPage]
class InventoryAndMaintenancePlaceholderRoute extends _i55.PageRouteInfo<void> {
  const InventoryAndMaintenancePlaceholderRoute({
    List<_i55.PageRouteInfo>? children,
  }) : super(
         InventoryAndMaintenancePlaceholderRoute.name,
         initialChildren: children,
       );

  static const String name = 'InventoryAndMaintenancePlaceholderRoute';

  static _i55.PageInfo page = _i55.PageInfo(
    name,
    builder: (data) {
      return const _i13.InventoryAndMaintenancePlaceholderPage();
    },
  );
}

/// generated route for
/// [_i18.InventoryFormPage]
class InventoryFormRoute extends _i55.PageRouteInfo<InventoryFormRouteArgs> {
  InventoryFormRoute({
    _i56.Key? key,
    _i58.InventoryEntity? inventoryData,
    List<_i55.PageRouteInfo>? children,
  }) : super(
         InventoryFormRoute.name,
         args: InventoryFormRouteArgs(key: key, inventoryData: inventoryData),
         initialChildren: children,
       );

  static const String name = 'InventoryFormRoute';

  static _i55.PageInfo page = _i55.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<InventoryFormRouteArgs>(
        orElse: () => const InventoryFormRouteArgs(),
      );
      return _i18.InventoryFormPage(
        key: args.key,
        inventoryData: args.inventoryData,
      );
    },
  );
}

class InventoryFormRouteArgs {
  const InventoryFormRouteArgs({this.key, this.inventoryData});

  final _i56.Key? key;

  final _i58.InventoryEntity? inventoryData;

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
/// [_i19.InventoryPage]
class InventoryRoute extends _i55.PageRouteInfo<void> {
  const InventoryRoute({List<_i55.PageRouteInfo>? children})
    : super(InventoryRoute.name, initialChildren: children);

  static const String name = 'InventoryRoute';

  static _i55.PageInfo page = _i55.PageInfo(
    name,
    builder: (data) {
      return const _i19.InventoryPage();
    },
  );
}

/// generated route for
/// [_i20.InvoiceListPage]
class InvoiceListRoute extends _i55.PageRouteInfo<void> {
  const InvoiceListRoute({List<_i55.PageRouteInfo>? children})
    : super(InvoiceListRoute.name, initialChildren: children);

  static const String name = 'InvoiceListRoute';

  static _i55.PageInfo page = _i55.PageInfo(
    name,
    builder: (data) {
      return const _i20.InvoiceListPage();
    },
  );
}

/// generated route for
/// [_i21.InvoicePaymentPage]
class InvoicePaymentRoute extends _i55.PageRouteInfo<InvoicePaymentRouteArgs> {
  InvoicePaymentRoute({
    _i56.Key? key,
    required int invoiceId,
    required String invoiceNumber,
    required double amount,
    String? roomNumber,
    String? invoiceType,
    DateTime? dueDate,
    _i59.MemberFinanceBloc? bloc,
    List<_i55.PageRouteInfo>? children,
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

  static _i55.PageInfo page = _i55.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<InvoicePaymentRouteArgs>();
      return _i21.InvoicePaymentPage(
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

  final _i56.Key? key;

  final int invoiceId;

  final String invoiceNumber;

  final double amount;

  final String? roomNumber;

  final String? invoiceType;

  final DateTime? dueDate;

  final _i59.MemberFinanceBloc? bloc;

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
/// [_i22.LandingCmsPage]
class LandingCmsRoute extends _i55.PageRouteInfo<void> {
  const LandingCmsRoute({List<_i55.PageRouteInfo>? children})
    : super(LandingCmsRoute.name, initialChildren: children);

  static const String name = 'LandingCmsRoute';

  static _i55.PageInfo page = _i55.PageInfo(
    name,
    builder: (data) {
      return const _i22.LandingCmsPage();
    },
  );
}

/// generated route for
/// [_i23.LandingPage]
class LandingRoute extends _i55.PageRouteInfo<void> {
  const LandingRoute({List<_i55.PageRouteInfo>? children})
    : super(LandingRoute.name, initialChildren: children);

  static const String name = 'LandingRoute';

  static _i55.PageInfo page = _i55.PageInfo(
    name,
    builder: (data) {
      return const _i23.LandingPage();
    },
  );
}

/// generated route for
/// [_i24.LoginPage]
class LoginRoute extends _i55.PageRouteInfo<LoginRouteArgs> {
  LoginRoute({
    _i56.Key? key,
    String? reason,
    _i60.RoomEntity? pendingRoom,
    List<_i55.PageRouteInfo>? children,
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

  static _i55.PageInfo page = _i55.PageInfo(
    name,
    builder: (data) {
      final queryParams = data.queryParams;
      final args = data.argsAs<LoginRouteArgs>(
        orElse: () => LoginRouteArgs(reason: queryParams.optString('reason')),
      );
      return _i24.LoginPage(
        key: args.key,
        reason: args.reason,
        pendingRoom: args.pendingRoom,
      );
    },
  );
}

class LoginRouteArgs {
  const LoginRouteArgs({this.key, this.reason, this.pendingRoom});

  final _i56.Key? key;

  final String? reason;

  final _i60.RoomEntity? pendingRoom;

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
/// [_i25.MaintananceDetailPage]
class MaintananceDetailRoute
    extends _i55.PageRouteInfo<MaintananceDetailRouteArgs> {
  MaintananceDetailRoute({
    _i56.Key? key,
    required _i61.ScheduleEntity schedule,
    List<_i55.PageRouteInfo>? children,
  }) : super(
         MaintananceDetailRoute.name,
         args: MaintananceDetailRouteArgs(key: key, schedule: schedule),
         initialChildren: children,
       );

  static const String name = 'MaintananceDetailRoute';

  static _i55.PageInfo page = _i55.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<MaintananceDetailRouteArgs>();
      return _i25.MaintananceDetailPage(key: args.key, schedule: args.schedule);
    },
  );
}

class MaintananceDetailRouteArgs {
  const MaintananceDetailRouteArgs({this.key, required this.schedule});

  final _i56.Key? key;

  final _i61.ScheduleEntity schedule;

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
/// [_i26.MaintananceFormPage]
class MaintananceFormRoute
    extends _i55.PageRouteInfo<MaintananceFormRouteArgs> {
  MaintananceFormRoute({
    _i56.Key? key,
    _i61.ScheduleEntity? scheduleData,
    List<_i55.PageRouteInfo>? children,
  }) : super(
         MaintananceFormRoute.name,
         args: MaintananceFormRouteArgs(key: key, scheduleData: scheduleData),
         initialChildren: children,
       );

  static const String name = 'MaintananceFormRoute';

  static _i55.PageInfo page = _i55.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<MaintananceFormRouteArgs>(
        orElse: () => const MaintananceFormRouteArgs(),
      );
      return _i26.MaintananceFormPage(
        key: args.key,
        scheduleData: args.scheduleData,
      );
    },
  );
}

class MaintananceFormRouteArgs {
  const MaintananceFormRouteArgs({this.key, this.scheduleData});

  final _i56.Key? key;

  final _i61.ScheduleEntity? scheduleData;

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
/// [_i27.MaintanancePage]
class MaintananceRoute extends _i55.PageRouteInfo<void> {
  const MaintananceRoute({List<_i55.PageRouteInfo>? children})
    : super(MaintananceRoute.name, initialChildren: children);

  static const String name = 'MaintananceRoute';

  static _i55.PageInfo page = _i55.PageInfo(
    name,
    builder: (data) {
      return const _i27.MaintanancePage();
    },
  );
}

/// generated route for
/// [_i28.MaintenanceCreateReportPage]
class MaintenanceCreateReportRoute extends _i55.PageRouteInfo<void> {
  const MaintenanceCreateReportRoute({List<_i55.PageRouteInfo>? children})
    : super(MaintenanceCreateReportRoute.name, initialChildren: children);

  static const String name = 'MaintenanceCreateReportRoute';

  static _i55.PageInfo page = _i55.PageInfo(
    name,
    builder: (data) {
      return const _i28.MaintenanceCreateReportPage();
    },
  );
}

/// generated route for
/// [_i29.MaintenanceReportDetailPage]
class MaintenanceReportDetailRoute
    extends _i55.PageRouteInfo<MaintenanceReportDetailRouteArgs> {
  MaintenanceReportDetailRoute({
    _i56.Key? key,
    required int id,
    List<_i55.PageRouteInfo>? children,
  }) : super(
         MaintenanceReportDetailRoute.name,
         args: MaintenanceReportDetailRouteArgs(key: key, id: id),
         rawPathParams: {'id': id},
         initialChildren: children,
       );

  static const String name = 'MaintenanceReportDetailRoute';

  static _i55.PageInfo page = _i55.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<MaintenanceReportDetailRouteArgs>(
        orElse: () =>
            MaintenanceReportDetailRouteArgs(id: pathParams.getInt('id')),
      );
      return _i29.MaintenanceReportDetailPage(key: args.key, id: args.id);
    },
  );
}

class MaintenanceReportDetailRouteArgs {
  const MaintenanceReportDetailRouteArgs({this.key, required this.id});

  final _i56.Key? key;

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
/// [_i30.MaintenanceReportListPage]
class MaintenanceReportListRoute extends _i55.PageRouteInfo<void> {
  const MaintenanceReportListRoute({List<_i55.PageRouteInfo>? children})
    : super(MaintenanceReportListRoute.name, initialChildren: children);

  static const String name = 'MaintenanceReportListRoute';

  static _i55.PageInfo page = _i55.PageInfo(
    name,
    builder: (data) {
      return const _i30.MaintenanceReportListPage();
    },
  );
}

/// generated route for
/// [_i31.MemberFinancePage]
class MemberFinanceRoute extends _i55.PageRouteInfo<void> {
  const MemberFinanceRoute({List<_i55.PageRouteInfo>? children})
    : super(MemberFinanceRoute.name, initialChildren: children);

  static const String name = 'MemberFinanceRoute';

  static _i55.PageInfo page = _i55.PageInfo(
    name,
    builder: (data) {
      return const _i31.MemberFinancePage();
    },
  );
}

/// generated route for
/// [_i32.MidtransPaymentPage]
class MidtransPaymentRoute
    extends _i55.PageRouteInfo<MidtransPaymentRouteArgs> {
  MidtransPaymentRoute({
    _i56.Key? key,
    required _i62.ReservationEntity reservation,
    List<_i55.PageRouteInfo>? children,
  }) : super(
         MidtransPaymentRoute.name,
         args: MidtransPaymentRouteArgs(key: key, reservation: reservation),
         initialChildren: children,
       );

  static const String name = 'MidtransPaymentRoute';

  static _i55.PageInfo page = _i55.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<MidtransPaymentRouteArgs>();
      return _i32.MidtransPaymentPage(
        key: args.key,
        reservation: args.reservation,
      );
    },
  );
}

class MidtransPaymentRouteArgs {
  const MidtransPaymentRouteArgs({this.key, required this.reservation});

  final _i56.Key? key;

  final _i62.ReservationEntity reservation;

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
/// [_i33.MyFinesPage]
class MyFinesRoute extends _i55.PageRouteInfo<void> {
  const MyFinesRoute({List<_i55.PageRouteInfo>? children})
    : super(MyFinesRoute.name, initialChildren: children);

  static const String name = 'MyFinesRoute';

  static _i55.PageInfo page = _i55.PageInfo(
    name,
    builder: (data) {
      return const _i33.MyFinesPage();
    },
  );
}

/// generated route for
/// [_i34.MyGuestPage]
class MyGuestRoute extends _i55.PageRouteInfo<void> {
  const MyGuestRoute({List<_i55.PageRouteInfo>? children})
    : super(MyGuestRoute.name, initialChildren: children);

  static const String name = 'MyGuestRoute';

  static _i55.PageInfo page = _i55.PageInfo(
    name,
    builder: (data) {
      return const _i34.MyGuestPage();
    },
  );
}

/// generated route for
/// [_i35.MyReservationPage]
class MyReservationRoute extends _i55.PageRouteInfo<void> {
  const MyReservationRoute({List<_i55.PageRouteInfo>? children})
    : super(MyReservationRoute.name, initialChildren: children);

  static const String name = 'MyReservationRoute';

  static _i55.PageInfo page = _i55.PageInfo(
    name,
    builder: (data) {
      return const _i35.MyReservationPage();
    },
  );
}

/// generated route for
/// [_i36.NotificationMonitoringPage]
class NotificationMonitoringRoute extends _i55.PageRouteInfo<void> {
  const NotificationMonitoringRoute({List<_i55.PageRouteInfo>? children})
    : super(NotificationMonitoringRoute.name, initialChildren: children);

  static const String name = 'NotificationMonitoringRoute';

  static _i55.PageInfo page = _i55.PageInfo(
    name,
    builder: (data) {
      return const _i36.NotificationMonitoringPage();
    },
  );
}

/// generated route for
/// [_i37.PaymentUploadPage]
class PaymentUploadRoute extends _i55.PageRouteInfo<PaymentUploadRouteArgs> {
  PaymentUploadRoute({
    _i56.Key? key,
    required _i62.ReservationEntity reservation,
    List<_i55.PageRouteInfo>? children,
  }) : super(
         PaymentUploadRoute.name,
         args: PaymentUploadRouteArgs(key: key, reservation: reservation),
         initialChildren: children,
       );

  static const String name = 'PaymentUploadRoute';

  static _i55.PageInfo page = _i55.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<PaymentUploadRouteArgs>();
      return _i37.PaymentUploadPage(
        key: args.key,
        reservation: args.reservation,
      );
    },
  );
}

class PaymentUploadRouteArgs {
  const PaymentUploadRouteArgs({this.key, required this.reservation});

  final _i56.Key? key;

  final _i62.ReservationEntity reservation;

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
/// [_i38.PaymentVerificationPage]
class PaymentVerificationRoute extends _i55.PageRouteInfo<void> {
  const PaymentVerificationRoute({List<_i55.PageRouteInfo>? children})
    : super(PaymentVerificationRoute.name, initialChildren: children);

  static const String name = 'PaymentVerificationRoute';

  static _i55.PageInfo page = _i55.PageInfo(
    name,
    builder: (data) {
      return const _i38.PaymentVerificationPage();
    },
  );
}

/// generated route for
/// [_i39.PermissionDetailPage]
class PermissionDetailRoute
    extends _i55.PageRouteInfo<PermissionDetailRouteArgs> {
  PermissionDetailRoute({
    _i56.Key? key,
    required int id,
    List<_i55.PageRouteInfo>? children,
  }) : super(
         PermissionDetailRoute.name,
         args: PermissionDetailRouteArgs(key: key, id: id),
         rawPathParams: {'id': id},
         initialChildren: children,
       );

  static const String name = 'PermissionDetailRoute';

  static _i55.PageInfo page = _i55.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<PermissionDetailRouteArgs>(
        orElse: () => PermissionDetailRouteArgs(id: pathParams.getInt('id')),
      );
      return _i39.PermissionDetailPage(key: args.key, id: args.id);
    },
  );
}

class PermissionDetailRouteArgs {
  const PermissionDetailRouteArgs({this.key, required this.id});

  final _i56.Key? key;

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
/// [_i40.PermissionPage]
class PermissionRoute extends _i55.PageRouteInfo<void> {
  const PermissionRoute({List<_i55.PageRouteInfo>? children})
    : super(PermissionRoute.name, initialChildren: children);

  static const String name = 'PermissionRoute';

  static _i55.PageInfo page = _i55.PageInfo(
    name,
    builder: (data) {
      return const _i40.PermissionPage();
    },
  );
}

/// generated route for
/// [_i13.PermissionPlaceholderPage]
class PermissionPlaceholderRoute extends _i55.PageRouteInfo<void> {
  const PermissionPlaceholderRoute({List<_i55.PageRouteInfo>? children})
    : super(PermissionPlaceholderRoute.name, initialChildren: children);

  static const String name = 'PermissionPlaceholderRoute';

  static _i55.PageInfo page = _i55.PageInfo(
    name,
    builder: (data) {
      return const _i13.PermissionPlaceholderPage();
    },
  );
}

/// generated route for
/// [_i41.ProfilePage]
class ProfileRoute extends _i55.PageRouteInfo<void> {
  const ProfileRoute({List<_i55.PageRouteInfo>? children})
    : super(ProfileRoute.name, initialChildren: children);

  static const String name = 'ProfileRoute';

  static _i55.PageInfo page = _i55.PageInfo(
    name,
    builder: (data) {
      return const _i41.ProfilePage();
    },
  );
}

/// generated route for
/// [_i42.ProfileUserPage]
class ProfileUserRoute extends _i55.PageRouteInfo<void> {
  const ProfileUserRoute({List<_i55.PageRouteInfo>? children})
    : super(ProfileUserRoute.name, initialChildren: children);

  static const String name = 'ProfileUserRoute';

  static _i55.PageInfo page = _i55.PageInfo(
    name,
    builder: (data) {
      return const _i42.ProfileUserPage();
    },
  );
}

/// generated route for
/// [_i43.RefundRequestPage]
class RefundRequestRoute extends _i55.PageRouteInfo<void> {
  const RefundRequestRoute({List<_i55.PageRouteInfo>? children})
    : super(RefundRequestRoute.name, initialChildren: children);

  static const String name = 'RefundRequestRoute';

  static _i55.PageInfo page = _i55.PageInfo(
    name,
    builder: (data) {
      return const _i43.RefundRequestPage();
    },
  );
}

/// generated route for
/// [_i44.RegisterPage]
class RegisterRoute extends _i55.PageRouteInfo<RegisterRouteArgs> {
  RegisterRoute({
    _i56.Key? key,
    _i60.RoomEntity? pendingRoom,
    List<_i55.PageRouteInfo>? children,
  }) : super(
         RegisterRoute.name,
         args: RegisterRouteArgs(key: key, pendingRoom: pendingRoom),
         initialChildren: children,
       );

  static const String name = 'RegisterRoute';

  static _i55.PageInfo page = _i55.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<RegisterRouteArgs>(
        orElse: () => const RegisterRouteArgs(),
      );
      return _i44.RegisterPage(key: args.key, pendingRoom: args.pendingRoom);
    },
  );
}

class RegisterRouteArgs {
  const RegisterRouteArgs({this.key, this.pendingRoom});

  final _i56.Key? key;

  final _i60.RoomEntity? pendingRoom;

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
/// [_i45.ReservationDetailFormPage]
class ReservationDetailFormRoute
    extends _i55.PageRouteInfo<ReservationDetailFormRouteArgs> {
  ReservationDetailFormRoute({
    _i56.Key? key,
    required _i60.RoomEntity room,
    List<_i55.PageRouteInfo>? children,
  }) : super(
         ReservationDetailFormRoute.name,
         args: ReservationDetailFormRouteArgs(key: key, room: room),
         initialChildren: children,
       );

  static const String name = 'ReservationDetailFormRoute';

  static _i55.PageInfo page = _i55.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ReservationDetailFormRouteArgs>();
      return _i45.ReservationDetailFormPage(key: args.key, room: args.room);
    },
  );
}

class ReservationDetailFormRouteArgs {
  const ReservationDetailFormRouteArgs({this.key, required this.room});

  final _i56.Key? key;

  final _i60.RoomEntity room;

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
/// [_i46.ReservationPage]
class ReservationRoute extends _i55.PageRouteInfo<void> {
  const ReservationRoute({List<_i55.PageRouteInfo>? children})
    : super(ReservationRoute.name, initialChildren: children);

  static const String name = 'ReservationRoute';

  static _i55.PageInfo page = _i55.PageInfo(
    name,
    builder: (data) {
      return const _i46.ReservationPage();
    },
  );
}

/// generated route for
/// [_i47.ResidentDashboardPage]
class ResidentDashboardRoute extends _i55.PageRouteInfo<void> {
  const ResidentDashboardRoute({List<_i55.PageRouteInfo>? children})
    : super(ResidentDashboardRoute.name, initialChildren: children);

  static const String name = 'ResidentDashboardRoute';

  static _i55.PageInfo page = _i55.PageInfo(
    name,
    builder: (data) {
      return const _i47.ResidentDashboardPage();
    },
  );
}

/// generated route for
/// [_i48.ResidentPage]
class ResidentRoute extends _i55.PageRouteInfo<void> {
  const ResidentRoute({List<_i55.PageRouteInfo>? children})
    : super(ResidentRoute.name, initialChildren: children);

  static const String name = 'ResidentRoute';

  static _i55.PageInfo page = _i55.PageInfo(
    name,
    builder: (data) {
      return const _i48.ResidentPage();
    },
  );
}

/// generated route for
/// [_i13.ResidentPlaceholderPage]
class ResidentPlaceholderRoute extends _i55.PageRouteInfo<void> {
  const ResidentPlaceholderRoute({List<_i55.PageRouteInfo>? children})
    : super(ResidentPlaceholderRoute.name, initialChildren: children);

  static const String name = 'ResidentPlaceholderRoute';

  static _i55.PageInfo page = _i55.PageInfo(
    name,
    builder: (data) {
      return const _i13.ResidentPlaceholderPage();
    },
  );
}

/// generated route for
/// [_i49.RoleManagementPage]
class RoleManagementRoute extends _i55.PageRouteInfo<void> {
  const RoleManagementRoute({List<_i55.PageRouteInfo>? children})
    : super(RoleManagementRoute.name, initialChildren: children);

  static const String name = 'RoleManagementRoute';

  static _i55.PageInfo page = _i55.PageInfo(
    name,
    builder: (data) {
      return const _i49.RoleManagementPage();
    },
  );
}

/// generated route for
/// [_i13.RolePlaceholderPage]
class RolePlaceholderRoute extends _i55.PageRouteInfo<void> {
  const RolePlaceholderRoute({List<_i55.PageRouteInfo>? children})
    : super(RolePlaceholderRoute.name, initialChildren: children);

  static const String name = 'RolePlaceholderRoute';

  static _i55.PageInfo page = _i55.PageInfo(
    name,
    builder: (data) {
      return const _i13.RolePlaceholderPage();
    },
  );
}

/// generated route for
/// [_i13.RoomAndReservationPlaceholderPage]
class RoomAndReservationPlaceholderRoute extends _i55.PageRouteInfo<void> {
  const RoomAndReservationPlaceholderRoute({List<_i55.PageRouteInfo>? children})
    : super(RoomAndReservationPlaceholderRoute.name, initialChildren: children);

  static const String name = 'RoomAndReservationPlaceholderRoute';

  static _i55.PageInfo page = _i55.PageInfo(
    name,
    builder: (data) {
      return const _i13.RoomAndReservationPlaceholderPage();
    },
  );
}

/// generated route for
/// [_i50.RoomDetailPage]
class RoomDetailRoute extends _i55.PageRouteInfo<RoomDetailRouteArgs> {
  RoomDetailRoute({
    _i56.Key? key,
    required int roomId,
    List<_i55.PageRouteInfo>? children,
  }) : super(
         RoomDetailRoute.name,
         args: RoomDetailRouteArgs(key: key, roomId: roomId),
         rawPathParams: {'id': roomId},
         initialChildren: children,
       );

  static const String name = 'RoomDetailRoute';

  static _i55.PageInfo page = _i55.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<RoomDetailRouteArgs>(
        orElse: () => RoomDetailRouteArgs(roomId: pathParams.getInt('id')),
      );
      return _i50.RoomDetailPage(key: args.key, roomId: args.roomId);
    },
  );
}

class RoomDetailRouteArgs {
  const RoomDetailRouteArgs({this.key, required this.roomId});

  final _i56.Key? key;

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
/// [_i51.RoomPage]
class RoomRoute extends _i55.PageRouteInfo<void> {
  const RoomRoute({List<_i55.PageRouteInfo>? children})
    : super(RoomRoute.name, initialChildren: children);

  static const String name = 'RoomRoute';

  static _i55.PageInfo page = _i55.PageInfo(
    name,
    builder: (data) {
      return const _i51.RoomPage();
    },
  );
}

/// generated route for
/// [_i52.RoomSchedulePage]
class RoomScheduleRoute extends _i55.PageRouteInfo<void> {
  const RoomScheduleRoute({List<_i55.PageRouteInfo>? children})
    : super(RoomScheduleRoute.name, initialChildren: children);

  static const String name = 'RoomScheduleRoute';

  static _i55.PageInfo page = _i55.PageInfo(
    name,
    builder: (data) {
      return const _i52.RoomSchedulePage();
    },
  );
}

/// generated route for
/// [_i53.SettingPage]
class SettingRoute extends _i55.PageRouteInfo<void> {
  const SettingRoute({List<_i55.PageRouteInfo>? children})
    : super(SettingRoute.name, initialChildren: children);

  static const String name = 'SettingRoute';

  static _i55.PageInfo page = _i55.PageInfo(
    name,
    builder: (data) {
      return const _i53.SettingPage();
    },
  );
}

/// generated route for
/// [_i54.UserManagementPage]
class UserManagementRoute extends _i55.PageRouteInfo<void> {
  const UserManagementRoute({List<_i55.PageRouteInfo>? children})
    : super(UserManagementRoute.name, initialChildren: children);

  static const String name = 'UserManagementRoute';

  static _i55.PageInfo page = _i55.PageInfo(
    name,
    builder: (data) {
<<<<<<< HEAD
      return const _i54.UserManagementPage();
=======
      return const _i53.UserManagementPage();
    },
  );
}

/// generated route for
/// [_i62.RefundRequestPage]
class RefundRequestRoute extends _i54.PageRouteInfo<void> {
  const RefundRequestRoute({List<_i54.PageRouteInfo>? children})
    : super(RefundRequestRoute.name, initialChildren: children);

  static const String name = 'RefundRequestRoute';

  static _i54.PageInfo page = _i54.PageInfo(
    name,
    builder: (data) {
      return const _i62.RefundRequestPage();
>>>>>>> 9d3eab1 (develop: fix setting finance 3)
    },
  );
}
