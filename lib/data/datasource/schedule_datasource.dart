import 'package:frontend/core/services/network/dio_client.dart';
import 'package:frontend/data/model/schedule/schedule_model.dart';
import 'package:frontend/domain/entity/schedule_entity.dart';

abstract class ScheduleRemoteDatasource {
  Future<List<ScheduleModel>> getSchedules();
  Future<ScheduleModel> getScheduleById(int id);
  Future<ScheduleModel> createSchedule(ScheduleEntity data);
  Future<ScheduleModel> update(int id, ScheduleModel schedule);
  Future<void> delete(int id);
  Future<void> addUpdate(int scheduleId, String notes, String? status);
}

class ScheduleRemoteDatasourceImpl implements ScheduleRemoteDatasource {
  final DioClient dioClient;

  ScheduleRemoteDatasourceImpl({required this.dioClient});

  @override
  Future<List<ScheduleModel>> getSchedules() async {
    final response = await dioClient.get('/v1/schedules/');
    final data = response.data['data'] as List;
    return data.map((json) => ScheduleModel.fromJson(json)).toList();
  }

  @override
  Future<ScheduleModel> getScheduleById(int id) async {
    final response = await dioClient.get('/v1/schedules/$id');
    return ScheduleModel.fromJson(response.data['data']);
  }

  @override
  Future<ScheduleModel> createSchedule(ScheduleEntity entity) async {
    final model = ScheduleModel.fromEntity(entity);
    final response = await dioClient.post('/v1/schedules/', data: model.toJson());
    return ScheduleModel.fromJson(response.data['data']);
  }

  @override
  Future<ScheduleModel> update(int id, ScheduleModel schedule) async {
    final response = await dioClient.put('/v1/schedules/$id', data: schedule.toJson());
    return ScheduleModel.fromJson(response.data['data']);
  }

  @override
  Future<void> delete(int id) async {
    await dioClient.delete('/v1/schedules/$id');
  }

  @override
  Future<void> addUpdate(int scheduleId, String notes, String? status) async {
    await dioClient.post(
      '/v1/schedules/$scheduleId/updates',
      data: {
        'notes': notes,
        if (status != null) 'status': status,
      },
    );
  }
}
