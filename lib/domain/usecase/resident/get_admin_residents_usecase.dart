import 'package:frontend/domain/entity/resident/resident_entity.dart';
import 'package:frontend/domain/repository/resident_repository.dart';

class GetAdminResidentsUseCase {
  final ResidentRepository _repository;

  GetAdminResidentsUseCase(this._repository);

  Future<ResidentResponse> call() async {
    return await _repository.getAdminResidents();
  }
}
