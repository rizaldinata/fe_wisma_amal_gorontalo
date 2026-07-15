import 'package:frontend/core/services/network/dio_client.dart';
import 'package:frontend/data/model/schedule/schedule_model.dart';
import 'package:frontend/domain/entity/pagination_meta.dart';
import 'package:frontend/domain/entity/schedule_entity.dart';

abstract class ScheduleRemoteDatasource {
  Future<PaginatedSchedules> getSchedules({int page = 1, int perPage = 10});
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
  Future<PaginatedSchedules> getSchedules({
    int page = 1,
    int perPage = 10,
  }) async {
    final response = await dioClient.get(
      '/v1/schedules/',
      queryParams: {'page': page, 'per_page': perPage},
    );

    // In case meta is absent, we use an empty object or default
    final dataList = (response.data['data'] as List?) ?? [];
    final metaObj = response.data['meta'] ?? {};

    final schedules = dataList
        .map((json) => ScheduleModel.fromJson(json))
        .toList();
    final meta = PaginationMeta.fromJson(metaObj);

    return PaginatedSchedules(data: schedules, meta: meta);
  }

  @override
  Future<ScheduleModel> getScheduleById(int id) async {
    final response = await dioClient.get('/v1/schedules/$id');
    return ScheduleModel.fromJson(response.data['data']);
  }

  @override
  Future<ScheduleModel> createSchedule(ScheduleEntity entity) async {
    final model = ScheduleModel.fromEntity(entity);
    final response = await dioClient.post(
      '/v1/schedules/',
      data: model.toJson(),
    );
    return ScheduleModel.fromJson(response.data['data']);
  }

  @override
  Future<ScheduleModel> update(int id, ScheduleModel schedule) async {
    final response = await dioClient.put(
      '/v1/schedules/$id',
      data: schedule.toJson(),
    );
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
      data: {'notes': notes, if (status != null) 'status': status},
    );
  }
}
