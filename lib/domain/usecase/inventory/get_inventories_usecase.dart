import 'package:frontend/domain/entity/inventory_entity.dart';
import 'package:frontend/domain/repository/inventory_repository.dart';

class GetInventoriesUseCase {
  final InventoryRepository repository;

  GetInventoriesUseCase(this.repository);

  Future<List<InventoryEntity>> call() async {
    return await repository.getInventories();
  }
}
