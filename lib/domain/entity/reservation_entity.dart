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
  // DP fields
  final String? paymentScheme; // 'full' | 'dp'
  final double? dpAmount;
  final String? dpPaidAt;
  final bool? dpRefundEligible;
  final String? invoiceType; // 'sewa' | 'dp' | 'pelunasan'

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
    this.paymentScheme,
    this.dpAmount,
    this.dpPaidAt,
    this.dpRefundEligible,
    this.invoiceType,
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
      paymentScheme: paymentScheme,
      dpAmount: dpAmount,
      dpPaidAt: dpPaidAt,
      dpRefundEligible: dpRefundEligible,
      invoiceType: invoiceType,
    );
  }

  bool get isDp => paymentScheme == 'dp';
  bool get isDpTerbayar => status == 'dp_terbayar';

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
        paymentScheme,
        dpAmount,
        dpPaidAt,
        dpRefundEligible,
        invoiceType,
      ];
}
