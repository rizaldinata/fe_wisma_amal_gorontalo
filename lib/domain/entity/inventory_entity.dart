import 'package:flutter/material.dart';

enum InventoryCondition {
  baik,
  cukup,
  rusakRingan,
  rusakBerat;

  String get displayName {
    switch (this) {
      case InventoryCondition.baik:
        return 'Baik';
      case InventoryCondition.cukup:
        return 'Cukup';
      case InventoryCondition.rusakRingan:
        return 'Rusak Ringan';
      case InventoryCondition.rusakBerat:
        return 'Rusak Berat';
    }
  }

  Color get color {
    switch (this) {
      case InventoryCondition.baik:
        return Colors.green;
      case InventoryCondition.cukup:
        return Colors.orange;
      case InventoryCondition.rusakRingan:
        return Colors.deepOrange;
      case InventoryCondition.rusakBerat:
        return Colors.red;
    }
  }

  static InventoryCondition fromString(String value) {
    switch (value.toLowerCase()) {
      case 'baik':
      case 'good':
        return InventoryCondition.baik;
      case 'cukup':
      case 'fair':
        return InventoryCondition.cukup;
      case 'rusak ringan':
      case 'broken':
        return InventoryCondition.rusakRingan;
      case 'rusak berat':
      case 'lost':
        return InventoryCondition.rusakBerat;
      default:
        // Defaulting to baik if parsing fails or provide a fallback
        return InventoryCondition.baik;
    }
  }
  
  String toBackendString() {
    switch (this) {
      case InventoryCondition.baik:
        return 'good';
      case InventoryCondition.cukup:
        return 'fair';
      case InventoryCondition.rusakRingan:
        return 'broken';
      case InventoryCondition.rusakBerat:
        return 'lost';
    }
  }

  static List<String> get displayNames =>
      InventoryCondition.values.map((e) => e.displayName).toList();
}

class InventoryEntity {
  final int? id;
  final String nama;
  final String keterangan;
  final int jumlah;
  final InventoryCondition kondisi;
  final double? purchasePrice;

  const InventoryEntity({
    this.id,
    required this.nama,
    required this.keterangan,
    required this.jumlah,
    required this.kondisi,
    this.purchasePrice,
  });

  InventoryEntity copyWith({
    int? id,
    String? nama,
    String? keterangan,
    int? jumlah,
    InventoryCondition? kondisi,
    double? purchasePrice,
  }) {
    return InventoryEntity(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      keterangan: keterangan ?? this.keterangan,
      jumlah: jumlah ?? this.jumlah,
      kondisi: kondisi ?? this.kondisi,
      purchasePrice: purchasePrice ?? this.purchasePrice,
    );
  }

  const InventoryEntity.empty()
    : this(
        id: null,
        nama: '',
        keterangan: '',
        jumlah: 0,
        kondisi: InventoryCondition.baik,
        purchasePrice: null,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is InventoryEntity &&
        other.id == id &&
        other.nama == nama &&
        other.keterangan == keterangan &&
        other.jumlah == jumlah &&
        other.kondisi == kondisi &&
        other.purchasePrice == purchasePrice;
  }

  @override
  int get hashCode =>
      Object.hash(id, nama, keterangan, jumlah, kondisi, purchasePrice);

  @override
  String toString() =>
      'InventoryEntity(id: $id, nama: $nama, jumlah: $jumlah, kondisi: ${kondisi.displayName}, purchasePrice: $purchasePrice)';
}
