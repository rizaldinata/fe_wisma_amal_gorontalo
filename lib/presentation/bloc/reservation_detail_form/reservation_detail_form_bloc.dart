import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:frontend/domain/entity/room_entity.dart';
import 'package:frontend/domain/entity/reservation_entity.dart';
import 'package:frontend/domain/usecase/reservation/create_reservation_usecase.dart';
import 'package:frontend/domain/usecase/setting/get_public_settings_usecase.dart';

part 'reservation_detail_form_event.dart';
part 'reservation_detail_form_state.dart';

class ReservationDetailFormBloc
    extends Bloc<ReservationDetailFormEvent, ReservationDetailFormState> {
  final GetPublicSettingsUseCase getSettingsUseCase;
  final CreateReservationUseCase createReservationUseCase;

  ReservationDetailFormBloc({
    required this.getSettingsUseCase,
    required this.createReservationUseCase,
  }) : super(const ReservationDetailFormState()) {
    on<InitReservationEvent>(_onInit);
    on<RentTypeChanged>(_onRentTypeChanged);
    on<StartDateChanged>(_onStartDateChanged);
    on<EndDateChanged>(_onEndDateChanged);
    on<DurationMonthsChanged>(_onDurationMonthsChanged);
    on<PaymentMethodChanged>(_onPaymentMethodChanged);
    on<SelectedMidtransMethodChanged>(_onSelectedMidtransMethodChanged);
    on<SubmitReservation>(_onSubmit);
    on<RefreshProfileStatusEvent>(_onRefreshProfileStatus);
  }

  Future<void> _onInit(
    InitReservationEvent event,
    Emitter<ReservationDetailFormState> emit,
  ) async {
    bool isDailyEnabled = true;
    bool isMidtransEnabled = true;
    bool isProfileComplete = true;
    List<String> midtransPaymentMethods = ['qris', 'gopay', 'shopeepay'];

    try {
      final settingEntity = await getSettingsUseCase.execute();
      isDailyEnabled = settingEntity.getBool('feature_daily_rental');
      isMidtransEnabled = settingEntity.getBool('feature_payment_midtrans');
      final methods = settingEntity.getList('midtrans_enabled_payments');
      if (methods.isNotEmpty) midtransPaymentMethods = methods;
    } catch (_) {
      // Keep default if error
    }

    // Profile completion is handled by admin during schedule creation; always allow reservation
    isProfileComplete = true;

    emit(
      state.copyWith(
        room: event.room,
        isDailyRentalEnabled: isDailyEnabled,
        isMidtransEnabled: isMidtransEnabled,
        midtransPaymentMethods: midtransPaymentMethods,
        isProfileComplete: isProfileComplete,
        paymentMethod: isMidtransEnabled ? 'online' : 'tunai',
        rentType: 'Bulanan',
        price: event.room.price.toInt(),
        tenantUserId: event.userId,
        tenantName: event.userName,
      ),
    );

    _calculate(emit);
  }

  void _onRentTypeChanged(
    RentTypeChanged event,
    Emitter<ReservationDetailFormState> emit,
  ) {
    if (state.room == null) return;

    int price;

    if (event.rentType == 'Bulanan') {
      price = state.room!.price.toInt();
    } else if (event.rentType == 'Tahunan') {
      price = (state.room!.price * 12).toInt();
    } else {
      price = state.room!.priceDaily.toInt();
    }

    emit(state.copyWith(rentType: event.rentType, price: price));

    _calculate(emit);
  }

  void _onStartDateChanged(
    StartDateChanged event,
    Emitter<ReservationDetailFormState> emit,
  ) {
    emit(state.copyWith(startDate: event.date));
    _calculate(emit);
  }

  void _onEndDateChanged(
    EndDateChanged event,
    Emitter<ReservationDetailFormState> emit,
  ) {
    emit(state.copyWith(endDate: event.date));
    _calculate(emit);
  }

  void _onDurationMonthsChanged(
    DurationMonthsChanged event,
    Emitter<ReservationDetailFormState> emit,
  ) {
    emit(state.copyWith(durationMonths: event.months));
    _calculate(emit);
  }

  void _onPaymentMethodChanged(
    PaymentMethodChanged event,
    Emitter<ReservationDetailFormState> emit,
  ) {
    emit(
      state.copyWith(
        paymentMethod: event.paymentMethod,
        selectedMidtransMethod:
            null, // Reset pilihan metode saat method berubah
      ),
    );
  }

  void _onSelectedMidtransMethodChanged(
    SelectedMidtransMethodChanged event,
    Emitter<ReservationDetailFormState> emit,
  ) {
    emit(state.copyWith(selectedMidtransMethod: event.method));
  }

  Future<void> _onSubmit(
    SubmitReservation event,
    Emitter<ReservationDetailFormState> emit,
  ) async {
    if (state.room == null || state.startDate == null) return;
    if (state.rentType == 'Harian' && state.endDate == null) return;

    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));

    try {
      String _fmtDate(DateTime d) =>
          "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

      final reservation = await createReservationUseCase.execute(
        roomId: state.room!.id,
        startDate: _fmtDate(state.startDate!),
        endDate: _fmtDate(state.endDate!),
        agreedPrice: state.totalPrice,
        tenantUserId: state.tenantUserId,
        tenantName: state.tenantName,
      );

      emit(
        state.copyWith(
          status: FormzSubmissionStatus.success,
          createdReservation: reservation,
        ),
      );
    } catch (e) {
      String message = 'Gagal membuat reservasi';
      if (e is DioException) {
        message = e.response?.data['message'] ?? message;
      }
      emit(
        state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: message,
        ),
      );
    }
  }

  Future<void> _onRefreshProfileStatus(
    RefreshProfileStatusEvent event,
    Emitter<ReservationDetailFormState> emit,
  ) async {
    emit(state.copyWith(isProfileComplete: true));
  }

  void _calculate(Emitter<ReservationDetailFormState> emit) {
    final start = state.startDate;

    if (start == null) return;

    if (state.rentType == 'Bulanan') {
      final months = state.durationMonths;

      // Calculate end date: same day of month, plus N months
      final end = DateTime(start.year, start.month + months, start.day);

      final total = months * state.price;

      emit(state.copyWith(endDate: end, duration: months, totalPrice: total));
    } else if (state.rentType == 'Tahunan') {
      final years = state.durationMonths;

      // Calculate end date: same day, plus N years
      final end = DateTime(start.year + years, start.month, start.day);

      final total = years * state.price;

      emit(state.copyWith(endDate: end, duration: years, totalPrice: total));
    } else {
      // Daily logic
      final end = state.endDate;
      if (end != null) {
        final duration = end.difference(start).inDays;
        if (duration > 0) {
          final total = duration * state.price;
          emit(state.copyWith(duration: duration, totalPrice: total));
        } else {
          emit(state.copyWith(duration: 0, totalPrice: 0));
        }
      }
    }
  }
}
