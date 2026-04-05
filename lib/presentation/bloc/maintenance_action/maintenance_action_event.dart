import 'package:equatable/equatable.dart';

abstract class MaintenanceActionEvent extends Equatable {
  const MaintenanceActionEvent();

  @override
  List<Object?> get props => [];
}

class SubmitMaintenanceRequest extends MaintenanceActionEvent {
  final String title;
  final String description;
  final int? roomId;
  final List<String>? imagePaths;

  const SubmitMaintenanceRequest({
    required this.title,
    required this.description,
    this.roomId,
    this.imagePaths,
  });

  @override
  List<Object?> get props => [title, description, roomId, imagePaths];
}

class SubmitMaintenanceUpdate extends MaintenanceActionEvent {
  final int requestId;
  final String description;
  final String? status;
  final List<String>? imagePaths;

  const SubmitMaintenanceUpdate({
    required this.requestId,
    required this.description,
    this.status,
    this.imagePaths,
  });

  @override
  List<Object?> get props => [requestId, description, status, imagePaths];
}
