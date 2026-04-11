import 'package:frontend/domain/repository/schedule_repository.dart';

class AddScheduleUpdateUseCase {
  final ScheduleRepository repository;

  AddScheduleUpdateUseCase(this.repository);

  Future<void> call({
    required int scheduleId,
    required String notes,
    String? status,
  }) async {
    return await repository.addUpdate(scheduleId, notes, status);
  }
}
