import 'package:equatable/equatable.dart';

class ReservationEntity extends Equatable {
  final int id;
  final String roomTitle;
  final String roomNumber;
  final String residentName;
  final String rentalType;
  final String status;
  final String paymentStatus;
  final String startDate;
  final String endDate;
  final int? invoiceId;
  final double? invoiceAmount;
  final String? paymentExpiresAt;
  final String? selectedPaymentMethod;

  const ReservationEntity({
    required this.id,
    required this.roomTitle,
    required this.roomNumber,
    required this.residentName,
    required this.rentalType,
    required this.status,
    required this.paymentStatus,
    required this.startDate,
    required this.endDate,
    this.invoiceId,
    this.invoiceAmount,
    this.paymentExpiresAt,
    this.selectedPaymentMethod,
  });

  ReservationEntity copyWith({String? selectedPaymentMethod}) {
    return ReservationEntity(
      id: id,
      roomTitle: roomTitle,
      roomNumber: roomNumber,
      residentName: residentName,
      rentalType: rentalType,
      status: status,
      paymentStatus: paymentStatus,
      startDate: startDate,
      endDate: endDate,
      invoiceId: invoiceId,
      invoiceAmount: invoiceAmount,
      paymentExpiresAt: paymentExpiresAt,
      selectedPaymentMethod: selectedPaymentMethod,
    );
  }

  @override
  List<Object?> get props => [
        id,
        roomTitle,
        roomNumber,
        residentName,
        rentalType,
        status,
        paymentStatus,
        startDate,
        endDate,
        invoiceId,
        invoiceAmount,
        paymentExpiresAt,
        selectedPaymentMethod,
      ];
}
