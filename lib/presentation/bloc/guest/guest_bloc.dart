import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/domain/entity/guest/guest_entity.dart';
import 'package:frontend/domain/usecase/guest/get_admin_guests_usecase.dart';

// --- EVENTS ---
abstract class GuestEvent {}

class FetchAdminGuests extends GuestEvent {
  final int page;
  final int perPage;
  final String? search;

  FetchAdminGuests({this.page = 1, this.perPage = 10, this.search});
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

// --- BLOC ---
class GuestBloc extends Bloc<GuestEvent, GuestState> {
  final GetAdminGuestsUseCase getAdminGuestsUseCase;

  GuestBloc({required this.getAdminGuestsUseCase}) : super(GuestInitial()) {
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
  }
}
