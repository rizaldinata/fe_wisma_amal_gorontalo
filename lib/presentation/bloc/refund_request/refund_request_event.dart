import 'package:file_picker/file_picker.dart';

abstract class RefundRequestEvent {}

class LoadRefundRequestsEvent extends RefundRequestEvent {
  final String? status;
  LoadRefundRequestsEvent({this.status});
}

class ProsesRefundEvent extends RefundRequestEvent {
  final int id;
  final PlatformFile? proof;
  final double adminFee;
  final String adminNotes;

  ProsesRefundEvent({
    required this.id,
    this.proof,
    this.adminFee = 0,
    this.adminNotes = '',
  });
}

class TolakRefundEvent extends RefundRequestEvent {
  final int id;
  final String adminNotes;

  TolakRefundEvent({required this.id, required this.adminNotes});
}
