import 'package:file_picker/file_picker.dart';
import '../../domain/entity/maintenance_request_entity.dart';
import '../../domain/repository/maintenance_repository.dart';
import '../datasource/maintenance_remote_datasource.dart';

class MaintenanceRepositoryImpl implements MaintenanceRepository {
  final MaintenanceRemoteDataSource defaultDataSource;

  MaintenanceRepositoryImpl({required this.defaultDataSource});

  @override
  Future<List<MaintenanceRequestEntity>> getMyRequests() async {
    final response = await defaultDataSource.getMyRequests();
    return response.map((e) => e.toEntity()).toList();
  }

  @override
  Future<List<MaintenanceRequestEntity>> getAllRequests() async {
    final response = await defaultDataSource.getAllRequests();
    return response.map((e) => e.toEntity()).toList();
  }

  @override
  Future<MaintenanceRequestEntity> getReportById(int id) async {
    final response = await defaultDataSource.getReportById(id);
    return response.toEntity();
  }

  @override
  Future<MaintenanceRequestEntity> createReport({
    required String title,
    required String description,
    int? roomId,
    List<PlatformFile>? images,
  }) async {
    final response = await defaultDataSource.createReport(
      title: title,
      description: description,
      roomId: roomId,
      images: images,
    );
    return response.toEntity();
  }

  @override
  Future<MaintenanceTimelineEntity> addUpdateReply({
    required int requestId,
    required String description,
    String? status,
    List<PlatformFile>? images,
  }) async {
    final response = await defaultDataSource.addUpdateReply(
      requestId: requestId,
      description: description,
      status: status,
      images: images,
    );
    return response.toEntity();
  }
}
