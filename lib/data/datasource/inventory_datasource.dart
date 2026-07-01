import 'package:frontend/core/services/network/dio_client.dart';
import 'package:frontend/core/services/network/exception.dart';
import 'package:frontend/data/model/inventory/inventory_model.dart';
import 'package:frontend/domain/entity/inventory_entity.dart';
import 'package:frontend/domain/entity/pagination_meta.dart';

abstract class InventoryRemoteDatasource {
  Future<PaginatedInventories> getInventories(int page, int perPage);
  Future<InventoryModel> getInventoryById(int id);
  Future<InventoryModel> createInventory(InventoryEntity data);
  Future<InventoryModel> updateInventory(int id, InventoryEntity data);
  Future<void> deleteInventory(int id);
}

class InventoryRemoteDatasourceImpl implements InventoryRemoteDatasource {
  final DioClient dioClient;

  InventoryRemoteDatasourceImpl({required this.dioClient});

  @override
  Future<PaginatedInventories> getInventories(int page, int perPage) async {
    final response = await dioClient.get('/inventory?page=$page&per_page=$perPage');
    final data = response.data['data'] as List? ?? [];
    final meta = response.data['meta'] as Map<String, dynamic>? ?? {};
    return PaginatedInventories(
      data: data.map((json) => InventoryModel.fromJson(json)).toList(),
      meta: PaginationMeta.fromJson(meta),
    );
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
