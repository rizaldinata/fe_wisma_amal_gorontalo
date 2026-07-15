import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:formz/formz.dart';
import 'package:frontend/domain/entity/room_entity.dart';
import 'package:frontend/domain/entity/reservation_entity.dart';
import 'package:frontend/domain/entity/setting/midtrans_method_entity.dart';
import 'package:frontend/domain/usecase/finance/get_available_payment_methods_usecase.dart';
import 'package:frontend/domain/usecase/reservation/create_reservation_usecase.dart';
import 'package:frontend/domain/usecase/resident/get_resident_profile_usecase.dart';
import 'package:frontend/domain/usecase/setting/get_public_settings_usecase.dart';

part 'reservation_detail_form_event.dart';
part 'reservation_detail_form_state.dart';

class ReservationDetailFormBloc
    extends Bloc<ReservationDetailFormEvent, ReservationDetailFormState> {
  final GetPublicSettingsUseCase getSettingsUseCase;
  final CreateReservationUseCase createReservationUseCase;
  final GetResidentProfileUseCase getProfileUseCase;
  final GetAvailablePaymentMethodsUseCase getAvailablePaymentMethodsUseCase;

  ReservationDetailFormBloc({
    required this.getSettingsUseCase,
    required this.createReservationUseCase,
    required this.getProfileUseCase,
    required this.getAvailablePaymentMethodsUseCase,
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
    on<ResetConfirmFlagEvent>(
      (event, emit) => emit(state.copyWith(readyToConfirm: false)),
    );
    on<PaymentSchemeChanged>(_onPaymentSchemeChanged);
  }

  Future<void> _onInit(
    InitReservationEvent event,
    Emitter<ReservationDetailFormState> emit,
  ) async {
    bool isDailyEnabled = true;
    bool isMidtransEnabled = true;
    bool isProfileComplete = true;
    List<MidtransMethodEntity> midtransPaymentMethods = const [];

    try {
      final settingEntity = await getSettingsUseCase.execute();
      isDailyEnabled = settingEntity.getBool('feature_daily_rental');
      isMidtransEnabled = settingEntity.getBool('feature_payment_midtrans');
      final codes = settingEntity.getList('midtrans_enabled_payments');
      midtransPaymentMethods = codes.map((c) => MidtransMethodEntity(code: c, label: '')).toList();
    } catch (_) {}

    if (event.isLoggedIn) {
      try {
        final profile = await getProfileUseCase();
        isProfileComplete = _isProfileComplete(profile);
      } catch (_) {
        isProfileComplete = false;
      }
      try {
        midtransPaymentMethods = await getAvailablePaymentMethodsUseCase.execute();
      } catch (_) {}
    }

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
    final threshold = DateTime.now().add(const Duration(days: 7));
    final dpStillAvailable = event.date.isAfter(threshold);
    // Jika DP aktif tapi tanggal tidak lagi memenuhi syarat, kembalikan ke full
    final scheme = state.paymentScheme == 'dp' && !dpStillAvailable ? 'full' : state.paymentScheme;
    emit(state.copyWith(startDate: event.date, paymentScheme: scheme));
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

  void _onPaymentSchemeChanged(
    PaymentSchemeChanged event,
    Emitter<ReservationDetailFormState> emit,
  ) {
    // Jika DP tidak lagi tersedia (start_date sudah diubah ke ≤ H+7), kembalikan ke full
    final scheme = event.scheme == 'dp' && !state.isDpAvailable ? 'full' : event.scheme;
    emit(state.copyWith(paymentScheme: scheme));
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
        paymentScheme: state.paymentScheme,
      );

      emit(
        state.copyWith(
          status: FormzSubmissionStatus.success,
          createdReservation: reservation,
        ),
      );
    } catch (e, st) {
      debugPrint('SubmitReservation error [${e.runtimeType}]: $e\n$st');
      String message = 'Gagal membuat reservasi. Silakan coba lagi.';
      if (e is DioException) {
        final data = e.response?.data;
        if (data is Map<String, dynamic>) {
          // Prioritaskan pesan error field pertama jika ada (422 validation)
          final errors = data['errors'] as Map<String, dynamic>?;
          if (errors != null && errors.isNotEmpty) {
            final firstFieldErrors = errors.values.first;
            if (firstFieldErrors is List && firstFieldErrors.isNotEmpty) {
              message = firstFieldErrors.first.toString();
            } else {
              message = data['message']?.toString() ?? message;
            }
          } else {
            message = data['message']?.toString() ?? message;
          }
        }
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
    try {
      final profile = await getProfileUseCase();
      final isComplete = _isProfileComplete(profile);
      emit(state.copyWith(
        isProfileComplete: isComplete,
        readyToConfirm: isComplete && event.thenConfirm,
      ));
    } catch (_) {
      emit(state.copyWith(isProfileComplete: false));
    }
  }

  bool _isProfileComplete(dynamic profile) {
    return profile.idCardNumber.isNotEmpty &&
        profile.phoneNumber.isNotEmpty &&
        profile.addressKtp.isNotEmpty;
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
