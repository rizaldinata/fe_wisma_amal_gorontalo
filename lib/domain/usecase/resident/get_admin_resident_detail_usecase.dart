import 'package:frontend/domain/entity/resident/resident_detail_entity.dart';
import 'package:frontend/domain/repository/resident_repository.dart';

class GetAdminResidentDetailUseCase {
  final ResidentRepository _repository;

  GetAdminResidentDetailUseCase(this._repository);

  Future<ResidentDetailEntity> call(String id) async {
    return await _repository.getAdminResidentDetail(id);
  }
}
