import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:frontend/domain/entity/room_entity.dart';
import 'package:frontend/domain/usecase/reservation/create_reservation_usecase.dart';
import 'package:frontend/domain/usecase/setting/get_settings_usecase.dart';
import 'package:frontend/presentation/bloc/auth/auth_bloc.dart';
import 'package:frontend/core/dependency_injection/dependency_injection.dart';

part 'reservation_detail_form_event.dart';
part 'reservation_detail_form_state.dart';

class ReservationDetailFormBloc extends Bloc<
    ReservationDetailFormEvent,
    ReservationDetailFormState> {
  final GetSettingsUseCase getSettingsUseCase;
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
    on<SelectedBankChanged>(_onSelectedBankChanged);
    on<SubmitReservation>(_onSubmit);
  }

  Future<void> _onInit(
    InitReservationEvent event,
    Emitter<ReservationDetailFormState> emit,
  ) async {
    bool isDailyEnabled = true;
    try {
      final authBloc = serviceLocator.get<AuthBloc>();
      if (authBloc.state.isLoggedIn) {
        final settingEntity = await getSettingsUseCase.execute();
        isDailyEnabled = settingEntity.getBool('feature_daily_rental');
      }
    } catch (_) {
      // Keep default if error
    }

    emit(state.copyWith(
      room: event.room,
      isDailyRentalEnabled: isDailyEnabled,
      rentType: 'Bulanan', // Default to Bulanan as requested
      price: event.room.price.toInt(),
    ));

    _calculate(emit);
  }

  void _onRentTypeChanged(
    RentTypeChanged event,
    Emitter<ReservationDetailFormState> emit,
  ) {
    if (state.room == null) return;

    int price = event.rentType == 'Bulanan' 
        ? state.room!.price.toInt() 
        : state.room!.priceDaily.toInt();

    emit(state.copyWith(
      rentType: event.rentType,
      price: price,
    ));

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
    emit(state.copyWith(
      paymentMethod: event.paymentMethod,
      selectedBank: null, // Reset bank selection saat method berubah
    ));
  }

  void _onSelectedBankChanged(
    SelectedBankChanged event,
    Emitter<ReservationDetailFormState> emit,
  ) {
    emit(state.copyWith(selectedBank: event.selectedBank));
  }

  Future<void> _onSubmit(
    SubmitReservation event,
    Emitter<ReservationDetailFormState> emit,
  ) async {
    if (state.room == null || state.startDate == null) return;
    if (state.rentType == 'Harian' && state.endDate == null) return;

    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));

    try {
      final startDateStr = "${state.startDate!.year}-${state.startDate!.month.toString().padLeft(2, '0')}-${state.startDate!.day.toString().padLeft(2, '0')}";
      
      final rentalType = state.rentType == 'Bulanan' ? 'monthly' : 'daily';

      await createReservationUseCase.execute(
        roomId: state.room!.id,
        startDate: startDateStr,
        duration: state.duration,
        rentalType: rentalType,
      );

      emit(state.copyWith(status: FormzSubmissionStatus.success));
    } catch (e) {
      String message = 'Gagal membuat reservasi';
      if (e is DioException) {
        message = e.response?.data['message'] ?? message;
      }
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: message,
      ));
    }
  }

  void _calculate(Emitter<ReservationDetailFormState> emit) {
    final start = state.startDate;
    
    if (start == null) return;

    if (state.rentType == 'Bulanan') {
      final months = state.durationMonths;
      // Calculate end date: same day of month, plus N months
      final end = DateTime(start.year, start.month + months, start.day);
      
      final total = months * state.price;

      emit(state.copyWith(
        endDate: end,
        duration: months,
        totalPrice: total,
      ));
    } else {
      // Daily logic
      final end = state.endDate;
      if (end != null) {
        final duration = end.difference(start).inDays;
        if (duration > 0) {
          final total = duration * state.price;
          emit(state.copyWith(
            duration: duration,
            totalPrice: total,
          ));
        } else {
          emit(state.copyWith(
            duration: 0,
            totalPrice: 0,
          ));
        }
      }
    }
  }
}