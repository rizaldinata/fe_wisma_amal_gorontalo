import 'package:file_picker/file_picker.dart';
import '../entity/maintenance_request_entity.dart';

abstract class MaintenanceRepository {
  Future<List<MaintenanceRequestEntity>> getMyRequests();
  Future<PaginatedMaintenanceRequests> getAllRequests(int page, int perPage);
  Future<MaintenanceRequestEntity> getReportById(int id);
  
  /// Creates a report. images is a list of PlatformFile.
  Future<MaintenanceRequestEntity> createReport({
    required String title,
    required String description,
    int? roomId,
    String? location,
    List<PlatformFile>? images,
  });

  /// Adds a timeline update.
  Future<MaintenanceTimelineEntity> addUpdateReply({
    required int requestId,
    required String description,
    String? status,
    List<PlatformFile>? images,
  });
}
