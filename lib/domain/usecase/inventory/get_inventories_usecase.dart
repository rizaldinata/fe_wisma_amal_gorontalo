import 'package:frontend/domain/entity/inventory_entity.dart';
import 'package:frontend/domain/repository/inventory_repository.dart';

class GetInventoriesUseCase {
  final InventoryRepository repository;

  GetInventoriesUseCase(this.repository);

  Future<PaginatedInventories> call({int page = 1, int perPage = 10}) async {
    return await repository.getInventories(page, perPage);
  }
}
