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
        return InventoryCondition.baik;
      case 'cukup':
        return InventoryCondition.cukup;
      case 'rusak ringan':
        return InventoryCondition.rusakRingan;
      case 'rusak berat':
        return InventoryCondition.rusakBerat;
      default:
        throw ArgumentError('Invalid inventory condition: $value');
    }
  }

  static List<String> get displayNames =>
      InventoryCondition.values.map((e) => e.displayName).toList();
}

enum InventoryType {
  umum,
  alatKerja,
  elektronik,
  furniture;

  String get displayName {
    switch (this) {
      case InventoryType.umum:
        return 'Umum';
      case InventoryType.alatKerja:
        return 'Alat Kerja';
      case InventoryType.elektronik:
        return 'Elektronik';
      case InventoryType.furniture:
        return 'Furniture';
    }
  }

  static InventoryType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'umum':
        return InventoryType.umum;
      case 'alat kerja':
        return InventoryType.alatKerja;
      case 'elektronik':
        return InventoryType.elektronik;
      case 'furniture':
        return InventoryType.furniture;
      default:
        throw ArgumentError('Invalid inventory type: $value');
    }
  }

  static List<String> get displayNames =>
      InventoryType.values.map((e) => e.displayName).toList();
}

enum InventoryCategory {
  kebersihan,
  makananMinuman,
  alatKerja,
  elektronik,
  furniture,
  lainnya;

  String get displayName {
    switch (this) {
      case InventoryCategory.kebersihan:
        return 'Kebersihan';
      case InventoryCategory.makananMinuman:
        return 'Makanan & Minuman';
      case InventoryCategory.alatKerja:
        return 'Alat Kerja';
      case InventoryCategory.elektronik:
        return 'Elektronik';
      case InventoryCategory.furniture:
        return 'Furniture';
      case InventoryCategory.lainnya:
        return 'Lainnya';
    }
  }

  static InventoryCategory fromString(String value) {
    switch (value.toLowerCase()) {
      case 'kebersihan':
        return InventoryCategory.kebersihan;
      case 'makanan & minuman':
        return InventoryCategory.makananMinuman;
      case 'alat kerja':
        return InventoryCategory.alatKerja;
      case 'elektronik':
        return InventoryCategory.elektronik;
      case 'furniture':
        return InventoryCategory.furniture;
      case 'lainnya':
        return InventoryCategory.lainnya;
      default:
        throw ArgumentError('Invalid inventory category: $value');
    }
  }

  static List<String> get displayNames =>
      InventoryCategory.values.map((e) => e.displayName).toList();
}

class InventoryEntity {
  final int? id;
  final String nama;
  final String keterangan;
  final int jumlah;
  final InventoryCondition kondisi;
  final InventoryType jenis;
  final InventoryCategory kategori;

  const InventoryEntity({
    this.id,
    required this.nama,
    required this.keterangan,
    required this.jumlah,
    required this.kondisi,
    required this.jenis,
    required this.kategori,
  });

  InventoryEntity copyWith({
    int? id,
    String? nama,
    String? keterangan,
    int? jumlah,
    InventoryCondition? kondisi,
    InventoryType? jenis,
    InventoryCategory? kategori,
  }) {
    return InventoryEntity(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      keterangan: keterangan ?? this.keterangan,
      jumlah: jumlah ?? this.jumlah,
      kondisi: kondisi ?? this.kondisi,
      jenis: jenis ?? this.jenis,
      kategori: kategori ?? this.kategori,
    );
  }

  const InventoryEntity.empty()
    : this(
        id: null,
        nama: '',
        keterangan: '',
        jumlah: 0,
        kondisi: InventoryCondition.baik,
        jenis: InventoryType.umum,
        kategori: InventoryCategory.lainnya,
      );

  /// Convert to Map for compatibility / serialization
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'nama': nama,
      'keterangan': keterangan,
      'jumlah': jumlah,
      'kondisi': kondisi.displayName,
      'jenis': jenis.displayName,
      'kategori': kategori.displayName,
    };
  }

  /// Create from Map (useful for model → entity conversion)
  factory InventoryEntity.fromMap(Map<String, dynamic> map) {
    return InventoryEntity(
      id: map['id'] as int?,
      nama: map['nama'] as String? ?? '',
      keterangan: map['keterangan'] as String? ?? '',
      jumlah: map['jumlah'] as int? ?? 0,
      kondisi: InventoryCondition.fromString(
        map['kondisi'] as String? ?? 'Baik',
      ),
      jenis: InventoryType.fromString(map['jenis'] as String? ?? 'Umum'),
      kategori: InventoryCategory.fromString(
        map['kategori'] as String? ?? 'Lainnya',
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is InventoryEntity &&
        other.id == id &&
        other.nama == nama &&
        other.keterangan == keterangan &&
        other.jumlah == jumlah &&
        other.kondisi == kondisi &&
        other.jenis == jenis &&
        other.kategori == kategori;
  }

  @override
  int get hashCode =>
      Object.hash(id, nama, keterangan, jumlah, kondisi, jenis, kategori);

  @override
  String toString() =>
      'InventoryEntity(id: $id, nama: $nama, jumlah: $jumlah, kondisi: ${kondisi.displayName}, jenis: ${jenis.displayName}, kategori: ${kategori.displayName})';
}
