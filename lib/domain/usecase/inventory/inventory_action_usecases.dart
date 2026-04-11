import 'package:frontend/domain/entity/inventory_entity.dart';
import 'package:frontend/domain/repository/inventory_repository.dart';

class GetInventoryByIdUseCase {
  final InventoryRepository repository;
  GetInventoryByIdUseCase(this.repository);

  Future<InventoryEntity> call(int id) async {
    return await repository.getInventoryById(id);
  }
}

class CreateInventoryUseCase {
  final InventoryRepository repository;
  CreateInventoryUseCase(this.repository);

  Future<InventoryEntity> call(InventoryEntity data) async {
    return await repository.createInventory(data);
  }
}

class UpdateInventoryUseCase {
  final InventoryRepository repository;
  UpdateInventoryUseCase(this.repository);

  Future<InventoryEntity> call(int id, InventoryEntity data) async {
    return await repository.updateInventory(id, data);
  }
}

class DeleteInventoryUseCase {
  final InventoryRepository repository;
  DeleteInventoryUseCase(this.repository);

  Future<void> call(int id) async {
    return await repository.deleteInventory(id);
  }
}
