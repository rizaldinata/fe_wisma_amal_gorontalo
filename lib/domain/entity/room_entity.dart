import 'package:flutter/material.dart';
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

  Color get getColor {
    switch (this) {
      case RoomStatusEnum.available:
        return Colors.green;
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
  final String title;
  final String number;
  final String type;
  final double price;
  final String priceFormatted;
  final RoomStatusEnum status;
  final String statusCode;
  final String description;
  final List<RoomImageModel> imageUrl;
  final List<String> facilities;

  const RoomEntity({
    required this.id,
    required this.title,
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

  copyWith({
    int? id,
    String? title,
    String? number,
    String? type,
    double? price,
    RoomStatusEnum? status,
    String? description,
    String? priceFormatted,
    List<RoomImageModel>? imageUrl,
    List<String>? facilities,
    String? statusCode,
  }) {
    return RoomEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      number: number ?? this.number,
      type: type ?? this.type,
      price: price ?? this.price,
      status: status ?? this.status,
      description: description ?? this.description,
      priceFormatted: priceFormatted ?? this.priceFormatted,
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
        type: '',
        price: 0.0,
        status: RoomStatusEnum.unknown,
        description: '',
        priceFormatted: '',
        imageUrl: const [],
        facilities: const [],
        statusCode: '',
      );
}
