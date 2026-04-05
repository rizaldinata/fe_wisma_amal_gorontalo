import '../entity/maintenance_request_entity.dart';

abstract class MaintenanceRepository {
  Future<List<MaintenanceRequestEntity>> getMyRequests();
  Future<List<MaintenanceRequestEntity>> getAllRequests();
  Future<MaintenanceRequestEntity> getReportById(int id);
  
  /// Creates a report. images is a list of file paths.
  Future<MaintenanceRequestEntity> createReport({
    required String title,
    required String description,
    int? roomId,
    List<String>? imagePaths,
  });

  /// Adds a timeline update.
  Future<MaintenanceTimelineEntity> addUpdateReply({
    required int requestId,
    required String description,
    String? status,
    List<String>? imagePaths,
  });
}
