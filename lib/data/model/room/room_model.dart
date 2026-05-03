import 'package:frontend/data/model/room/room_image_model.dart';
import 'package:frontend/domain/entity/room_entity.dart';

class RoomModel {
  final int id;
  final String title;
  final String number;
  final double price;
  final double priceDaily;
  final String? priceFormatted;
  final String? priceDailyFormatted;
  final String status;
  final String statusCode;
  final String? description;
  final List<String> facilities;
  final List<RoomImageModel> images;

  RoomModel({
    required this.id,
    required this.title,
    required this.number,
    required this.price,
    required this.priceDaily,
    required this.status,
    this.priceFormatted,
    this.priceDailyFormatted,
    required this.statusCode,
    this.description,
    required this.facilities,
    required this.images,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      number: json['number']?.toString() ?? '',
      price: (json['price'] is String)
          ? double.tryParse(json['price']) ?? 0.0
          : (json['price'] as num?)?.toDouble() ?? 0.0,
      priceDaily: (json['price_daily'] is String)
          ? double.tryParse(json['price_daily']) ?? 0.0
          : (json['price_daily'] as num?)?.toDouble() ?? 0.0,
      priceFormatted: json['price_formatted'],
      priceDailyFormatted: json['price_daily_formatted'],
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
      'price': price,
      'price_daily': priceDaily,
      'status': statusCode,
      'facilities': facilities,
      'description': description,
    };
  }

  RoomEntity toEntity() {
    return RoomEntity(
      id: id,
      title: title,
      number: number,
      price: price,
      priceDaily: priceDaily,
      status: RoomStatusEnum.fromString(statusCode),
      statusCode: statusCode,
      description: description ?? '',
      priceFormatted: priceFormatted ?? '',
      priceDailyFormatted: priceDailyFormatted ?? '',
      imageUrl: images,
      facilities: facilities,
    );
  }

  factory RoomModel.fromDomain(RoomEntity entity) {
    return RoomModel(
      id: entity.id,
      title: entity.title,
      number: entity.number,
      price: entity.price,
      priceDaily: entity.priceDaily,
      status: entity.status.name,
      statusCode: entity.status.name,
      description: entity.description,
      facilities: entity.facilities,
      images: entity.imageUrl,
      priceFormatted: entity.priceFormatted,
      priceDailyFormatted: entity.priceDailyFormatted,
    );
  }
}
