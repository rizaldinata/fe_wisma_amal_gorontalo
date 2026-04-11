import 'package:frontend/domain/entity/inventory_entity.dart';

abstract class InventoryRepository {
  Future<List<InventoryEntity>> getInventories();
  Future<InventoryEntity> getInventoryById(int id);
  Future<InventoryEntity> createInventory(InventoryEntity data);
  Future<InventoryEntity> updateInventory(int id, InventoryEntity data);
  Future<void> deleteInventory(int id);
}
