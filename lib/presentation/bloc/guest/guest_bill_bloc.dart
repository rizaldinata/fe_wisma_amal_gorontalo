import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/domain/entity/guest/guest_bill_entity.dart';
import 'package:frontend/domain/usecase/guest/get_admin_guest_bills_usecase.dart';
import 'package:frontend/domain/usecase/guest/verify_guest_bill_usecase.dart';

// ─── Events ───────────────────────────────────────────────────────────────────

abstract class GuestBillEvent {}

class FetchAdminGuestBills extends GuestBillEvent {
  final int page;
  final int perPage;
  final String? search;

  FetchAdminGuestBills({this.page = 1, this.perPage = 10, this.search});
}

class VerifyAdminGuestBill extends GuestBillEvent {
  final int billId;
  final bool isApproved;
  final String? adminNotes;

  VerifyAdminGuestBill({
    required this.billId,
    required this.isApproved,
    this.adminNotes,
  });
}

// ─── States ───────────────────────────────────────────────────────────────────

abstract class GuestBillState {}

class GuestBillInitial extends GuestBillState {}

class GuestBillLoading extends GuestBillState {}

class GuestBillLoaded extends GuestBillState {
  final AdminGuestBillResponse data;
  GuestBillLoaded(this.data);
}

class GuestBillError extends GuestBillState {
  final String message;
  GuestBillError(this.message);
}

class GuestBillVerifySuccess extends GuestBillState {
  final String message;
  GuestBillVerifySuccess(this.message);
}

class GuestBillVerifyError extends GuestBillState {
  final String message;
  GuestBillVerifyError(this.message);
}

// ─── BLoC ─────────────────────────────────────────────────────────────────────

class GuestBillBloc extends Bloc<GuestBillEvent, GuestBillState> {
  final GetAdminGuestBillsUseCase getAdminGuestBillsUseCase;
  final VerifyGuestBillUseCase verifyGuestBillUseCase;

  GuestBillBloc({
    required this.getAdminGuestBillsUseCase,
    required this.verifyGuestBillUseCase,
  }) : super(GuestBillInitial()) {
    on<FetchAdminGuestBills>(_onFetch);
    on<VerifyAdminGuestBill>(_onVerify);
  }

  Future<void> _onFetch(
      FetchAdminGuestBills event, Emitter<GuestBillState> emit) async {
    emit(GuestBillLoading());
    try {
      final data = await getAdminGuestBillsUseCase(
        page: event.page,
        perPage: event.perPage,
        search: event.search,
      );
      emit(GuestBillLoaded(data));
    } catch (e) {
      emit(GuestBillError(e.toString()));
    }
  }

  Future<void> _onVerify(
      VerifyAdminGuestBill event, Emitter<GuestBillState> emit) async {
    try {
      await verifyGuestBillUseCase(
        billId: event.billId,
        isApproved: event.isApproved,
        adminNotes: event.adminNotes,
      );
      final msg = event.isApproved
          ? 'Pembayaran berhasil diverifikasi.'
          : 'Pembayaran ditolak.';
      emit(GuestBillVerifySuccess(msg));
    } catch (e) {
      emit(GuestBillVerifyError(e.toString()));
    }
  }
}
