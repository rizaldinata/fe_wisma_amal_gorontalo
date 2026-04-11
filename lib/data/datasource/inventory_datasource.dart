import 'package:frontend/core/services/network/dio_client.dart';
import 'package:frontend/data/model/inventory/inventory_model.dart';
import 'package:frontend/domain/entity/inventory_entity.dart';

abstract class InventoryRemoteDatasource {
  Future<List<InventoryModel>> getInventories();
  Future<InventoryModel> getInventoryById(int id);
  Future<InventoryModel> createInventory(InventoryEntity data);
  Future<InventoryModel> updateInventory(int id, InventoryEntity data);
  Future<void> deleteInventory(int id);
}

class InventoryRemoteDatasourceImpl implements InventoryRemoteDatasource {
  final DioClient dioClient;

  InventoryRemoteDatasourceImpl({required this.dioClient});

  @override
  Future<List<InventoryModel>> getInventories() async {
    final response = await dioClient.get('/inventory');
    final data = response.data['data'] as List;
    return data.map((json) => InventoryModel.fromJson(json)).toList();
  }

  @override
  Future<InventoryModel> getInventoryById(int id) async {
    final response = await dioClient.get('/inventory/$id');
    return InventoryModel.fromJson(response.data['data']);
  }

  @override
  Future<InventoryModel> createInventory(InventoryEntity entity) async {
    final model = InventoryModel.fromEntity(entity);
    final response = await dioClient.post('/inventory', data: model.toJson());
    return InventoryModel.fromJson(response.data['data']);
  }

  @override
  Future<InventoryModel> updateInventory(int id, InventoryEntity entity) async {
    final model = InventoryModel.fromEntity(entity);
    final response = await dioClient.put('/inventory/$id', data: model.toJson());
    return InventoryModel.fromJson(response.data['data']);
  }

  @override
  Future<void> deleteInventory(int id) async {
    await dioClient.delete('/inventory/$id');
  }
}
