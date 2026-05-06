import 'package:flutter/material.dart';
import 'package:frontend/data/model/room/room_image_model.dart';

enum RoomStatusEnum {
  available,
  reserved,
  occupied,
  maintenance,
  unknown;

  bool get isActive {
    switch (this) {
      case RoomStatusEnum.available:
      case RoomStatusEnum.occupied:
        return true;
      case RoomStatusEnum.reserved:
      case RoomStatusEnum.maintenance:
      case RoomStatusEnum.unknown:
        return false;
    }
  }

  Color get getColor {
    switch (this) {
      case RoomStatusEnum.available:
        return Colors.green;
      case RoomStatusEnum.reserved:
        return Colors.blue;
      case RoomStatusEnum.occupied:
        return Colors.red;
      case RoomStatusEnum.maintenance:
        return Colors.orange;
      case RoomStatusEnum.unknown:
        return Colors.grey;
    }
  }

  String get displayName {
    switch (this) {
      case RoomStatusEnum.available:
        return 'Tersedia';
      case RoomStatusEnum.reserved:
        return 'Dipesan';
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
      case 'reserved':
        return RoomStatusEnum.reserved;
      case 'occupied':
        return RoomStatusEnum.occupied;
      case 'maintenance':
        return RoomStatusEnum.maintenance;
      default:
        return RoomStatusEnum.unknown;
    }
  }
}

class RoomEntity {
  final int id;
  final String title;
  final String number;
  final double price;
  final String priceFormatted;
  final double priceDaily;
  final String priceDailyFormatted;
  final RoomStatusEnum status;
  final String statusCode;
  final String description;
  final List<RoomImageModel> imageUrl;
  final List<String> facilities;

  const RoomEntity({
    required this.id,
    required this.title,
    required this.number,
    required this.price,
    required this.priceDaily,
    required this.status,
    required this.description,
    required this.priceFormatted,
    required this.priceDailyFormatted,
    required this.imageUrl,
    required this.facilities,
    required this.statusCode,
  });

  copyWith({
    int? id,
    String? title,
    String? number,
    double? price,
    double? priceDaily,
    RoomStatusEnum? status,
    String? description,
    String? priceFormatted,
    String? priceDailyFormatted,
    List<RoomImageModel>? imageUrl,
    List<String>? facilities,
    String? statusCode,
  }) {
    return RoomEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      number: number ?? this.number,
      price: price ?? this.price,
      priceDaily: priceDaily ?? this.priceDaily,
      status: status ?? this.status,
      description: description ?? this.description,
      priceFormatted: priceFormatted ?? this.priceFormatted,
      priceDailyFormatted: priceDailyFormatted ?? this.priceDailyFormatted,
      imageUrl: imageUrl ?? this.imageUrl,
      facilities: facilities ?? this.facilities,
      statusCode: statusCode ?? this.statusCode,
    );
  }

  const RoomEntity.empty()
    : this(
        id: 0,
        title: '',
        number: '',
        price: 0.0,
        priceDaily: 0.0,
        status: RoomStatusEnum.unknown,
        description: '',
        priceFormatted: '',
        priceDailyFormatted: '',
        imageUrl: const [],
        facilities: const [],
        statusCode: '',
      );
}
