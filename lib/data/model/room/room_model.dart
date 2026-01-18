import 'package:frontend/domain/entity/room_entity.dart';

class RoomModel {
  final int id;
  final String number;
  final String type;
  final double price;
  final String status;
  final String? description;
  RoomModel({
    required this.id,
    required this.number,
    required this.type,
    required this.price,
    required this.status,
    this.description,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id'] ?? 0,
      number: json['number'] ?? 0,
      type: json['type'] ?? '',
      price: (json['price'] == null)
          ? 0.0
          : (json['price'] is String
                ? double.tryParse(json['price']) ?? 0.0
                : (json['price'] as num).toDouble()),
      status: json['status'] ?? 'available',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'type': type,
      'price': price,
      'status': status,
      'description': description,
    };
  }

  RoomEntity toEntity() {
    return RoomEntity(
      id: id,
      number: number,
      type: type,
      price: price,
      status: RoomStatusEnum.fromString(status),
      description: description,
    );
  }

  factory RoomModel.fromDomain(RoomEntity entity) {
    return RoomModel(
      id: entity.id,
      number: entity.number,
      type: entity.type,
      price: entity.price,
      status: entity.status.displayName,
      description: entity.description,
    );
  }
}
