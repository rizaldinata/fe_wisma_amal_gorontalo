import 'package:frontend/data/model/room/room_image_model.dart';
import 'package:frontend/domain/entity/room_entity.dart';

class RoomModel {
  final int id;
  final String title;
  final String number;
  final String type;
  final double price;
  final String? priceFormatted;
  final String status;
  final String? statusCode;
  final String? description;
  final List<String> facilities;
  final List<RoomImageModel> images;

  RoomModel({
    required this.id,
    required this.title,
    required this.number,
    required this.type,
    required this.price,
    required this.status,
    this.priceFormatted,
    this.statusCode,
    this.description,
    required this.facilities,
    required this.images,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      number: json['number']?.toString() ?? '',
      type: json['type'] ?? '',
      price: (json['price'] is String)
          ? double.tryParse(json['price']) ?? 0.0
          : (json['price'] as num?)?.toDouble() ?? 0.0,
      priceFormatted: json['price_formatted'],
      status: json['status'] ?? '',
      statusCode: json['status_code'],
      description: json['description'],
      facilities:
          (json['facilities'] as List?)?.map((e) => e.toString()).toList() ??
          const [],
      images:
          (json['images'] as List?)
              ?.map((e) => RoomImageModel.fromJson(e))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'number': number,
      'type': type,
      'price': price,
      'status': statusCode ?? status,
      'description': description,
    };
  }

  RoomEntity toEntity() {
    return RoomEntity(
      id: id,
      title: title,
      number: number,
      type: type,
      price: price,
      status: RoomStatusEnum.fromString(statusCode ?? ''),
      statusCode: statusCode ?? '',
      description: description ?? '',
      priceFormatted: priceFormatted ?? '',
      imageUrl: images,
      facilities: facilities,
    );
  }

  factory RoomModel.fromDomain(RoomEntity entity) {
    return RoomModel(
      id: entity.id,
      title: entity.title,
      number: entity.number,
      type: entity.type,
      price: entity.price,
      status: entity.status.displayName,
      statusCode: entity.status.name,
      description: entity.description,
      facilities: entity.facilities,
      images: entity.imageUrl,
      priceFormatted: entity.priceFormatted,
    );
  }
}
