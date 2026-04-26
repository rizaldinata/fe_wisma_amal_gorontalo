import 'package:frontend/data/datasource/schedule_datasource.dart';
import 'package:frontend/data/model/schedule/schedule_model.dart';
import 'package:frontend/domain/entity/schedule_entity.dart';
import 'package:frontend/domain/repository/schedule_repository.dart';

class ScheduleRepositoryImpl implements ScheduleRepository {
  final ScheduleRemoteDatasource remoteDatasource;

  ScheduleRepositoryImpl({required this.remoteDatasource});

  @override
  Future<List<ScheduleEntity>> getSchedules() async {
    return await remoteDatasource.getSchedules();
  }

  @override
  Future<ScheduleEntity> getScheduleById(int id) async {
    return await remoteDatasource.getScheduleById(id);
  }

  @override
  Future<ScheduleEntity> createSchedule(ScheduleEntity data) async {
    return await remoteDatasource.createSchedule(data);
  }

  @override
  Future<ScheduleEntity> updateSchedule(int id, ScheduleEntity data) async {
    final model = ScheduleModel.fromEntity(data);
    return await remoteDatasource.update(id, model);
  }

  @override
  Future<void> deleteSchedule(int id) async {
    return await remoteDatasource.delete(id);
  }

  @override
  Future<void> addUpdate(int id, String notes, String? status) async {
    return await remoteDatasource.addUpdate(id, notes, status);
  }
}
