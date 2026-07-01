import 'package:frontend/domain/entity/schedule_entity.dart';

abstract class ScheduleRepository {
  Future<PaginatedSchedules> getSchedules({int page = 1, int perPage = 10});
  Future<ScheduleEntity> getScheduleById(int id);
  Future<ScheduleEntity> createSchedule(ScheduleEntity data);
  Future<ScheduleEntity> updateSchedule(int id, ScheduleEntity data);
  Future<void> deleteSchedule(int id);
  Future<void> addUpdate(int id, String notes, String? status);
}
