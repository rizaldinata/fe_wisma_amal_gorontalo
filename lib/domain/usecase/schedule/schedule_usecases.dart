import 'package:frontend/domain/entity/schedule_entity.dart';
import 'package:frontend/domain/repository/schedule_repository.dart';

class GetSchedulesUseCase {
  final ScheduleRepository repository;
  GetSchedulesUseCase(this.repository);
  Future<List<ScheduleEntity>> call() => repository.getSchedules();
}

class GetScheduleByIdUseCase {
  final ScheduleRepository repository;
  GetScheduleByIdUseCase(this.repository);
  Future<ScheduleEntity> call(int id) => repository.getScheduleById(id);
}

class CreateScheduleUseCase {
  final ScheduleRepository repository;
  CreateScheduleUseCase(this.repository);
  Future<ScheduleEntity> call(ScheduleEntity data) => repository.createSchedule(data);
}

class UpdateScheduleUseCase {
  final ScheduleRepository repository;
  UpdateScheduleUseCase(this.repository);
  Future<ScheduleEntity> call(int id, ScheduleEntity data) => repository.updateSchedule(id, data);
}

class DeleteScheduleUseCase {
  final ScheduleRepository repository;
  DeleteScheduleUseCase(this.repository);
  Future<void> call(int id) => repository.deleteSchedule(id);
}
