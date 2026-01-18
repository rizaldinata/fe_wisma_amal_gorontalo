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
      case 'tersedia':
        return RoomStatusEnum.available;
      case 'terisi':
        return RoomStatusEnum.occupied;
      case 'perbaikan':
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
  final RoomStatusEnum status;
  final String? description;

  RoomEntity({
    required this.id,
    required this.number,
    required this.type,
    required this.price,
    required this.status,
    this.description,
  });
}
