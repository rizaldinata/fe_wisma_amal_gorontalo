import 'package:frontend/domain/entity/room_entity.dart';

class RoomModel extends RoomEntity {
  RoomModel({
    required super.id,
    required super.number,
    required super.type,
    required super.price,
    required super.status,
    super.description,
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
      status: status,
      description: description,
    );
  }
}
