import '../../../domain/entity/finance/fine_entity.dart';

class FineModel extends FineEntity {
  const FineModel({
    required super.id,
    required super.tenantUserId,
    super.scheduleId,
    required super.tenantName,
    super.tenantPhone,
    required super.amount,
    required super.reason,
    required super.status,
    super.waiveReason,
    super.paidAt,
    super.createdAt,
  });

  factory FineModel.fromJson(Map<String, dynamic> json) {
    return FineModel(
      id:           json['id'] as int,
      tenantUserId: json['tenant_user_id'] as int,
      scheduleId:   json['schedule_id'] as int?,
      tenantName:   json['tenant_name'] as String? ?? '',
      tenantPhone:  json['tenant_phone'] as String?,
      amount:       (json['amount'] as num?)?.toDouble() ?? 0.0,
      reason:       json['reason'] as String? ?? '',
      status:       json['status'] as String? ?? 'unpaid',
      waiveReason:  json['waive_reason'] as String?,
      paidAt:       json['paid_at'] != null ? DateTime.tryParse(json['paid_at']) : null,
      createdAt:    json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }
}
