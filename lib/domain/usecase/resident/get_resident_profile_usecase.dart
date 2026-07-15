import 'package:frontend/domain/entity/resident/resident_profile_entity.dart';
import 'package:frontend/domain/repository/resident_repository.dart';

class GetResidentProfileUseCase {
  final ResidentRepository repository;

  GetResidentProfileUseCase(this.repository);

  Future<ResidentProfileEntity> call() => repository.getProfile();
}
