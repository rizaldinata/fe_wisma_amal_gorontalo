import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/domain/entity/guest/guest_entity.dart';
import 'package:frontend/domain/usecase/guest/checkout_admin_guest_usecase.dart';
import 'package:frontend/domain/usecase/guest/create_admin_guest_usecase.dart';
import 'package:frontend/domain/usecase/guest/extend_admin_guest_usecase.dart'; // <-- Pastikan class ini dibuat
import 'package:frontend/domain/usecase/guest/get_admin_guests_usecase.dart';

// --- EVENTS ---
abstract class GuestEvent {}

class FetchAdminGuests extends GuestEvent {
  final int page;
  final int perPage;
  final String? search;

  FetchAdminGuests({this.page = 1, this.perPage = 10, this.search});
}

class CreateAdminGuest extends GuestEvent {
  final int scheduleId; // <-- Diganti menjadi scheduleId (dari sebelumnya leaseId)
  final String name;
  final String checkInAt;
  final String checkOutAt;
  final String relationship;

  CreateAdminGuest({
    required this.scheduleId,
    required this.name,
    required this.checkInAt,
    required this.checkOutAt,
    required this.relationship,
  });
}

class CheckoutAdminGuest extends GuestEvent {
  final int id;
  CheckoutAdminGuest(this.id);
}

class ExtendAdminGuest extends GuestEvent {
  final int id;
  final String newCheckOutAt;

  ExtendAdminGuest({required this.id, required this.newCheckOutAt});
}

// --- STATES ---
abstract class GuestState {}

class GuestInitial extends GuestState {}

class GuestLoading extends GuestState {}

class GuestLoaded extends GuestState {
  final GuestResponse data;
  GuestLoaded(this.data);
}

class GuestError extends GuestState {
  final String message;
  GuestError(this.message);
}

class GuestActionSuccess extends GuestState {
  final String message;
  GuestActionSuccess(this.message);
}

class GuestActionError extends GuestState {
  final String message;
  GuestActionError(this.message);
}

// --- BLOC ---
class GuestBloc extends Bloc<GuestEvent, GuestState> {
  final GetAdminGuestsUseCase getAdminGuestsUseCase;
  final CreateAdminGuestUseCase createAdminGuestUseCase;
  final CheckoutAdminGuestUseCase checkoutAdminGuestUseCase;
  final ExtendAdminGuestUseCase extendAdminGuestUseCase; // <-- Use Case Baru

  GuestBloc({
    required this.getAdminGuestsUseCase,
    required this.createAdminGuestUseCase,
    required this.checkoutAdminGuestUseCase,
    required this.extendAdminGuestUseCase,
  }) : super(GuestInitial()) {
    on<FetchAdminGuests>((event, emit) async {
      if (event.page == 1) {
        emit(GuestLoading());
      }
      try {
        final response = await getAdminGuestsUseCase(
          page: event.page,
          perPage: event.perPage,
          search: event.search,
        );
        emit(GuestLoaded(response));
      } catch (e) {
        emit(GuestError(e.toString()));
      }
    });

    on<CreateAdminGuest>((event, emit) async {
      try {
        await createAdminGuestUseCase(
          scheduleId: event.scheduleId,
          name: event.name,
          checkInAt: event.checkInAt,
          checkOutAt: event.checkOutAt,
          relationship: event.relationship,
        );
        emit(GuestActionSuccess('Data tamu berhasil ditambahkan.'));
      } catch (e) {
        emit(GuestActionError(e.toString()));
      }
    });

    on<CheckoutAdminGuest>((event, emit) async {
      try {
        await checkoutAdminGuestUseCase(event.id);
        emit(GuestActionSuccess('Tamu berhasil ditandai keluar.'));
      } catch (e) {
        emit(GuestActionError(e.toString()));
      }
    });

    on<ExtendAdminGuest>((event, emit) async {
      try {
        await extendAdminGuestUseCase(event.id, event.newCheckOutAt);
        emit(GuestActionSuccess('Waktu menginap tamu berhasil diperpanjang.'));
      } catch (e) {
        emit(GuestActionError(e.toString()));
      }
    });
  }
}