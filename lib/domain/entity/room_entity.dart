import 'package:frontend/data/model/room/room_image_model.dart';

enum RoomStatusEnum {
  available,
  occupied,
  maintenance,
  unknown;

  bool get isActive {
    switch (this) {
      case RoomStatusEnum.available:
      case RoomStatusEnum.occupied:
        return true;
      case RoomStatusEnum.maintenance:
        return false;
      case RoomStatusEnum.unknown:
        return false;
    }
  }

  String get displayName {
    switch (this) {
      case RoomStatusEnum.available:
        return 'Tersedia';
      case RoomStatusEnum.occupied:
        return 'Terisi';
      case RoomStatusEnum.maintenance:
        return 'Perbaikan';
      case RoomStatusEnum.unknown:
        return 'Tidak Diketahui';
    }
  }

  static RoomStatusEnum fromString(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return RoomStatusEnum.available;
      case 'occupied':
        return RoomStatusEnum.occupied;
      case 'maintenance':
        return RoomStatusEnum.maintenance;
      default:
        throw ArgumentError('Invalid room status: $status');
    }
  }
}

class RoomEntity {
  final int id;
  final String number;
  final String type;
  final double price;
  final String priceFormatted;
  final RoomStatusEnum status;
  final String statusCode;
  final String description;
  final List<RoomImageModel> imageUrl;
  final List<String> facilities;

  RoomEntity({
    required this.id,
    required this.number,
    required this.type,
    required this.price,
    required this.status,
    required this.description,
    required this.priceFormatted,
    required this.imageUrl,
    required this.facilities,
    required this.statusCode,
  });
}
