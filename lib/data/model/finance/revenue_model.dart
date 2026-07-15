import '../../../domain/entity/finance/revenue_entity.dart';

class RevenueModel extends RevenueEntity {
  RevenueModel({
    required super.month,
    required super.total,
    required super.monthlyRentTotal,
    required super.dailyRentTotal,
  });

  factory RevenueModel.fromJson(Map<String, dynamic> json) {
    return RevenueModel(
      month: json['month'] ?? '',
      total: json['total'] != null
          ? double.parse(json['total'].toString())
          : 0.0,
      monthlyRentTotal: json['monthly_rent_total'] != null
          ? double.parse(json['monthly_rent_total'].toString())
          : 0.0,
      dailyRentTotal: json['daily_rent_total'] != null
          ? double.parse(json['daily_rent_total'].toString())
          : 0.0,
    );
  }
}
