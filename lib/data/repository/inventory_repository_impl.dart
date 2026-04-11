import 'package:frontend/data/datasource/inventory_datasource.dart';
import 'package:frontend/domain/entity/inventory_entity.dart';
import 'package:frontend/domain/repository/inventory_repository.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  final InventoryRemoteDatasource remoteDatasource;

  InventoryRepositoryImpl({required this.remoteDatasource});

  @override
  Future<List<InventoryEntity>> getInventories() async {
    return await remoteDatasource.getInventories();
  }

  @override
  Future<InventoryEntity> getInventoryById(int id) async {
    return await remoteDatasource.getInventoryById(id);
  }

  @override
  Future<InventoryEntity> createInventory(InventoryEntity data) async {
    return await remoteDatasource.createInventory(data);
  }

  @override
  Future<InventoryEntity> updateInventory(int id, InventoryEntity data) async {
    return await remoteDatasource.updateInventory(id, data);
  }

  @override
  Future<void> deleteInventory(int id) async {
    await remoteDatasource.deleteInventory(id);
  }
}
