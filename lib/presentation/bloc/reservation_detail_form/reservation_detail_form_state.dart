part of 'reservation_detail_form_bloc.dart';

class ReservationDetailFormState extends Equatable {
  const ReservationDetailFormState({
    this.rentType = 'Harian',
    this.startDate,
    this.endDate,
    this.duration = 0,
    this.pricePerDay = 150000,
    this.totalPrice = 0,
  });

  final String rentType;
  final DateTime? startDate;
  final DateTime? endDate;
  final int duration;
  final int pricePerDay;
  final int totalPrice;

  ReservationDetailFormState copyWith({
    String? rentType,
    DateTime? startDate,
    DateTime? endDate,
    int? duration,
    int? pricePerDay,
    int? totalPrice,
  }) {
    return ReservationDetailFormState(
      rentType: rentType ?? this.rentType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      duration: duration ?? this.duration,
      pricePerDay: pricePerDay ?? this.pricePerDay,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }

  @override
  List<Object?> get props => [
        rentType,
        startDate,
        endDate,
        duration,
        pricePerDay,
        totalPrice,
      ];
}