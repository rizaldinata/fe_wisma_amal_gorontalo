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
  });

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
      ];
}