part of 'reservation_detail_form_bloc.dart';

class ReservationDetailFormState extends Equatable {
  const ReservationDetailFormState({
    this.rentType = 'Bulanan',
    this.startDate,
    this.endDate,
    this.duration = 0,
    this.durationMonths = 1,
    this.price = 0,
    this.totalPrice = 0,
    this.room,
    this.isDailyRentalEnabled = true,
    this.isMidtransEnabled = true,
    this.status = FormzSubmissionStatus.initial,
    this.errorMessage,
    this.paymentMethod = 'online',
    this.selectedMidtransMethod,
    this.midtransPaymentMethods = const [],
    this.createdReservation,
    this.isProfileComplete = true,
    this.tenantUserId,
    this.tenantName,
  });

  final String rentType;
  final DateTime? startDate;
  final DateTime? endDate;
  final int duration;
  final int durationMonths;
  final int price;
  final int totalPrice;
  final RoomEntity? room;
  final bool isDailyRentalEnabled;
  final bool isMidtransEnabled;
  final FormzSubmissionStatus status;
  final String? errorMessage;
  final String paymentMethod; // 'online' atau 'tunai'
  final String? selectedMidtransMethod;
  final List<String> midtransPaymentMethods;
  final ReservationEntity? createdReservation;
  final bool isProfileComplete;
  final int? tenantUserId;
  final String? tenantName;

  ReservationDetailFormState copyWith({
    String? rentType,
    DateTime? startDate,
    DateTime? endDate,
    int? duration,
    int? durationMonths,
    int? price,
    int? totalPrice,
    RoomEntity? room,
    bool? isDailyRentalEnabled,
    bool? isMidtransEnabled,
    FormzSubmissionStatus? status,
    String? errorMessage,
    String? paymentMethod,
    String? selectedMidtransMethod,
    List<String>? midtransPaymentMethods,
    ReservationEntity? createdReservation,
    bool? isProfileComplete,
    int? tenantUserId,
    String? tenantName,
  }) {
    return ReservationDetailFormState(
      rentType: rentType ?? this.rentType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      duration: duration ?? this.duration,
      durationMonths: durationMonths ?? this.durationMonths,
      price: price ?? this.price,
      totalPrice: totalPrice ?? this.totalPrice,
      room: room ?? this.room,
      isDailyRentalEnabled: isDailyRentalEnabled ?? this.isDailyRentalEnabled,
      isMidtransEnabled: isMidtransEnabled ?? this.isMidtransEnabled,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      selectedMidtransMethod: selectedMidtransMethod ?? this.selectedMidtransMethod,
      midtransPaymentMethods: midtransPaymentMethods ?? this.midtransPaymentMethods,
      createdReservation: createdReservation ?? this.createdReservation,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      tenantUserId: tenantUserId ?? this.tenantUserId,
      tenantName: tenantName ?? this.tenantName,
    );
  }

  @override
  List<Object?> get props => [
        rentType,
        startDate,
        endDate,
        duration,
        durationMonths,
        price,
        totalPrice,
        room,
        isDailyRentalEnabled,
        isMidtransEnabled,
        status,
        errorMessage,
        paymentMethod,
        selectedMidtransMethod,
        midtransPaymentMethods,
        createdReservation,
        isProfileComplete,
        tenantUserId,
        tenantName,
      ];
}
