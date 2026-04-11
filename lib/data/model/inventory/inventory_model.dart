import 'package:frontend/domain/entity/inventory_entity.dart';

class InventoryModel extends InventoryEntity {
  const InventoryModel({
    super.id,
    required super.nama,
    required super.keterangan,
    required super.jumlah,
    required super.kondisi,
    super.purchasePrice,
  });

  factory InventoryModel.fromJson(Map<String, dynamic> json) {
    return InventoryModel(
      id: json['id'] as int?,
      nama: json['name'] as String? ?? json['nama'] as String? ?? '',
      keterangan: json['description'] as String? ?? json['keterangan'] as String? ?? '',
      jumlah: (json['quantity'] as num?)?.toInt() ?? (json['jumlah'] as num?)?.toInt() ?? 0,
      kondisi: json['condition'] != null 
        ? InventoryCondition.fromString(json['condition']) 
        : InventoryCondition.baik,
      purchasePrice: json['purchase_price'] != null 
        ? double.tryParse(json['purchase_price'].toString()) 
        : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': nama,
      'description': keterangan,
      'quantity': jumlah,
      'condition': kondisi.toBackendString(),
      if (purchasePrice != null) 'purchase_price': purchasePrice,
    };
  }

  factory InventoryModel.fromEntity(InventoryEntity entity) {
    return InventoryModel(
      id: entity.id,
      nama: entity.nama,
      keterangan: entity.keterangan,
      jumlah: entity.jumlah,
      kondisi: entity.kondisi,
      purchasePrice: entity.purchasePrice,
    );
  }
}
