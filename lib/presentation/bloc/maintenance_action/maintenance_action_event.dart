import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';

abstract class MaintenanceActionEvent extends Equatable {
  const MaintenanceActionEvent();

  @override
  List<Object?> get props => [];
}

class SubmitMaintenanceRequest extends MaintenanceActionEvent {
  final String title;
  final String description;
  final int? roomId;
  final List<PlatformFile>? images;

  const SubmitMaintenanceRequest({
    required this.title,
    required this.description,
    this.roomId,
    this.images,
  });

  @override
  List<Object?> get props => [title, description, roomId, images];
}

class SubmitMaintenanceUpdate extends MaintenanceActionEvent {
  final int requestId;
  final String description;
  final String? status;
  final List<PlatformFile>? images;

  const SubmitMaintenanceUpdate({
    required this.requestId,
    required this.description,
    this.status,
    this.images,
  });

  @override
  List<Object?> get props => [requestId, description, status, images];
}
