import '../../../domain/entity/finance/revenue_entity.dart';

class RevenueModel extends RevenueEntity {
  RevenueModel({required super.month, required super.total});

  factory RevenueModel.fromJson(Map<String, dynamic> json) {
    return RevenueModel(
      month: json['month'] ?? '',
      total: json['total'] != null
          ? double.parse(json['total'].toString())
          : 0.0,
    );
  }
}
