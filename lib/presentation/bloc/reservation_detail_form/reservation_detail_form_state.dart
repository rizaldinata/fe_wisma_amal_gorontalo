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
    this.status = FormzSubmissionStatus.initial,
    this.errorMessage,
    this.paymentMethod = 'online',
    this.selectedBank,
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
  final FormzSubmissionStatus status;
  final String? errorMessage;
  final String paymentMethod; // 'online' atau 'tunai'
  final String? selectedBank; // 'mandiri', 'bca', 'bri'

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
    FormzSubmissionStatus? status,
    String? errorMessage,
    String? paymentMethod,
    String? selectedBank,
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
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      selectedBank: selectedBank ?? this.selectedBank,
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
        status,
        errorMessage,
        paymentMethod,
        selectedBank,
      ];
}